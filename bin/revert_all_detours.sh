#!/usr/bin/env sh
# Revert/uninstall all detour changes, production-ready, idempotent.
# Usage:
#   DRY_RUN=1 bin/revert_all_detours.sh
#   bin/revert_all_detours.sh
#   bin/revert_all_detours.sh --push
# Env:
#   KEEP_ASCII_FIX=1  (keep {{ "/scripts/" | absURL }} in ASCII files)
#   KEEP_NOJEKYLL=1   (keep static/.nojekyll)

set -eu

say(){ printf "%s\n" "$*"; }
note(){ printf "INFO: %s\n" "$*"; }
die(){ printf "ERROR: %s\n" "$*" >&2; exit 1; }
dry(){ [ "${DRY_RUN:-0}" != "0" ]; }

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "Not in a Git repo."
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"; cd "$ROOT" || exit 1
say "Repo root: $ROOT"

_do_rm(){ if dry; then note "rm -f $*"; else rm -f "$@"; fi; }
_do_mv(){ if dry; then note "mv -f $1 $2"; else mv -f "$1" "$2"; fi; }
_do_cp(){ if dry; then note "cp -f $1 $2"; else cp -f "$1" "$2"; fi; }

restore_workflows(){
  say "== Restore workflows =="
  W=".github/workflows"; [ -d "$W" ] || { note "No $W; skip"; return; }
  [ -f "$W/build-and-deploy.yml.disabled" ] && { say "ENABLED: $W/build-and-deploy.yml"; _do_mv "$W/build-and-deploy.yml.disabled" "$W/build-and-deploy.yml"; } || note "No disabled build-and-deploy.yml"
  [ -f "$W/hugo.yml.disabled" ] && { say "ENABLED: $W/hugo.yml"; _do_mv "$W/hugo.yml.disabled" "$W/hugo.yml"; } || note "No disabled hugo.yml"
  [ -f "$W/pages.yml" ] && { say "REMOVED: $W/pages.yml"; _do_rm "$W/pages.yml"; } || note "No consolidated pages.yml"
}

remove_layout_overrides(){
  say "== Remove layout overrides =="
  for f in \
    layouts/scripts/list.html \
    layouts/section/scripts.html \
    layouts/_default/list.html \
    layouts/_default/baseof.html
  do
    [ -f "$f" ] && { say "REMOVED: $f"; _do_rm "$f"; } || note "Skip missing: $f"
  done
  for b in layouts/index.html.bak.* layouts/scripts/list.html.bak.*; do
    [ -e "$b" ] || continue
    say "CLEANUP: $b"; _do_rm "$b"
  done
}

restore_index_backup_if_any(){
  say "== Restore layouts/index.html from latest backup (if any) =="
  latest=""
  for b in $(ls -1t layouts/index.html.bak.* 2>/dev/null || true); do latest="$b"; break; done
  [ -n "$latest" ] || { note "No index.html backup found."; return; }
  say "RESTORE: $latest -> layouts/index.html"
  if [ -f "layouts/index.html" ] && ! dry; then cp -f layouts/index.html "layouts/index.html.reverted.$(date +%s)"; fi
  _do_cp "$latest" "layouts/index.html"
}

