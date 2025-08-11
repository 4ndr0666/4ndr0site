#!/usr/bin/env bash
# File: scripts/hugo_wire_scripts_section_v2.sh
# Purpose: Ensure /scripts/ section renders cleanly and "exit" routes to it.
# - Creates/updates layouts/scripts/list.html (site-level override)
# - Patches layouts/index.html 'exit' to point to {{ "/scripts/" | relURL }} (override with EXIT_TARGET)
# - Builds and verifies outputs with clear diagnostics
# Idempotent. Verbose. Safe to run from any directory.

set -u
IFS=$'\n\t'

ok=true
failc=0

log()  { printf '%s\n' "$*"; }
info() { printf 'INFO: %s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
err()  { printf 'ERROR: %s\n' "$*" >&2; ok=false; failc=$((failc+1)); }

# ---------- Resolve repo root ----------
resolve_repo_root() {
  # 1) If inside a git repo, use top-level
  if command -v git >/dev/null 2>&1 && git rev-parse --show-toplevel >/dev/null 2>&1; then
    git rev-parse --show-toplevel
    return
  fi
  # 2) Else, walk up until we find config.yml and static/
  local d="$PWD"
  while [[ "$d" != "/" ]]; do
    if [[ -f "$d/config.yml" && -d "$d/static" ]]; then
      echo "$d"; return
    fi
    d="$(dirname "$d")"
  done
  echo ""  # not found
}

REPO_ROOT="$(resolve_repo_root)"
if [[ -z "$REPO_ROOT" ]]; then
  err "Could not locate repo root. Run inside the repo or ensure config.yml & static/ exist."
  printf 'Hint: cd /path/to/4ndr0site and rerun.\n' >&2
  exit 1
fi
cd "$REPO_ROOT" || { err "Failed to cd to $REPO_ROOT"; exit 1; }
info "Using repo root: $REPO_ROOT"

# ---------- Config ----------
EXIT_TARGET_DEFAULT='{{ "/scripts/" | relURL }}'
EXIT_TARGET="${EXIT_TARGET:-$EXIT_TARGET_DEFAULT}"

LIST_TPL_PATH="$REPO_ROOT/layouts/scripts/list.html"
INDEX_TPL_PATH="$REPO_ROOT/layouts/index.html"
BACKUP_SUFFIX=".bak.$(date +%s)"

# ---------- Preconditions ----------
[[ -f "$REPO_ROOT/config.yml" ]] || err "Missing $REPO_ROOT/config.yml"
[[ -d "$REPO_ROOT/layouts"   ]] || err "Missing $REPO_ROOT/layouts/"
[[ -f "$INDEX_TPL_PATH"      ]] || err "Missing $INDEX_TPL_PATH"

if ! $ok; then
  err "Pre-checks failed. Fix the above and rerun."
  exit 1
fi

mkdir -p "$(dirname "$LIST_TPL_PATH")" || { err "Cannot create $(dirname "$LIST_TPL_PATH")"; exit 1; }

# ---------- Step 1: Ensure section list template ----------
read -r -d '' DESIRED_LIST_TPL <<'HUGO'
{{ define "main" }}
<main class="container" style="max-width: 60rem; margin: 0 auto; padding: 2rem 1rem;">
  <header style="margin-bottom: 1.5rem;">
    <h1 style="margin: 0 0 .25rem 0;">{{ .Title }}</h1>
    {{ with .Params.description }}
      <p style="margin: .25rem 0 0 0; opacity: .85;">{{ . }}</p>
    {{ end }}
  </header>

  <section aria-labelledby="notes-heading" style="margin-top: 1rem;">
    <h2 id="notes-heading" style="font-size: 1.25rem; margin: 0 0 .75rem 0;">Notes & Articles</h2>

    {{ if .Pages }}
      <ul style="list-style: none; padding: 0; margin: 0;">
        {{ range .Pages.ByDate.Reverse }}
          <li style="margin: 0 0 .75rem 0;">
            <a href="{{ .RelPermalink }}" style="text-decoration: none;">
              <strong>{{ .Title }}</}}</strong>
            </a>
            {{ with .Date }}<small style="opacity:.7;"> — {{ .Format "2006-01-02" }}</small>{{ end }}
            {{ with .Summary }}<div style="opacity:.85; margin-top:.25rem;">{{ . }}</div>{{ end }}
          </li>
        {{ end }}
      </ul>
    {{ else }}
      <p>No published entries yet.</p>
    {{ end }}
  </section>

  <section aria-labelledby="assets-heading" style="margin-top: 2rem;">
    <h2 id="assets-heading" style="font-size: 1.25rem; margin: 0 0 .5rem 0;">Static Assets (Optional)</h2>
    <p style="margin: 0;">
      Place raw files in <code>static/scripts/</code> to serve them at
      <code>{{ "/scripts/" | relURL }}</code>.
    </p>
  </section>
