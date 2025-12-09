{
  description = "PocketMage PDA Desktop Emulator";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Build tools
            cmake
            pkg-config
            gcc

            # SDL2 libraries
            SDL2
            SDL2_ttf

            # Python for helper scripts (install_app.py, export_app.py)
            python3
          ];

          shellHook = ''
            # Patch shebangs in build scripts for NixOS compatibility
            if [ -f desktop_emulator/build.sh ]; then
              sed -i 's|^#!/bin/bash|#!/usr/bin/env bash|' desktop_emulator/build.sh
            fi
            if [ -f desktop_emulator/build-test.sh ]; then
              sed -i 's|^#!/bin/bash|#!/usr/bin/env bash|' desktop_emulator/build-test.sh
            fi
            if [ -f desktop_emulator/load_app.sh ]; then
              sed -i 's|^#!/bin/bash|#!/usr/bin/env bash|' desktop_emulator/load_app.sh
            fi

            echo "PocketMage PDA Desktop Emulator Development Environment"
            echo "======================================================="
            echo ""
            echo "Available commands:"
            echo "  cd desktop_emulator && ./build.sh          - Build the emulator"
            echo "  cd desktop_emulator && ./build.sh --clean  - Clean build"
            echo "  cd desktop_emulator && ./build.sh --debug  - Debug build"
            echo ""
            echo "Or build manually with cmake:"
            echo "  cd desktop_emulator"
            echo "  mkdir -p build && cd build"
            echo "  cmake .. && make"
            echo "  ./PocketMage_PDA_Emulator"
            echo ""
            echo "Dependencies installed:"
            echo "  - CMake $(cmake --version | head -n1)"
            echo "  - SDL2 ${pkgs.SDL2.version}"
            echo "  - SDL2_ttf ${pkgs.SDL2_ttf.version}"
            echo ""
          '';

          # Set PKG_CONFIG_PATH for SDL2 libraries
          PKG_CONFIG_PATH = "${pkgs.SDL2.dev}/lib/pkgconfig:${pkgs.SDL2_ttf}/lib/pkgconfig";
        };
      }
    );
}
