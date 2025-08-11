#!/usr/bin/env bash
# File: bin/wire_scripts_and_deploy.sh
# Purpose: Wire the /scripts/ section, patch "exit" to route there, build, verify,
#          commit, push, and optionally verify the live Pages deployment.
#
# ENV:
#   EXIT_TARGET  - JS target for exit (default: {{ "/scripts/" | relURL }})
#   BRANCH       - git branch to push (auto-detected)
#   BASE_URL     - live site base for verify (default: https://4ndr0666.github.io/4ndr0site)
#   VERIFY_LIVE  - 1 to verify live after push (default: 0)
#   POLL_SECS    - live-verify window (default: 90)
#
set -Eeuo pipefail
IFS=$'\n\t'
trap 'printf "ERROR: line %s failed\n" "$LINENO" >&2' ERR

log()  { printf '%s\n' "$*"; }
info() { printf 'INFO: %s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
err()  { printf 'ERROR: %s\n' "$*" >&2; }

# --- repo root detection ---
resolve_repo_root() {
  if command -v git >/dev/null 2>&1 && git rev-parse --show-toplevel >/dev/null 2>&1; then
    git rev-parse --show-toplevel
    return
  fi
  local d="$PWD"
  while [[ "$d" != "/" ]]; do
    if [[ -f "$d/config.yml" && -d "$d/static" ]]; then
      echo "$d"; return
    fi
    d="$(dirname "$d")"
  done
  echo ""
}

ROOT="$(resolve_repo_root)"
[[ -n "$ROOT" ]] || { err "Could not locate repo root (needs config.yml and static/)."; exit 1; }
cd "$ROOT"
info "Repo root: $ROOT"

# --- config ---
EXIT_TARGET_DEFAULT='{{ "/scripts/" | relURL }}'
EXIT_TARGET="${EXIT_TARGET:-$EXIT_TARGET_DEFAULT}"
LIST_TPL="layouts/scripts/list.html"
INDEX_TPL="layouts/index.html"
ASCII_STATIC="static/ascii-index.html"
BACKUP_TAG=".bak.$(date +%s)"
BRANCH="${BRANCH:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)}"
BASE_URL="${BASE_URL:-https://4ndr0666.github.io/4ndr0site}"
VERIFY_LIVE="${VERIFY_LIVE:-0}"
POLL_SECS="${POLL_SECS:-90}"

# --- prechecks ---
[[ -f config.yml ]]               || { err "Missing config.yml"; exit 1; }
[[ -d layouts ]]                  || { err "Missing layouts/"; exit 1; }
[[ -f "$INDEX_TPL" ]]             || { err "Missing $INDEX_TPL"; exit 1; }
command -v hugo >/dev/null 2>&1   || { err "hugo not found in PATH"; exit 1; }
command -v git  >/dev/null 2>&1   || { err "git not found in PATH"; exit 1; }

mkdir -p "$(dirname "$LIST_TPL")"

# --- Step 1: ensure section list template (fixed heredoc handling) ---
DESIRED_LIST_TPL="$(cat <<'HUGO'
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
              <strong>{{ .Title }}</strong>
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
)"

if [[ -f "$LIST_TPL" ]]; then
  if ! diff -q <(printf "%s" "$DESIRED_LIST_TPL") "$LIST_TPL" >/dev/null 2>&1; then
    cp -f "$LIST_TPL" "$LIST_TPL$BACKUP_TAG"
    printf "%s" "$DESIRED_LIST_TPL" > "$LIST_TPL"
    log "UPDATED: $LIST_TPL (backup: $LIST_TPL$BACKUP_TAG)"
  else
    info "OK: $LIST_TPL up to date"
  fi
else
  printf "%s" "$DESIRED_LIST_TPL" > "$LIST_TPL"
  log "CREATED: $LIST_TPL"
fi

# --- Step 2: patch 'exit' in layouts/index.html ---
TMP="$(mktemp)"
awk -v target="$EXIT_TARGET" '
  BEGIN { in_exit=0 }
  /^\s*case[[:space:]]+'\''exit'\'':\s*$/ { in_exit=1; print; next }
  in_exit==1 && /window\.location[[:space:]]*=/ {
    print "                setTimeout(function(){window.location = " target "}, 2000);"
    next
  }
  in_exit==1 && /^\s*break;\s*$/ { in_exit=0; print; next }
  { print }
' "$INDEX_TPL" > "$TMP"

if ! diff -q "$TMP" "$INDEX_TPL" >/dev/null 2>&1; then
  cp -f "$INDEX_TPL" "$INDEX_TPL$BACKUP_TAG"
  mv "$TMP" "$INDEX_TPL"
  log "UPDATED: $INDEX_TPL (backup: $INDEX_TPL$BACKUP_TAG)"
else
  rm -f "$TMP"
  info "OK: $INDEX_TPL already routes exit"
fi