</main>
{{ end }}
HUGO

# fix minor template typo if any (defensive)
DESIRED_LIST_TPL="${DESIRED_LIST_TPL//\{\}\}/\}}"

if [[ -f "$LIST_TPL_PATH" ]]; then
  if ! diff -q <(printf "%s" "$DESIRED_LIST_TPL") "$LIST_TPL_PATH" >/dev/null 2>&1; then
    cp -f "$LIST_TPL_PATH" "$LIST_TPL_PATH$BACKUP_SUFFIX"
    printf "%s" "$DESIRED_LIST_TPL" > "$LIST_TPL_PATH"
    log "UPDATED: $LIST_TPL_PATH  (backup: $LIST_TPL_PATH$BACKUP_SUFFIX)"
  else
    info "OK: $LIST_TPL_PATH already up to date"
  fi
else
  printf "%s" "$DESIRED_LIST_TPL" > "$LIST_TPL_PATH"
  log "CREATED: $LIST_TPL_PATH"
fi

# ---------- Step 2: Patch 'exit' case in layouts/index.html ----------
PATCHED_INDEX="$(mktemp)"
awk -v target="$EXIT_TARGET" '
  BEGIN { in_exit=0 }
  /^\s*case[[:space:]]+'\''exit'\'':\s*$/ { in_exit=1; print; next }
  in_exit==1 && /window\.location[[:space:]]*=/ {
    print "                setTimeout(function(){window.location = " target "}, 2000);"
    next
  }
  in_exit==1 && /^\s*break;\s*$/ { in_exit=0; print; next }
  { print }
' "$INDEX_TPL_PATH" > "$PATCHED_INDEX" || { err "AWK patch failed on $INDEX_TPL_PATH"; rm -f "$PATCHED_INDEX"; exit 1; }

if ! diff -q "$PATCHED_INDEX" "$INDEX_TPL_PATH" >/dev/null 2>&1; then
  cp -f "$INDEX_TPL_PATH" "$INDEX_TPL_PATH$BACKUP_SUFFIX"
  mv "$PATCHED_INDEX" "$INDEX_TPL_PATH"
  log "UPDATED: $INDEX_TPL_PATH  (backup: $INDEX_TPL_PATH$BACKUP_SUFFIX)"
else
  rm -f "$PATCHED_INDEX"
  info "OK: $INDEX_TPL_PATH already routes exit to target"
fi

# ---------- Step 3: Build ----------
log "== Build =="
if ! command -v hugo >/dev/null 2>&1; then
  err "hugo not found in PATH"
  exit 1
fi
if ! hugo --minify; then
  err "hugo build failed"
  exit 1
fi

# ---------- Step 4: Verify ----------
verify_fail=0

log "== Verify: /scripts/ section index =="
if [[ -f public/scripts/index.html ]]; then
  log "PASS: public/scripts/index.html exists"
else
  warn "FAIL: public/scripts/index.html missing"
  verify_fail=$((verify_fail+1))
fi

log "== Verify: known script pages (if present) =="
for p in example-script install-dependencies; do
  if [[ -f "content/scripts/${p}.md" ]]; then
    if [[ -f "public/scripts/${p}/index.html" ]]; then
      log "PASS: public/scripts/${p}/index.html present"
    else
      warn "FAIL: expected public/scripts/${p}/index.html missing"
      verify_fail=$((verify_fail+1))
    fi
  else
    info "SKIP: content/scripts/${p}.md not present"
  fi
done

log "== Verify: exit routes to /scripts/ on rendered homepage =="
if grep -q "window.location = '/scripts/'" public/index.html; then
  log "PASS: homepage JS routes exit to /scripts/"
elif grep -qE "window\.location = ['\"][^'\"]*/scripts/['\"]" public/index.html; then
  log "PASS: homepage JS routes exit to a /scripts/ URL"
else
  warn "FAIL: could not confirm exit routing to /scripts/ in public/index.html"
  verify_fail=$((verify_fail+1))
fi

if (( verify_fail > 0 )); then
  err "RESULT: FAIL (${verify_fail} verification issue(s)). See messages above."
  exit 1
else
  log "RESULT: PASS (all checks OK)"
  log "Open locally: http://localhost:1313/scripts/  (or run: hugo server -D)"
  exit 0
fi
