{
  description = "Orbit - A simple, lightweight solution for scaling containers with built-in service discovery and proxying";

  # Usage:
  # - Build: nix build .#orbit
  # - Develop: nix develop
  # - Run: nix run .#orbit -- [args]
  #
  # First time setup:
  # 1. Run 'nix build .#orbit' to get the correct cargoHash
  # 2. Update the cargoHash in the buildRustPackage section
  # 3. Run 'nix build .#orbit' again to build successfully

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Common build inputs needed for orbit
        nativeBuildInputs = with pkgs; [
          pkg-config
          openssl.dev
          cmake # Required by some native dependencies
        ];
        
        buildInputs = with pkgs; [
          openssl
        ] ++ lib.optionals stdenv.isDarwin [
          darwin.apple_sdk.frameworks.Security
          darwin.apple_sdk.frameworks.SystemConfiguration
        ];

      in {
        packages = {
          default = self.packages.${system}.orbit;
          
          orbit = pkgs.rustPlatform.buildRustPackage rec {
            pname = "orbit";
            version = "0.3.0";
            
            src = ./.;
            
            # To get the correct hash, run: nix build .#orbit 2>&1 | grep "got:" | awk '{print $2}'
            # Then replace this placeholder with the actual hash
            cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
            
            inherit nativeBuildInputs buildInputs;
            
            # Skip tests since there are none currently
            doCheck = false;
            
            meta = with pkgs.lib; {
              description = "A simple, lightweight solution for scaling containers with built-in service discovery and proxying";
              homepage = "https://github.com/batonac/orbit";
              license = licenses.asl20;
              maintainers = [ ];
              mainProgram = "orbit";
            };
          };
        };

        devShells.default = pkgs.mkShell {
          inherit buildInputs;
          nativeBuildInputs = nativeBuildInputs ++ (with pkgs; [
            # Rust toolchain
            cargo
            rustc
            rustfmt
            clippy
            rust-analyzer
            
            # Development tools
            git
            just # Command runner, commonly used in Rust projects
            
            # Docker for container management (orbit's core functionality)
            docker
            docker-compose
            
            # Additional tools for Rust development
            cargo-watch # Auto-rebuild on file changes
            cargo-audit # Security audit
          ]);
          
          # Environment variables for development
          RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
          
          shellHook = ''
            echo "🚀 Welcome to the Orbit development environment!"
            echo ""
            echo "Available commands:"
            echo "  cargo build    - Build the project"
            echo "  cargo run      - Run orbit"
            echo "  cargo test     - Run tests"
            echo "  cargo clippy   - Lint the code"
            echo "  cargo fmt      - Format the code"
            echo ""
            echo "Docker is available for container operations."
            echo ""
          '';
        };

        # Optional: provide the binary as an app
        apps.default = {
          type = "app";
          program = "${self.packages.${system}.orbit}/bin/orbit";
        };
      });
}