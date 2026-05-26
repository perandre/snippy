# Night Shift Digest

**Week ending:** 2026-04-13

## Summary

| Metric | Value |
|--------|-------|
| Total runs | 13 |
| OK | 6 |
| Silent | 7 |
| Failed | 0 |
| Silent rate | 54% |
| PRs opened | 4 |

## Runs by bundle

| Bundle | Runs | OK | Silent | Failed |
|--------|------|----|--------|--------|
| plans | 3 | 0 | 3 | 0 |
| docs | 4 | 4 | 0 | 0 |
| code-fixes | 4 | 0 | 4 | 0 |
| audits | 2 | 2 | 0 | 0 |

## PRs opened

- 3 audit PRs (2026-04-09): security image-protection, bug move-order, perf image-cache
- 1 audit PR (2026-04-08): bug move-order-ignored

_(Docs bundle PRs for ADRs and suggestions are not counted in the history notes.)_

## Key takeaways

- Plans bundle is consistently silent — no `*-PLAN.md` files exist in `docs/`, so this bundle will remain idle until a plan file is created.
- Code-fixes bundle is consistently silent — the project has no test target, no web UI, and no i18n setup, so all three code-fixes tasks (add-tests, improve-accessibility, translate-ui) self-skip each run.
- Docs bundle is the most productive, generating 4 ADRs and 6 suggestions across two runs this week.
