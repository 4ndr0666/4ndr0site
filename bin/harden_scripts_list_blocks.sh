#!/usr/bin/env bash
# File: bin/harden_scripts_list_blocks.sh
# Purpose: Make the /scripts/ section render under both {{ define "body" }} and {{ define "main" }},
#          rebuild, conditionally commit+push, and verify live anchors.
set -Eeuo pipefail
IFS=$'\n\t'
trap 'printf "ERROR: line %s failed\n" "$LINENO" >&2' ERR

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

LIST="layouts/scripts/list.html"
mkdir -p "$(dirname "$LIST")"

# Single source of truth for the section markup
read -r -d '' CONTENT <<'HUGO' || true
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
            <a href="{{ .Permalink }}" style="text-decoration:none;"><strong>{{ .Title }}</strong></a>
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
HUGO

# Write a template that defines BOTH blocks, using the same content
cat > "$LIST" <<HUGO
{{ define "body" }}
$CONTENT
{{ end }}

{{ define "main" }}
$CONTENT
{{ end }}
HUGO

echo "== Build =="
hugo --minify

echo "== Local smoke =="
if grep -q '<a href=' public/scripts/index.html || grep -q '<a href=' <(sed 's/"/\x22/g' public/scripts/index.html); then
  echo "PASS: anchors present locally"
else
  echo "FAIL: no anchors found locally"; sed -n '1,120p' public/scripts/index.html; exit 1
fi

echo "== Commit & push (if changed) =="
if git diff --quiet -- "$LIST"; then
  echo "INFO: no changes to commit."
else
  git add "$LIST"
  git commit -m 'fix(scripts): render under both "body" and "main" blocks; absolute anchors'
  git push origin "$(git rev-parse --abbrev-ref HEAD)"
fi

# Live verify
BASE_URL="${BASE_URL:-https://4ndr0666.github.io/4ndr0site}"
echo "== Poll live for anchors =="
end=$(( $(date +%s) + 240 ))
ok=0
while (( $(date +%s) < end )); do
  if curl -fsSL "$BASE_URL/scripts/" -o /tmp/live-scripts.html; then
    # Match quoted or unquoted href attributes
    if awk 'BEGIN{IGNORECASE=1}
      { while (match($0, /href=("|'\''|)[^ >"'\''#]+/, m)) { print m[0]; $0=substr($0, RSTART+RLENGTH) } }
    ' /tmp/live-scripts.html | grep -qi '/scripts/'; then
      echo "PASS: live anchors detected"
      ok=1
      break
    fi
  fi
  printf "."; sleep 5
done
echo

if (( ok == 0 )); then
  echo "WARN: live anchors not detected yet; dumping first 2000 chars:"
  head -c 2000 /tmp/live-scripts.html || true; echo
fi

echo "== Probe child pages =="
for p in example-script install-dependencies; do
  url="$BASE_URL/scripts/$p/"
  code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  echo "$code  $url"
done

echo "DONE."
