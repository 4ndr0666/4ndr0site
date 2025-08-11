# File: bin/debug_live_scripts.sh
#!/usr/bin/env bash
set -euo pipefail
BASE_URL="${BASE_URL:-https://4ndr0666.github.io/4ndr0site}"

echo "== Fetch live /scripts/ =="
curl -fsSL "$BASE_URL/scripts/" -o /tmp/live-scripts.html
echo "== Extract script links =="
# grab hrefs under /scripts/, normalize to absolute
awk 'BEGIN{IGNORECASE=1}
     /href=/{while (match($0, /href="([^"]+)"/, m)) {print m[1]; $0=substr($0, RSTART+RLENGTH)} }' \
    /tmp/live-scripts.html \
  | sed -E "s#^/+#$BASE_URL/#; s#^scripts/#$BASE_URL/scripts/#" \
  | awk '!seen[$0]++'

echo "== Test each link =="
awk 'BEGIN{IGNORECASE=1}
     /href=/{while (match($0, /href="([^"]+)"/, m)) {print m[1]; $0=substr($0, RSTART+RLENGTH)} }' \
    /tmp/live-scripts.html \
  | sed -E "s#^/+#$BASE_URL/#; s#^scripts/#$BASE_URL/scripts/#" \
  | awk '!seen[$0]++' |
while read -r url; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  echo "$code  $url"
done

echo "== Check ASCII has any /scripts/ link (base-aware) =="
curl -fsSL "$BASE_URL/ascii-index.html" -o /tmp/live-ascii.html || true
grep -Eo 'href="[^"]*scripts/?[^"]*"' /tmp/live-ascii.html || echo "No /scripts link found in ASCII (may be templated now)."
