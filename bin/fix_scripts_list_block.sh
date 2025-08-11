#!/usr/bin/env bash
# File: bin/fix_scripts_list_block.sh
# Purpose: Ensure /scripts/ section uses {{ define "body" }}, list pages recursively,
#          build, smoke-check, conditionally commit+push, and optional live verify.
#
# ENV:
#   VERIFY_LIVE=1   # to poll the live site after push
#   BASE_URL="https://4ndr0666.github.io/4ndr0site"

set -Eeuo pipefail
IFS=$'\n\t'
trap 'printf "ERROR: line %s failed\n" "$LINENO" >&2' ERR

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

LIST="layouts/scripts/list.html"
mkdir -p "$(dirname "$LIST")"

cat > "$LIST" <<'HUGO'
{{ define "body" }}
<main class="container" style="max-width:60rem;margin:0 auto;padding:2rem 1rem;">
  <header style="margin-bottom:1.5rem;">
    <h1 style="margin:0 0 .25rem 0;">{{ .Title }}</h1>
    {{ with .Params.description }}<p style="margin:.25rem 0 0 0;opacity:.85;">{{ . }}</p>{{ end }}
  </header>

  {{ $pages := .RegularPagesRecursive }}
  {{ if not $pages }}{{ $pages = .Pages }}{{ end }}

  <section aria-labelledby="scripts-list" style="margin-top:1rem;">
    <h2 id="scripts-list" style="font-size:1.25rem;margin:0 0 .75rem 0;">Scripts</h2>
    {{ if $pages }}
      <ul style="list-style:none;padding:0;margin:0;">
        {{ range $pages.ByDate.Reverse }}
          <li style="margin:0 0 .75rem 0;">
            <a href="{{ .RelPermalink }}" style="text-decoration:none;"><strong>{{ .Title }}</strong></a>
            {{ with .Date }}<small style="opacity:.7;"> — {{ .Format "2006-01-02" }}</small>{{ end }}
            {{ with .Summary }}<div style="opacity:.85;margin-top:.25rem;">{{ . }}</div>{{ end }}
          </li>
        {{ end }}
      </ul>
    {{ else }}
      <p>No published entries yet.</p>
    {{ end }}
  </section>

  <section style="margin-top:2rem;">
    <h2 style="font-size:1.25rem;margin:0 0 .5rem 0;">Static Assets</h2>
    <p style="margin:0;">Place raw files in <code>static/scripts/</code> to serve them at <code>{{ "/scripts/" | relURL }}</code>.</p>
  </section>
</main>
{{ end }}
HUGO

echo "== Build =="
hugo --minify

echo "== Smoke check =="
if grep -q '<li' public/scripts/index.html; then
  echo "PASS: list items found"
else
  echo "FAIL: still no list items"; sed -n '1,80p' public/scripts/index.html; exit 1
fi

echo "== Commit & push (if changed) =="
if git diff --quiet -- "$LIST"; then
  echo "INFO: no changes to commit."
else
  git add "$LIST"
  git commit -m 'fix(scripts): use {{ define "body" }}; list pages recursively'
  git push origin "$(git rev-parse --abbrev-ref HEAD)"
fi

# Optional live verify
if [[ "${VERIFY_LIVE:-0}" == "1" ]]; then
  BASE_URL="${BASE_URL:-https://4ndr0666.github.io/4ndr0site}"
  echo "== Poll live =="
  end=$(( $(date +%s) + 180 ))
  pass=0
  while (( $(date +%s) < end )); do
    if curl -fsSL "$BASE_URL/scripts/" -o /tmp/live-scripts.html; then
      if grep -q '<li' /tmp/live-scripts.html; then
        echo "PASS: live list detected"
        pass=1
        break
      fi
    fi
    printf "."; sleep 5
  done
  echo
  for p in example-script install-dependencies; do
    code=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/scripts/$p/")
    echo "$code  $BASE_URL/scripts/$p/"
  done
  (( pass == 1 )) || { echo "WARN: live list not detected yet"; exit 0; }
fi

echo "DONE."
