# CLAUDE.md: markupme-qa

SDODS (BDD) end-to-end tests for MarkupMe (app: `YarlisAISolutions/markupme`; work tracked in YCadence project MKP). One project: `projects/markupme`. This repo is public. `README.md` has what is covered and how to run it locally.

## Tools

- **MCP:** `.mcp.json` registers the SDODS MCP server. Use its `project_*`, `feature_*`, `step_*` and `run_*` tools for anything about features, steps and runs. It runs the latest `@sdods/cli` through `npx`, not this repo's pin.
- **Skills** (`.claude/skills/`; `.agents/skills/` holds the same set for other agents): `sdods` (workspace model and feature rules), `sdods-run`, `sdods-record`, `sdods-start-ui`. They come from `@sdods/cli` 0.22.0 while `package.json` pins 0.16.0, so check `bun run sdods --help` before relying on a flag they name. Refresh them with `npx -y @sdods/cli@<version> skills install --force`.

## Commands

```bash
bun run lint                                          # before every PR
bun run test:api
bun run test:ui
node scripts/qa-gate.mjs --suite api --min-scenarios 15   # the gate
```

`sdods run` exits 0 when nothing matches the selection, so always follow a run with `qa-gate.mjs`.

## Paired PRs

When a change needs a branch in both repos, point each repo's CI at the other's branch, and delete both variables after merge:

- `QA_REF` (repository variable on `markupme`): the `markupme-qa` branch.
- `APP_REF` (repository variable here): the `markupme` branch.

## Rules

- Features, steps and pages go through proposals (`feature_write` or the proposal tools). A person accepts them with `sdods proposals accept <id>`.
- Every scenario has one layer tag (`@ui`, `@api`) and one suite tag (`@smoke`, `@regression`, `@sanity`).
- Reuse the SDODS core steps first (`step_find`). Locator priority: role + name, label, test id, placeholder, text, CSS. Never XPath.
- Secrets are `${VAR}` references. Never commit `.env` files or `.auth/`.