# --- Step 3: ensure ASCII page links to /scripts/ (if exists) ---
if [[ -f "$ASCII_STATIC" ]]; then
  if ! grep -qE 'href="/scripts/"' "$ASCII_STATIC"; then
    tmp2="$(mktemp)"
    if grep -qi '</body>' "$ASCII_STATIC"; then
      awk '
        BEGIN{done=0; IGNORECASE=1}
        /<\/body>/ && !done { print "<p style=\"margin-top:1rem;\"><a href=\"/scripts/\">Scripts</a></p>"; print; done=1; next }
        { print }
        END{ if(!done) print "<p style=\"margin-top:1rem;\"><a href=\"/scripts/\">Scripts</a></p>" }
      ' "$ASCII_STATIC" > "$tmp2"
    else
      cat "$ASCII_STATIC" > "$tmp2"
      printf "\n<p style=\"margin-top:1rem;\"><a href=\"/scripts/\">Scripts</a></p>\n" >> "$tmp2"
    fi
    cp -f "$ASCII_STATIC" "$ASCII_STATIC$BACKUP_TAG"
    mv "$tmp2" "$ASCII_STATIC"
    log "UPDATED: $ASCII_STATIC (added hard link to /scripts/)"
  else
    info "OK: $ASCII_STATIC already links to /scripts/"
  fi
else
  info "SKIP: $ASCII_STATIC not found"
fi

# --- Step 4: build ---
log "== Build =="
hugo --minify

# --- Step 5: local verify ---
fail=0
log "== Verify: /scripts/ index =="
[[ -f public/scripts/index.html ]] && log "PASS: public/scripts/index.html" || { warn "FAIL: missing public/scripts/index.html"; fail=$((fail+1)); }

log "== Verify: known pages (if present) =="
for p in example-script install-dependencies; do
  if [[ -f "content/scripts/${p}.md" ]]; then
    [[ -f "public/scripts/${p}/index.html" ]] && log "PASS: public/scripts/${p}/index.html" || { warn "FAIL: missing public/scripts/${p}/index.html"; fail=$((fail+1)); }
  else
    info "SKIP: content/scripts/${p}.md not present"
  fi
done

log "== Verify: exit routes to /scripts/ on rendered homepage =="
if grep -qE 'window\.location[[:space:]]*=[[:space:]]*["'\''][^"'\''"]*/scripts/["'\'']' public/index.html; then
  log "PASS: homepage exit routes to /scripts/"
else
  warn "FAIL: could not confirm exit routing to /scripts/ in public/index.html"
  fail=$((fail+1))
fi

(( fail == 0 )) || { err "Local verify failed (${fail} issue[s])."; exit 1; }
log "Local verify: PASS"

# --- Step 6: commit & push ---
git add -N "$LIST_TPL" "$INDEX_TPL" "$ASCII_STATIC" >/dev/null 2>&1 || true
changed=$(git status --porcelain | awk 'NF{print}' | wc -l | tr -d ' ')
if (( changed == 0 )); then
  info "No changes to commit."
else
  git add "$LIST_TPL" "$INDEX_TPL" || true
  [[ -f "$ASCII_STATIC" ]] && git add "$ASCII_STATIC" || true
  git add content/scripts/_index.md 2>/dev/null || true
  git add content/scripts/example-script.md 2>/dev/null || true
  git add content/scripts/install-dependencies.md 2>/dev/null || true
  git commit -m "Route 'exit' to /scripts/; add /scripts/ section list; ensure ASCII links to /scripts/"
  info "Committed."
  info "Pushing to origin/${BRANCH}…"
  git push origin "$BRANCH"
  log "Push done."
fi

# --- Step 7: optional live verify ---
if [[ "${VERIFY_LIVE:-0}" != "1" ]]; then
  info "Live verify skipped (set VERIFY_LIVE=1 to enable)."
  exit 0
fi

log "== Live verify (${BASE_URL}) =="
end=$(( $(date +%s) + POLL_SECS ))
live_ok=0
while (( $(date +%s) <= end )); do
  code_idx=$(curl -s -o /dev/null -w "%{http_code}" "${BASE_URL}/scripts/")
  code_ex1=$(curl -s -o /dev/null -w "%{http_code}" "${BASE_URL}/scripts/example-script/")
  code_ex2=$(curl -s -o /dev/null -w "%{http_code}" "${BASE_URL}/scripts/install-dependencies/")
  printf "HTTP %s /scripts/ | %s /scripts/example-script/ | %s /scripts/install-dependencies/\n" "$code_idx" "$code_ex1" "$code_ex2"
  if [[ "$code_idx" == "200" ]] && [[ "$code_ex1" =~ ^(200|404)$ ]] && [[ "$code_ex2" =~ ^(200|404)$ ]]; then
    live_ok=1; break
  fi
  sleep 5
done

if (( live_ok == 1 )); then
  log "Live verify: basic checks passed."
  if curl -sS "${BASE_URL}/ascii-index.html" -o /tmp/live-ascii.html; then
    if grep -q 'href="/scripts/' /tmp/live-ascii.html; then
      log "PASS: live ASCII links to /scripts/"
    else
      warn "WARN: could not confirm /scripts/ link on live ASCII page"
    fi
  fi
  exit 0
else
  err "Live verify timed out within ${POLL_SECS}s."
  exit 3
fi
