---
title: "{{ replace .Name "-" " " | title }}"
date: {{ .Date }}
url: /snippets/{{ .Name }}/
image: images/snippets/{{ .Name }}.jpg
categories:
  - Snippets
tags:
  - Python
  - Code
draft: true
---

## {{ replace .Name "-" " " | title }}

```python
# Python code snippet example
def example_function():
    return "Hello, world!"
```

<!--more-->
