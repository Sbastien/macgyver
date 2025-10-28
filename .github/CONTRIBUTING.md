# Contributing

Thanks for your interest in contributing!

## Code Guidelines

**POSIX Compliance**: All scripts must use `#!/bin/sh` and avoid bashisms.

**Key Requirements**:

- Use `[ ]` not `[[ ]]`
- Use logging functions from `scripts/lib/log_utils.sh`
- Set up error handling with `setup_error_handling`
- Make scripts idempotent (safe to run multiple times)

**Testing**:

```bash
# Syntax check
sh -n *.sh scripts/*.sh scripts/lib/*.sh

# Shellcheck (CI requirement)
shellcheck -s sh *.sh scripts/*.sh scripts/lib/*.sh
```

## Commit Format

Use conventional commits:

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `refactor:` Code refactoring
- `test:` Tests
- `chore:` Maintenance

Example: `fix: resolve ANSI color codes in log output`

## Pull Request Process

1. Fork and create a feature branch
2. Make changes following code guidelines
3. Test with `sh -n` and `shellcheck`
4. Commit with clear messages
5. Open PR with description of changes

That's it!
