---
title: "Antigravity Serverless Expeditions"
date: 2026-01-17T01:56:54-05:00
url: /howtos/antigravity.md/
image: images/howtos/setup-nginx.jpg
categories:
  - Howtos
tags:
  - Tutorial
  - Howto
draft: false
---

# Antigravity Serverless Full-Stack Webapp

The following is a spec sheet for Antigravity to build a full-stack web app.

## Spec Sheet

"Act as a Senior Full Stack Developer. Build a web app called ""."

**The Goal:**
A WiFi QR Code generator that creates a printable "Guest Card" for visitors.

**The Stack:**
1. Backend: Typescrip with Express.
2. Frontend: A single `index.html` file served by Express from a `/public` folder.
3. Styling: Use Tailwind CSS via CDN.

**Core Requirements:**
1. User enters SSID and Password in a "Glassmorphism" styled form.
2. On submit, backend generates a QR code using the 'qrcode' library.
3. CRITICAL: Privacy first. These images contain sensitive passwords. DO NOT save files to the server disk. Generate the QR code in a memory (buffer) and return as a Base64 string.
4. Display the result in a printable card UI.

**Deployment (Modern Approach):**
*Use the `node:23` Docker base image.
*DO NOT include a build step (tsc).
*Run the application directly using the `--experiemental-strip-types` flag.



### Step 1

Describe the first step here.

## Step 2

Describe the second step here.

<!--more-->
