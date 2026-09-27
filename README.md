# Oakestra Documentation

This project includes ready-to-use development environments for DevContainer and CodeSandbox.

- **DevContainer:** open this repository in VS Code and select **Reopen in Container** (from the Command Palette or prompt).
- **CodeSandbox:** open `https://codesandbox.io/p/github/oakestra/documentation`.

## Dependencies

In order to build the webside you need to install:

- [`npm`](https://nodejs.org/en/download/package-manager)
- [`golang`](https://go.dev/doc/install)

then you can install all the project dependencies using

```
npm install
```

## How to test?

This repo is based on the GoHugo Doks theme. Follow the instructions [here](https://getdoks.org/docs/start-here/installation/#install-dependencies) to build it.

You can just serve a development version of your website locally using:

```
npm run dev
```

## How to format code?

This project uses [Prettier](https://prettier.io/) for consistent code formatting. Configuration is in `.prettierrc.yaml`.

Format all files:

```bash
npm run format
```

Check formatting without making changes:

```bash
npx prettier --check .
```

> **Note:** `npm run format` is a shortcut for `npx prettier **/** -w -c`. Both approaches work, but the npm script is the recommended way.

## How to build and test the production website locally?

Build and serve the production website using:

```
npm run build && npm run serve
```

Then reach the website at `http://localhost:8000` and test the build.
The website should look like the production one deployed at [oakestra.com](https://oakestra.com).

> **N.b.** While `npm run dev` is a good way to test your website during development, sometimes artifacts occur in the build process that are not present in the development website. For this reason, it is always a good idea to test the production build locally before deploying.

## Development Environments

This project supports multiple development environments:

### DevContainer (Recommended)

- Open in VS Code with Dev Containers extension
- Configuration: `.devcontainer/devcontainer.json`
- Hugo version: **v0.152.2**

### CodeSandbox

- Open at: `https://codesandbox.io/p/github/oakestra/documentation`
- Configuration: `.codesandbox/tasks.json`
- Hugo version: **v0.152.2** (installed automatically on setup)

## Weights Explained

Weights are necessary for the ordering shown in the left side bar as well as for the "Prev" and "Next" pages displayed at the bottom of every page.

Every page should have a weight - e.g:

```md
---
title: "High-Level Architecture"
summary: ""
draft: false
weight: 00102010000
toc: true
...
---
```

One can think about pages and their weights as nodes on a tree structure.
The following example helps you to visualize how we use weights:

```
- 📁 Getting Started                  | 00 01 00 00 00 00
    - 📄 Welcome to Oakestra ...      | 00 01 01 00 00 00
    - 📁 Create your first ...        | 00 01 02 00 00 00
        - 📄 High Level Setup ...     | 00 01 02 01 00 00
        - 📄 Create your first ...    | 00 01 02 02 00 00
- 📁 Concepts                         | 00 02 00 00 00 00
- 📁 Manuals                          | 00 03 00 00 00 00
    - ...
    - 📁 Federated Learning (FLOps)   | 00 03 07 00 00 00
        - 📄 FLOps Overview           | 00 03 07 01 00 00
        - 📄 FLOps API Endpoints      | 00 03 07 02 00 00
        - 📁 System Preparations      | 00 03 07 03 00 00
            - 📄 ... Overview         | 00 03 07 03 01 00
            - 📄 Prepare Image ...    | 00 03 07 03 02 00
        - 📁 FLOps Project Workflow   | 00 03 07 04 00 00
            - 📄 ... Overview         | 00 03 07 04 01 00
            - 📁 Project Stages       | 00 03 07 04 02 00
                - 📄 Stage 0 ...      | 00 03 07 04 02 01
                - 📄 ...
    - 📁 Debugging                    | 00 03 10 00 00 00
    - ...
- 📁 Contributng Guide                | 00 04 00 00 00 00
- 📁 Reference                        | 00 05 00 00 00 00
```

We are working with a maximum document/tree depth of 6
We are using 12 digits for the weight - 2 digits per depth level.
Thus every level can fit 100 documents.
(Why so many? -> Because 10 in one level is easily and already breached.)
Each digit pair from left to right represents how deep the respective page/folder is located in.
Each folder requires an `_index.md` file that contains its weight.

The first 2 digits are for the documentation version:

- Release | 00 ...
- alpha-v0.4.410 | 01 ...
- ...

The latest docs should have the lowest index

<!-- I was not able to reprocude this: -->
<!--The weight should not start with a 0 otherwise errors occur (octal interpretation).-->
