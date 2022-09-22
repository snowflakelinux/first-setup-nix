{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    first-setup-src = {
      url = "git+https://github.com/Vanilla-OS/first-setup";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, utils, first-setup-src }@inputs:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        libadwaita-git = pkgs.libadwaita.overrideAttrs (oldAttrs: rec {
          version = "1.2.0";
          src = pkgs.fetchFromGitLab {
            domain = "gitlab.gnome.org";
            owner = "GNOME";
            repo = "libadwaita";
            rev = version;
            hash = "sha256-3lH7Vi9M8k+GSrCpvruRpLrIpMoOakKbcJlaAc/FK+U=";
          };
        });
        name = "vanilla-first-setup";
      in
      rec
      {
        packages.${name} = pkgs.callPackage ./default.nix {
          inherit (inputs) first-setup-src;
          libadwaita-git = libadwaita-git;
        };

        # `nix build`
        defaultPackage = packages.${name};

        # `nix run`
        apps.${name} = utils.lib.mkApp {
          inherit name;
          drv = packages.${name};
        };
        defaultApp = packages.${name};

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            python3
            python3.pkgs.pyaml
            python3.pkgs.pygobject3
            desktop-file-utils
            gtk4
            gettext
            libadwaita-git
            wrapGAppsHook4
            glib
            appstream
          ];
        };
      });
}
