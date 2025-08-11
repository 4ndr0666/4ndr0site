# File: bin/force_redeploy_and_probe.sh
#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

BASE_URL="${BASE_URL:-https://4ndr0666.github.io/4ndr0site}"
BRANCH="${BRANCH:-$(git rev-parse --abbrev-ref HEAD)}"

echo "== Touch content to force rebuild =="
# bump lastmod safely (idempotent if already up-to-date)
for f in content/scripts/example-script.md content/scripts/install-dependencies.md content/scripts/_index.md; do
  [[ -f "$f" ]] && { printf '\nlastmod: %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$f"; echo "TOUCHED: $f"; }
done

echo "== Local build =="
hugo --minify

echo "== Assert built files exist locally =="
for p in "scripts/index.html" "scripts/example-script/index.html" "scripts/install-dependencies/index.html"; do
  [[ -f "public/$p" ]] && echo "PASS: public/$p" || { echo "FAIL: public/$p missing"; exit 1; }
done

echo "== Commit + push =="
git add content/scripts/*.md || true
git commit -m "chore: touch scripts content to force GH Pages rebuild" || echo "INFO: nothing to commit"
git push origin "$BRANCH"

echo "== Poll live until updated =="
deadline=$(( $(date +%s) + 180 ))
updated=0
while (( $(date +%s) < deadline )); do
  curl -fsSL "$BASE_URL/scripts/" -o /tmp/live-scripts.html || true
  # consider updated when page contains a link or a known title
  if grep -Eqo 'href="[^"]+/scripts/[^"]+/"' /tmp/live-scripts.html || \
     grep -Eq 'Example Script|Install Dependencies' /tmp/live-scripts.html; then
    updated=1; break
  fi
  printf "."
  sleep 5
done
echo

if (( updated == 0 )); then
  echo "WARN: live /scripts/ still shows no links; dumping first 40 lines for inspection:"
  sed -n '1,40p' /tmp/live-scripts.html || true
else
  echo "OK: live /scripts/ now shows links. Testing child pages:"
fi

for path in "scripts/example-script/" "scripts/install-dependencies/"; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/$path")
  echo "$code  $BASE_URL/$path"
done

echo "== Save full live /scripts/ for review =="
echo "Saved to: /tmp/live-scripts.html"
