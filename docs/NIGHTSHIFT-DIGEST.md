# Night Shift Digest

**Week ending:** 2026-04-12

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

- audits 2026-04-09: 3 PRs (security image-protection, bug move-order, perf image-cache)
- audits 2026-04-08: 1 PR (bug move-order-ignored)

## Key takeaways

- The docs bundle is the most productive, with all 4 runs producing work (ADRs and suggestions).
- Plans and code-fixes are consistently silent: no `*-PLAN.md` files exist for plans, and code-fixes self-skips due to no test target, no web UI, and no i18n setup.
- Zero failures across 13 runs this week.
