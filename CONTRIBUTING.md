# Contributing

## Rules

1. **Never push directly to `main`** — always use a feature branch + PR.
2. **Write clear commit messages** — explain *why*, not just *what*.
3. **Keep PRs small** — one logical change per PR.
4. **Review before merging** — at least one approval required.

## Resolving Conflicts

```bash
git checkout main
git pull origin main
git checkout your-branch
git merge main
# fix conflicts, then commit
```