revert_ascii_absurl(){
  say "== Revert ASCII absURL (unless KEEP_ASCII_FIX=1) =="
  [ "${KEEP_ASCII_FIX:-0}" = "1" ] && { note "Keeping ASCII absURL"; return; }
  for f in static/ascii-index.html themes/4ndr0line/layouts/ascii-index.html; do
    [ -f "$f" ] || { note "Skip missing: $f"; continue; }
    say "PATCH: $f"
    # Use safe delimiters so '|' and '/' in templates are not treated as sed separators.
    # 1) {{ "/scripts/" | absURL }}  ->  {{ "/scripts/" | relURL }}
    if dry; then
      note "sed -i 's~{{[[:space:]]*\"/?scripts/\"[[:space:]]*\\|[[:space:]]*absURL[[:space:]]*}}~{{ \"/scripts/\" | relURL }}~g' $f"
    else
      sed -i 's~{{[[:space:]]*"/\?scripts/"[[:space:]]*\|[[:space:]]*absURL[[:space:]]*}}~{{ "/scripts/" | relURL }}~g' "$f"
    fi
    # 2) href="/4ndr0site/scripts/" -> helper
    if dry; then
      note "sed -E -i 's@(href=[\"'\"''])/4ndr0site/scripts/([\"'\"''])@\\1{{ \"/scripts/\" | relURL }}\\2@g' $f"
    else
      sed -E -i 's@(href=["'\''])/4ndr0site/scripts/(["'\''])@\1{{ "/scripts/" | relURL }}\2@g' "$f"
    fi
    # 3) href="/scripts/" -> helper
    if dry; then
      note "sed -E -i 's@(href=[\"'\"''])/scripts/([\"'\"''])@\\1{{ \"/scripts/\" | relURL }}\\2@g' $f"
    else
      sed -E -i 's@(href=["'\''])/scripts/(["'\''])@\1{{ "/scripts/" | relURL }}\2@g' "$f"
    fi
  done
}

remove_nojekyll(){
  say "== Remove static/.nojekyll (unless KEEP_NOJEKYLL=1) =="
  [ "${KEEP_NOJEKYLL:-0}" = "1" ] && { note "Keeping .nojekyll"; return; }
  [ -f static/.nojekyll ] && { say "REMOVED: static/.nojekyll"; _do_rm static/.nojekyll; } || note "No .nojekyll"
}

scrub_lastmod(){
  say "== Scrub trailing lastmod lines in content/scripts/*.md (outside front matter) =="
  changed=0
  for f in content/scripts/*.md; do
    [ -f "$f" ] || continue
    if dry; then note "Would scrub lastmod in $f"; continue; fi
    awk '
      BEGIN{infm=0}
      /^---[ \t]*$/ { infm = 1 - infm; print; next }
      {
        if (infm==0 && $0 ~ /^lastmod:[[:space:]]+[0-9]{4}-[0-9]{2}-[0-9]{2}T[^[:space:]]+Z[[:space:]]*$/) next
        print
      }
    ' "$f" > "$f.__tmp__"
    if ! cmp -s "$f" "$f.__tmp__"; then mv "$f.__tmp__" "$f"; say "CLEANED: $f"; changed=1; else rm -f "$f.__tmp__"; fi
  done
  [ "$changed" -eq 0 ] && note "No trailing lastmod lines found."
}

remove_helper_bins(){
  say "== Remove helper bin scripts =="
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    [ -f "$f" ] || { note "Skip missing: $f"; continue; }
    say "REMOVED: $f"; _do_rm "$f"
  done <<'EOF'
bin/hugo_wire_scripts_section.sh
bin/wire_scripts_and_deploy.sh
bin/fix_scripts_list_block.sh
bin/fix_pages_child_404.sh
bin/normalize_pages_workflow.sh
bin/live_verify.sh
bin/debug_live_scripts.sh
bin/force_redeploy_and_probe.sh
bin/harden_scripts_list_blocks.sh
bin/force_section_layout.sh
bin/diagnose_scripts_pages.sh
bin/add_content_block_for_lists.sh
bin/stamp_and_probe_scripts.sh
bin/stamp_all_scripts_templates.sh
bin/fallback_list_template.sh
bin/fix_ascii_scripts_link.sh
bin/revert_extras.sh
bin/verify_live.sh
bin/fix_scripts_link.sh
EOF
}

build_commit_push(){
  say "== Build =="
  if dry; then note "hugo --minify (dry run)"; else hugo --minify; fi

  say "== Git stage & commit =="
  if dry; then note "git add -A (dry run)"; else git add -A; fi

  if git diff --cached --quiet; then
    note "No changes to commit."
  else
    if dry; then note "git commit (dry run)"; else git commit -m "revert: remove detour layouts/workflows; restore original state"; say "Committed."; fi
  fi

  if [ "${1:-}" = "--push" ]; then
    BR="$(git rev-parse --abbrev-ref HEAD)"
    if dry; then note "git push origin $BR (dry run)"; else say "Pushing to origin/$BR…"; git push origin "$BR"; fi
  else
    note "Push skipped (use --push)."
  fi
}

PUSH_ARG=""
[ "${1:-}" = "--push" ] && PUSH_ARG="--push"

restore_workflows
remove_layout_overrides
restore_index_backup_if_any
revert_ascii_absurl
remove_nojekyll
scrub_lastmod
remove_helper_bins
build_commit_push "$PUSH_ARG"

say "DONE."
