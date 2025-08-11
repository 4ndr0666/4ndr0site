# File: bin/normalize_pages_workflow.sh
#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

mkdir -p .github/workflows

# Disable any other Pages/Hugo workflows to avoid race/overwrites
for f in .github/workflows/*.yml .github/workflows/*.yaml; do
  [[ -e "$f" ]] || continue
  case "$f" in
    *.pages.yml|*pages.yaml) continue;;
    *)
      if grep -Eq 'configure-pages|upload-pages-artifact|deploy-pages|hugo' "$f"; then
        mv -f "$f" "$f.disabled"
        echo "DISABLED: $f -> $f.disabled"
      fi
    ;;
  esac
done

# Canonical workflow (Hugo 0.148.x compatible, single pipeline)
cat > .github/workflows/pages.yml <<'YAML'
name: Build and Deploy to GitHub Pages

on:
  push:
    branches: [ main ]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-24.04
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          submodules: recursive

      - name: Setup Pages
        id: pages
        uses: actions/configure-pages@v5

      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v3
        with:
          hugo-version: "0.148.2"
          extended: true

      - name: Build with Hugo (minified, prod)
        env:
          HUGO_ENV: production
        run: |
          rm -rf public
          hugo --minify --gc --baseURL "${{ steps.pages.outputs.base_url }}/"
          echo "== Artifact contents =="
          find public -maxdepth 3 -type f -name 'index.html' -print | sort
          test -f public/.nojekyll || : > public/.nojekyll
          echo "== Sanity check =="
          test -f public/scripts/index.html
          test -f public/scripts/example-script/index.html
          test -f public/scripts/install-dependencies/index.html

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: ./public

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-24.04
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
YAML

git add .github/workflows/pages.yml .github/workflows/*.disabled || true
git commit -m "ci: consolidate Pages workflow; ensure child pages and .nojekyll in artifact" || true
git push origin main

echo "Pushed. Watch the workflow logs: it will print the artifact file list and assert the three files exist."
