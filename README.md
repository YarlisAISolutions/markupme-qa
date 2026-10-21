# markupme-qa

SDODS end-to-end tests for [MarkupMe](https://github.com/YarlisAISolutions/markupme). The application under test lives in a different repository; this one holds only the tests, the environments and the CI.

## What is covered

| Module | Layer | Scenarios |
| --- | --- | --- |
| `00-probes` | `@api` | health, capabilities (planned features reported honestly) |
| `01-render` | `@api` | GFM, footnotes, alerts, directives, heading ids, TOC, Graphviz/Blueprint/Mermaid diagrams, diagram errors, sanitizing, md/text/ast formats, bad requests |
| `02-validate` | `@api` | lint rules with codes and lines, clean documents, stats |
| `03-playground` | `@ui` | live preview, typing, diagnostics, Mermaid in the browser, accessibility (axe), dark mode |
| `04-pages` | `@ui` | the kitchen-sink page: TOC, alerts, callouts, copy buttons, diagrams, sanitizing, accessibility, in-page links |

## Run locally

```bash
# 1. In a checkout of YarlisAISolutions/markupme
bun install && bun run build
node packages/cli/dist/bin.js serve examples --port 4321

# 2. Here
bun install
npx playwright install chromium
bun run lint                 # sdods lint -p markupme --strict
bun run test:api             # sdods run -p markupme -e local -l api
bun run test:ui              # sdods run -p markupme -e local -l ui -b chromium -t @smoke
node scripts/qa-gate.mjs --suite api --min-scenarios 15
```

`sdods run` exits 0 when no scenario matches the selection, so CI always follows a run with `scripts/qa-gate.mjs`, which fails an empty or short run.

## Rules

- Every scenario carries one layer tag (`@ui`, `@api`) and one suite tag (`@smoke`, `@regression`, `@sanity`).
- Reuse the SDODS core steps first (`npx sdods steps list -p markupme`). Project steps live in page objects under `projects/markupme/pages/`.
- Secrets are never literals; reference `${VAR}`.
