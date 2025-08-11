# File: bin/fix_pages_child_404.sh
#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

BASE_URL="${BASE_URL:-https://4ndr0666.github.io/4ndr0site}"
BRANCH="${BRANCH:-$(git rev-parse --abbrev-ref HEAD)}"

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

echo "== Ensure .nojekyll will be deployed =="
mkdir -p static
if [[ ! -f static/.nojekyll ]]; then
  : > static/.nojekyll
  echo "CREATED: static/.nojekyll"
else
  echo "OK: static/.nojekyll present"
fi

echo "== Build =="
hugo --minify

echo "== Check local outputs =="
for p in \
  "scripts/index.html" \
  "scripts/example-script/index.html" \
  "scripts/install-dependencies/index.html" \
  ".nojekyll"
do
  if [[ -f "public/$p" ]]; then
    echo "PASS: public/$p"
  else
    echo "MISS: public/$p"
  fi
done

echo "== Commit & push (if needed) =="
if ! git diff --quiet -- static/.nojekyll; then
  git add static/.nojekyll
  git commit -m "pages: add .nojekyll to ensure nested pages are served"
  git push origin "$BRANCH"
else
  echo "INFO: no changes to commit."
fi

echo "== Poll live until updated =="
end=$(( $(date +%s) + 180 ))
updated=0
while (( $(date +%s) < end )); do
  curl -fsSL "$BASE_URL/scripts/" -o /tmp/live-scripts.html && updated=1 && break || true
  sleep 5
done
(( updated )) || { echo "ERR: couldn’t fetch live /scripts/"; exit 1; }

echo "== Extract live links =="
awk 'BEGIN{IGNORECASE=1}
     /href=/{while (match($0, /href="([^"]+)"/, m)) {print m[1]; $0=substr($0, RSTART+RLENGTH)} }' \
  /tmp/live-scripts.html \
| sed -E "s#^/+#$BASE_URL/#; s#^scripts/#$BASE_URL/scripts/#" \
| awk '!seen[$0]++' | tee /tmp/live-script-links.txt

echo "== Verify each live link =="
while read -r url; do
  [[ -n "$url" ]] || continue
  code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  echo "$code  $url"
done < /tmp/live-script-links.txt

echo "DONE."
