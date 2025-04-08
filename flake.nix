{
  description = "Lazarus IDE and Application with Complete GTK2 Support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};

        # Shared GTK2 dependencies for both dev shell and package
        gtk2Deps = with pkgs; [
          lazarus
          fpc
          gtk2
          glib
          pango
          atk
          cairo
          gdk-pixbuf
          xorg.libX11
          xorg.libXext
          xorg.libXrender
          xorg.libXi
          xorg.libXcursor
          xorg.libXfixes
          xorg.libXcomposite
          xorg.libXdamage
          gnome-themes-extra
        ];

        # Function to create library paths
        mkLibPaths = deps: {
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath deps;
          XDG_DATA_DIRS = with pkgs; lib.makeSearchPath "share" [gtk2 gnome-themes-extra];
          GI_TYPELIB_PATH = pkgs.lib.makeSearchPath "lib/girepository-1.0" deps;
        };
      in {
        # Development environment
        devShells.default = pkgs.mkShell {
          name = "lazarus-dev";

          packages = gtk2Deps;

          shellHook = ''
            # Set all necessary environment variables
            export ${pkgs.lib.concatStringsSep "\n" (
              pkgs.lib.mapAttrsToList (k: v: "export ${k}=${v}")
              (mkLibPaths gtk2Deps)
            )}
            echo "Lazarus development shell ready with full GTK2 support"
            export PS1='\n\[\033[1;34m\](Pascal):\w]\$\[\033[0m\]'
            echo "Run 'lazarus' to start the IDE"
          '';
        };

        # Package derivation
        packages.default = pkgs.stdenv.mkDerivation {
          name = "laz-hello";
          src = ./.;

          nativeBuildInputs = with pkgs; [makeWrapper];
          buildInputs = gtk2Deps;

          # this does not work - assuming local build first with "lazbuild -B Laz_Hello.lpi"
          #buildPhase = ''
          #  ldir="${pkgs.lazarus}/"
          #  HOME=/tmp/lazhome lazbuild Laz_Hello.lpi --lazarusdir="$ldir/share/lazarus/"
          #'';

          installPhase = ''
                        mkdir -p $out/bin
                        cp ${./Laz_Hello} $out/bin/Laz_Hello
                        chmod +x $out/bin/Laz_Hello

                        # Get all library paths
                        libPaths=${pkgs.lib.escapeShellArg (pkgs.lib.concatStringsSep ":" [
              (pkgs.lib.makeLibraryPath gtk2Deps)
              (pkgs.lib.makeSearchPath "lib/girepository-1.0" gtk2Deps)
            ])}
            #
                        dataPaths=${pkgs.lib.escapeShellArg (pkgs.lib.concatStringsSep ":" [
              "${pkgs.gtk2}/share"
              "${pkgs.gnome-themes-extra}/share"
            ])}

                        wrapProgram $out/bin/Laz_Hello \
                          --prefix LD_LIBRARY_PATH : "$libPaths" \
                          --prefix XDG_DATA_DIRS : "$dataPaths" \
                          --prefix GI_TYPELIB_PATH : "$libPaths"
          '';
        };

        # Default package for 'nix build'
        defaultPackage = self.packages.${system}.default;
      }
    );
}
