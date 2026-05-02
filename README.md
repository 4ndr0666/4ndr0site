# 4NDR0666OS // AKASHA DIRECTIVE: SYSTEM OPERATOR MANUAL

![System Status](https://img.shields.io/badge/STATUS-OPERATIONAL-00E5FF?style=for-the-badge&logo=hugo&logoColor=00E5FF&labelColor=050A0F)
![UI Matrix](https://img.shields.io/badge/UI_MATRIX-3LECTRIC__GLASS-00E5FF?style=for-the-badge&labelColor=050A0F)
![Framework](https://img.shields.io/badge/FRAMEWORK-HUGO_EXTENDED-00E5FF?style=for-the-badge&labelColor=050A0F)

Welcome to the central repository and operational matrix for the **4NDR0666OS Website (Akasha)**. This document serves as the comprehensive Operator Manual for initializing, developing, managing, and deploying payloads to the live production environment. 

This architecture utilizes a heavily modified instance of the Hugo static site generator, completely overhauled to adhere to the **3LECTRIC_GLASS v1.5.0-Ψ** cyberpunk aesthetic specification. The DOM has been weaponized; legacy Bootstrap classes have been purged or overridden, and the CSS variables operate on a strict cyan-and-obsidian color space.

---

## TABLE OF CONTENTS

1. [Architectural Overview](#1-architectural-overview)
2. [Environment Initialization](#2-environment-initialization)
3. [The 3LECTRIC_GLASS UI Specification](#3-the-3lectric_glass-ui-specification)
4. [Payload Deployment (Content Workflow)](#4-payload-deployment-content-workflow)
5. [Frontmatter Metadata Matrix](#5-frontmatter-metadata-matrix)
6. [Custom HUD Components (Shortcodes)](#6-custom-hud-components-shortcodes)
7. [System Layouts & Grid Topology](#7-system-layouts--grid-topology)
8. [SCSS Compilation & Style Overrides](#8-scss-compilation--style-overrides)
9. [Performance & Mobile Contingencies](#9-performance--mobile-contingencies)
10. [Version Control & Deployment Pipeline](#10-version-control--deployment-pipeline)
11. [Troubleshooting & Anomaly Resolution](#11-troubleshooting--anomaly-resolution)

---

## 1. ARCHITECTURAL OVERVIEW

The codebase is structured around a highly optimized Hugo directory tree. Understanding this topology is critical for executing modifications without triggering structural collapse.

```text
/dev/akasha/
├── archetypes/         # Templates for new markdown payloads (default.md)
├── assets/             # THE KERNEL: Raw SCSS, JS, and compiled pipelines
│   ├── css/            # Vendor CSS (Bootstrap)
│   ├── js/             # Interactive logic: code-copy.js (Moved from static), theme.js
│   └── scss/           # THE BEATING HEART: Compressed 3LECTRIC_GLASS styling
├── content/            # THE DATABASE: Raw Markdown payloads categorized by sector
│   ├── posts/          # Primary entry streams (Refactored from /blog/)
│   ├── categories/     # SECTOR taxonomy nodes
│   └── tags/           # DATA_TAG sub-taxonomy nodes
├── data/               # YAML/JSON data files
├── layouts/            # HTML templates dictating the structural DOM grid
│   ├── _default/       # Primary templates (single.html, list.html)
│   ├── partials/       # HUD Fragments (header, footer, widgets)
│   └── shortcodes/     # Inline markdown components (box, quote, collapse)
├── static/             # Binary assets served directly (images, fonts, bypass-regs)
│   └── images/         # High-priority visual assets
├── config.toml         # Primary Hugo configuration and global variables
└── README.md           # You are here.
```

---

## 2. ENVIRONMENT INITIALIZATION

To operate on this environment locally, your workstation must meet the following prerequisites.

### Prerequisites
* **Hugo Extended Version:** (v0.110.0 or higher). The *Extended* version is strictly required because this project compiles raw SCSS into CSS locally via LibSass/Dart Sass.
* **Git:** For version control and pushing payloads to the remote server.
* **Node.js (Optional but Recommended):** For handling advanced PostCSS pipelines if added in the future.

### Local Deployment Sequence

1. **Clone the Matrix:**
   ```bash
   git clone https://github.com/4ndr0666/4ndr0site.git
   cd 4ndr0site
   ```

2. **Initialize Submodules (If Applicable):**
   ```bash
   git submodule update --init --recursive
   ```

3. **Engage Local Development Server:**
   Execute the following command to spin up the local Hugo server with drafts enabled and live-reload active.
   ```bash
   hugo server -D --disableFastRender
   ```
   *Note: `--disableFastRender` is often necessary when making deep SCSS architectural changes to ensure the full pipeline recompiles on every save.*

4. **Access the Interface:**
   Navigate to `http://localhost:1313/` in your local browser.

---

## 3. THE 3LECTRIC_GLASS UI SPECIFICATION

The entire visual identity of this project is governed by the `3LECTRIC_GLASS_SPEC`. Do not attempt to hardcode hex colors in random files. All color and structural logic must map back to the global CSS variables defined in `assets/scss/style.scss` and `layouts/partials/style.html`.

### The Global Variable Registry

```css
:root {
  /* Foundations */
  --bg-dark-base: #050A0F;                  /* Deep obsidian base */
  --bg-glass-panel: rgba(10, 19, 26, 0.25); /* Translucent glass logic */
  --bg-glass-dense: rgba(10, 19, 26, 0.85); /* Frost-shield for text collision prevention */
  
  /* The Cyan Matrix */
  --accent-cyan: #00E5FF;                   /* Base UI lines */
  --text-cyan-active: #67E8F9;              /* High-contrast text */
  --accent-cyan-border-idle: rgba(0, 229, 255, 0.2);
  --accent-cyan-border-hover: rgba(0, 229, 255, 0.6);
  --accent-cyan-bg-hover: rgba(0, 229, 255, 0.1);
  --accent-cyan-bg-active: rgba(0, 229, 255, 0.2);
  --glow-cyan-active: rgba(0, 229, 255, 0.5);
  
  /* Typography */
  --primary_font: 'Roboto Mono', monospace;
}
```

### Core Design Philosophies
1. **No Opaque Blocks:** Never use solid backgrounds for content cards. Always utilize `var(--bg-glass-panel)` coupled with `backdrop-filter: blur(12px)`.
2. **Glowing Interactive States:** All hover, focus, and active states must trigger a cyan `box-shadow` glow via the `@include glow` or `@include box-glow` mixins.
3. **Monospace Dominance:** The layout relies on fluid typography via `clamp()` to maintain a terminal interface aesthetic across all viewports.

---

## 4. PAYLOAD DEPLOYMENT (CONTENT WORKFLOW)

Writing content in Hugo relies on Markdown (`.md`) files injected into the `/content/` directory.

### Generating a New Node
To create a new blog post or data payload, use the Hugo CLI. This ensures the file is created with the correct timestamp and frontmatter based on `/archetypes/default.md`.

```bash
hugo new posts/my-new-payload.md
```

### Structuring Your Payload
Open the generated file. You will see a block of YAML or TOML at the top, bordered by `---`. This is the **Frontmatter**. Below the frontmatter is where your standard Markdown content goes.

```markdown
---
title: "Advanced Matrix Infiltration Techniques"
date: 2026-04-08T19:00:00-05:00
draft: true
image: "/images/infiltration-banner.jpg"
categories: ["CYBERSEC", "TUTORIAL"]
tags: ["nmap", "proxychains", "opsec"]
---

## Initialization

Begin the standard deployment sequence. The text here will automatically be parsed by Hugo, wrapped in the `.4ndr0-content` container, and rendered with the proper cyan fonts and spacing.

### Code Blocks
Fenced code blocks are natively supported and include a floating [ COPY ] HUD trigger powered by the `code-copy.js` pipeline.

```bash
sudo nmap -sS -p- 192.168.1.1
```
```

---

## 5. FRONTMATTER METADATA MATRIX

The metadata defined in your payload's frontmatter directly controls how the `single.html` layout renders the HUD.

| Variable | Type | Description |
| :--- | :--- | :--- |
| `title` | String | The main H1 title. Rendered uppercase with a cyan text-shadow. |
| `date` | Datetime | Rendered in the UI as the `TIMESTAMP`. |
| `draft` | Boolean | If `true`, the post will not compile in production. |
| `image` | String | URL to banner. Rendered with a cyan border and **Autonomous Fallback** to `4ndr0arch.png` if missing. |
| `categories` | Array | Taxonomy nodes displayed in the HUD as **SECTORS**. |
| `tags` | Array | Taxonomy nodes displayed in the HUD as **DATA_TAGS**. |

---

## 6. CUSTOM HUD COMPONENTS (SHORTCODES)

To inject advanced UI components into payloads, use Hugo Shortcodes located in `layouts/shortcodes/`.

### A. The System Box (`box.html`)
**Usage:** `{{< box >}} Content {{< /box >}}`
**Behavior:** Creates a `.4ndr0-sys-box` glass container with an interactive hover glow.

### B. The Decrypt Envelope (`collapse.html`)
**Usage:** `{{< collapse "Title" >}} Secret Data {{< /collapse >}}`
**Behavior:** Generates an expandable `4ndr0-envelope` with a cubic-bezier slide reveal.

### C. System Insight Quote (`quote.html`)
**Usage:** `{{< quote by="4NDR0666" >}} Text {{< /quote >}}`
**Behavior:** Renders a heavy left-bordered `.cortex-insight` panel that translates `5px` on hover.

### D. Youtube Telemetry (`youtube.html`)
**Usage:** `{{< youtube id="ID" >}}`
**Behavior:** Injects a sanitized 16:9 iframe wrapped in a HUD border with no external branding.

---

## 7. SYSTEM LAYOUTS & GRID TOPOLOGY

### `layouts/_default/single.html` (Payload Renderer)
* **Sidebar Dominance:** Regardless of configuration, sidebars are forced to `order-lg-1` (left) to eliminate viewport collisions.
* **Asset Resilience:** Images utilize an `onerror` protocol to autonomously revert to the canonical site logo if a visual asset is unreachable.

### `layouts/_default/list.html` (Stream Renderer)
* **HUD Sanitization:** Article previews utilize `.Plain` sanitization to prevent shortcode bleed and DOM hijacking.

---

## 8. SCSS COMPILATION & STYLE OVERRIDES

Styles are compiled from `assets/scss/`. The **Superset Protocol** refactor (Step 163-172) collapsed the legacy code-base into a high-performance variable-mapped unit.

### The Override Strategy
* **The Bridge Block:** `style.scss` contains a mandatory bridge mapping Hugo Params to SCSS variables (`$primary-color`, etc.) to maintain backward compatibility with legacy modules.
* **Component-First Logic:** Typography and buttons are mapped directly to CSS variables to enable real-time theme switching and glow-states.

---

## 9. PERFORMANCE & MOBILE CONTINGENCIES

* **Content Visibility:** Tables and code blocks utilize `content-visibility: auto` to reduce TTI.
* **Mobile Glassmorphism:** Mobile viewports include specific `backdrop-filter` overrides in `header.html` to ensure menu legibility on low-powered devices.
* **Asset Pipeline:** All JS logic (`bootstrap`, `theme`, `code-copy`) is concatenated, minified, and fingerprinted in the footer.

---

## 10. VERSION CONTROL & DEPLOYMENT PIPELINE

### The Standard Deployment Sequence
1. **Verify local build:** `hugo server`
2. **Undraft payload:** `draft: false`
3. **Stage & Commit:**
   ```bash
   git add -A
   git commit -m "content(payload): deploy advanced telemetry log"
   ```
4. **Push to Matrix:** `git push origin main`

### GitHub Actions
Pushing to `main` triggers a GitHub Action that executes `hugo --minify` and deploys the static matrix to `https://4ndr0666.github.io/4ndr0site/`.

---

## 11. TROUBLESHOOTING & ANOMALY RESOLUTION

**Anomaly 1: SCSS Fails to Compile.**
* **Cause:** Missing bridge variables in `style.scss` or syntax errors in `_common.scss`.
* **Fix:** Verify the bridge block in `style.scss` is correctly mapping all mandatory $variables.

**Anomaly 2: Code Copy Button Invisible.**
* **Cause:** `code-copy.js` missing from the footer asset pipeline or located in `static/`.
* **Fix:** Ensure the file is in `assets/js/` and the footer slice includes `$codeCopy`.

**Anomaly 3: Taxonomy Node Missing.**
* **Cause:** Labels "Categories" or "Tags" were used instead of "Sectors" or "Data_Tags".
* **Fix:** Check `widget-wrapper.html` and individual widget partials for naming consistency.

---

Copyright © 2026 4ndr0666
