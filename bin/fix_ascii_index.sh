#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

DRY=0
PUSH=0
[[ "${1:-}" == "--dry-run" ]] && DRY=1
[[ "${1:-}" == "--push" ]] && PUSH=1

patch_file() {
  local f="$1"
  if [[ -f "$f" ]]; then
    echo "Patching $f …"
    if [[ $DRY -eq 1 ]]; then
      # Show a preview of what would change
      sed -E -f - "$f" <<'SED' | diff -u "$f" - || true
s~(href=["'"])/4ndr0site/scripts/(["'"])~\1{{ "/scripts/" | relURL }}\2~g
s~(href=["'"])/scripts/(["'"])~\1{{ "/scripts/" | relURL }}\2~g
s~\{\{[[:space:]]*"/?scripts/"[[:space:]]*\|[[:space:]]*absURL[[:space:]]*\}\}~{{ "/scripts/" | relURL }}~g
SED
    else
      # Apply in-place using a safe delimiter (~)
      sed -E -i -f /dev/stdin "$f" <<'SED'
s~(href=["'"])/4ndr0site/scripts/(["'"])~\1{{ "/scripts/" | relURL }}\2~g
s~(href=["'"])/scripts/(["'"])~\1{{ "/scripts/" | relURL }}\2~g
s~\{\{[[:space:]]*"/?scripts/"[[:space:]]*\|[[:space:]]*absURL[[:space:]]*\}\}~{{ "/scripts/" | relURL }}~g
SED
    fi
  else
    echo "WARN: $f not found, skipping."
  fi
}

patch_file "static/ascii-index.html"
patch_file "themes/4ndr0line/layouts/ascii-index.html"

if [[ $DRY -eq 1 ]]; then
  echo "Dry run complete."
  exit 0
fi

git add -N static/ascii-index.html themes/4ndr0line/layouts/ascii-index.html >/dev/null 2>&1 || true
if ! git diff --quiet -- static/ascii-index.html themes/4ndr0line/layouts/ascii-index.html; then
  git add static/ascii-index.html themes/4ndr0line/layouts/ascii-index.html
  git commit -m "fix(ascii-index): normalize /scripts/ links to {{ \"/scripts/\" | relURL }}"
  [[ $PUSH -eq 1 ]] && git push
else
  echo "No changes to commit."
fi
