# Contributing to Citron-CI

This repository handles nightly builds for the Citron emulator. Contributions are welcome!

## CI Workflows

- **build-all.yml**: Unified workflow for all platforms (Linux, macOS, Windows, Android) using matrix strategy.
- **build-stable.yml**: Builds stable releases on version tags.
- **lint.yml**: Lints workflow files for errors.

## Naming Convention

For nightly: `Citron-v{version}-nightly.{hash}-{os}-{arch}{modifiers}.{ext}`

For stable: `Citron-v{version}-{os}-{arch}{modifiers}.{ext}` (no hash or nightly)

## Debugging Failures

- Check the workflow logs for errors.
- For build issues, ensure dependencies are cached.
- For packaging, verify the naming script.

## Issues

Report issues in the [Issues tab](https://github.com/Zephyron-Dev/Citron-CI/issues).