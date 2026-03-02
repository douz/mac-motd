# Contributing

Thanks for contributing to `mac-motd`.

## Development Setup

1. Clone the repo.
2. Run local checks:

```bash
./tests/run.sh
zsh -n motd.sh install.sh uninstall.sh bin/mac-motd modules/*.sh config/*.zsh
```

## Pull Request Guidelines

1. Keep changes focused and small.
2. Add or update tests when behavior changes.
3. Update README/docs when commands, install flow, or config changes.
4. If you add or change a module, update `modules/README.md`.
5. Run the local checks before requesting review.

## Commit Messages

Prefer conventional-style messages, for example:

- `feat: add module dependency guard`
- `fix: handle missing battery info`
- `docs: clarify install flow`
- `test: add uninstall coverage`

## Reporting Bugs

Please use the bug report issue template and include:

- macOS version
- shell (`zsh --version`)
- install method (source/install script)
- expected vs actual behavior
- relevant output/errors
