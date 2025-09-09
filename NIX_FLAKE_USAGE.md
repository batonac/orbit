# Nix Flake Usage Guide

This repository includes a Nix flake for building and developing Orbit.

## Prerequisites

- [Nix with flakes enabled](https://nixos.wiki/wiki/Flakes)

## Quick Start

### Building Orbit

```bash
# Build the orbit binary
nix build .#orbit

# The binary will be available at ./result/bin/orbit
./result/bin/orbit --help
```

### Development Environment

```bash
# Enter the development shell
nix develop

# This provides:
# - Rust toolchain (cargo, rustc, rustfmt, clippy)
# - Development tools (git, just, cargo-watch)
# - Docker for container operations
# - All necessary build dependencies
```

### Running Orbit

```bash
# Run directly with nix
nix run .#orbit -- --help

# Or build and run
nix build .#orbit && ./result/bin/orbit --help
```

## First Time Setup

The first time you build, you'll need to get the correct `cargoHash`:

1. Run `nix build .#orbit`
2. Copy the correct hash from the error message
3. Update the `cargoHash` in `flake.nix`
4. Run `nix build .#orbit` again

**Automated Setup**: Use the validation script for guided setup:
```bash
./scripts/validate_nix_flake.sh
```

## Cross-Platform Support

This flake supports building on:
- x86_64-linux
- aarch64-linux  
- x86_64-darwin (macOS Intel)
- aarch64-darwin (macOS Apple Silicon)

## Available Packages

- `orbit` - The main orbit binary (default package)

## Available Apps

- `default` - Run orbit directly with `nix run`

## Development Shell Features

- **Rust toolchain**: Latest stable Rust with cargo, rustc, rustfmt, clippy
- **LSP support**: rust-analyzer for IDE integration
- **Docker**: For testing container operations
- **Additional tools**: just, cargo-watch, cargo-audit
- **Welcome message**: Helpful commands and tips when entering the shell