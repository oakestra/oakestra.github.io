---
title: "Code Style Guide and Tools"
summary: "Oakestra code style guide and tools for maintaining high-quality, readable code"
draft: false
weight: 10402000000
toc: true
seo:
  title: "Oakestra code style guide" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

## High-Quality Code: A Shared Understanding

Spending additional time to write high-quality, readable code is crucial for success in software engineering. Clear and easily comprehensible code not only saves time during development but also simplifies onboarding and collaboration.

In case you are interested, we recommend the following reads for improving your code quality.
- [You Spend Much More Time Reading Code Than Writing Code](https://bayrhammer-klaus.medium.com/you-spend-much-more-time-reading-code-than-writing-code-bc953376fe19)
- [Google Python Style Guide: Block and Inline Comments](https://google.github.io/styleguide/pyguide.html#385-block-and-inline-comments)
- [Google Python Style Guide: Punctuation, Spelling, and Grammar](https://google.github.io/styleguide/pyguide.html#386-punctuation-spelling-and-grammar)

## Why Follow a Code Style Guide?

A shared code style ensures:
- Uniform and high-quality code that is easier to understand and maintain.
- Simplified onboarding for new team members.
- Fewer errors caused by inconsistencies.

To align with industry standards and avoid reinventing the wheel, we adhere to **PEP 8** ([Python Enhancement Proposal 8](https://peps.python.org/pep-0008/)).

## Linting & Formatting
We use [ruff](https://github.com/astral-sh/ruff) for Python linting and formatting.

Install ruff via `pip install ruff`.

Use `ruff format` and `ruff check --fix` to keep your code compliant.
