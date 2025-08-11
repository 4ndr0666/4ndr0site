# File: bin/live_verify.sh
#!/usr/bin/env bash
set -u
IFS=$'\n\t'

BASE_URL="${BASE_URL:-https://4ndr0666.github.io/4ndr0site}"
POLL_SECS="${POLL_SECS:-90}"

command -v curl >/dev/null 2>&1 || { echo "ERROR: curl not found"; exit 1; }

end=$(( $(date +%s) + POLL_SECS ))
ok=0

echo "== Live verify ($BASE_URL) =="
while (( $(date +%s) <= end )); do
  code_idx=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/scripts/" || echo "000")
  code_ex1=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/scripts/example-script/" || echo "000")
  code_ex2=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/scripts/install-dependencies/" || echo "000")
  printf "HTTP %s /scripts/ | %s /scripts/example-script/ | %s /scripts/install-dependencies/\n" "$code_idx" "$code_ex1" "$code_ex2"

  if [[ "$code_idx" == "200" ]]; then ok=1; break; fi
  sleep 5
done

if (( ok )); then
  echo "Live verify: /scripts/ is up."
  curl -s "$BASE_URL/ascii-index.html" -o /tmp/live-ascii.html || true
  grep -q 'href="/scripts/' /tmp/live-ascii.html && echo "ASCII links to /scripts/ (found)" || echo "ASCII link not confirmed (OK if you templated it)."
  exit 0
else
  echo "Live verify: timed out (${POLL_SECS}s)."
  exit 1
fi
