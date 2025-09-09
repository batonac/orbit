#!/usr/bin/env bash

# Nix Flake Validation and Setup Script
# This script helps validate and set up the Nix flake for the Orbit project

set -euo pipefail

echo "🔍 Orbit Nix Flake Validation Script"
echo "===================================="

# Check if Nix is installed and flakes are enabled
if ! command -v nix &> /dev/null; then
    echo "❌ Nix is not installed. Please install Nix with flakes support:"
    echo "   curl -L https://nixos.org/nix/install | sh -s -- --daemon"
    echo "   Or visit: https://nixos.org/download.html"
    exit 1
fi

echo "✅ Nix is installed"

# Check if flakes are enabled
if ! nix --version | grep -q "flakes"; then
    # Try to check via nix show-config (newer versions)
    if ! nix show-config 2>/dev/null | grep -q "experimental-features.*flakes"; then
        echo "⚠️  Flakes may not be enabled. Add to ~/.config/nix/nix.conf:"
        echo "   experimental-features = nix-command flakes"
    fi
fi

echo "📋 Validating flake structure..."

# Validate flake syntax
if nix flake check --no-build 2>/dev/null; then
    echo "✅ Flake syntax is valid"
else
    echo "❌ Flake syntax validation failed"
    exit 1
fi

# Show flake info
echo ""
echo "📦 Flake information:"
nix flake show --no-write-lock-file 2>/dev/null || {
    echo "⚠️  Could not show flake info, but this might be normal for first run"
}

echo ""
echo "🔨 Testing build (this will show the correct cargoHash if not set)..."

# Try to build and capture the hash if needed
if ! nix build .#orbit 2>&1; then
    echo ""
    echo "❓ If you see a hash mismatch error above, copy the correct hash"
    echo "   and update the 'cargoHash' field in flake.nix"
    echo ""
    echo "   Look for a line like:"
    echo "   got: sha256-AbCdEfGhIjKlMnOpQrStUvWxYz1234567890123456="
    echo ""
    read -p "   Press Enter to continue after updating the hash, or Ctrl+C to exit..."
    
    # Try building again
    if nix build .#orbit; then
        echo "✅ Build successful!"
    else
        echo "❌ Build still failing. Check the error messages above."
        exit 1
    fi
else
    echo "✅ Build successful!"
fi

echo ""
echo "🧪 Testing development shell..."
if nix develop --command echo "Development shell works!"; then
    echo "✅ Development shell is functional"
else
    echo "❌ Development shell failed"
    exit 1
fi

echo ""
echo "🚀 Testing app execution..."
if nix run .#orbit -- --help >/dev/null 2>&1; then
    echo "✅ App execution works"
else
    echo "⚠️  App execution test failed (this might be normal if orbit requires specific setup)"
fi

echo ""
echo "🎉 Nix flake validation complete!"
echo ""
echo "Next steps:"
echo "  • Run 'nix develop' to enter the development environment"
echo "  • Run 'nix build .#orbit' to build the project"
echo "  • Run 'nix run .#orbit -- --help' to run orbit"
echo ""
echo "See NIX_FLAKE_USAGE.md for detailed usage instructions."