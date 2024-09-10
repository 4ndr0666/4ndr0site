---
title: "{{ replace .Name "-" " " | title }}"
date: {{ .Date }}
url: /scripts/{{ .Name }}/
image: images/scripts/{{ .Name }}.jpg
categories:
  - Scripts
tags:
  - Bash
  - Shell
  - Linux
draft: true
---

## {{ replace .Name "-" " " | title }}

```bash
#!/bin/bash
# Your script content goes here
```

<!--more-->
