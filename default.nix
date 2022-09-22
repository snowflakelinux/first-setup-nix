{ lib ? <nixpkgs/lib>
, pkgs ? <nixpkgs>
, first-setup-src
, libadwaita-git ? pkgs.libadwaita
, recipe ? ./recipe.json
}:

pkgs.python3.pkgs.buildPythonApplication rec {

  pname = "vanilla-first-setup";
  version = "git";
  format = "other";
  src = first-setup-src;

  nativeBuildInputs = with pkgs; [
    meson
    ninja
    pkg-config
    python3
    wrapGAppsHook4
    gettext
    desktop-file-utils
    glib
    appstream
  ];

  buildInputs = with pkgs; [
    gtk4
    libadwaita-git
  ];

  propagatedBuildInputs = with pkgs.python3.pkgs; [
    pygobject3
  ];

  postPatch = ''
    substituteInPlace vanilla_first_setup/utils/recipe.py \
    --replace  "/etc/vanilla-first-setup/recipe.json" "${recipe}"
  '';

  preFixup = ''
    chmod 555 $out/bin/vanilla-first-setup $out/bin/vanilla-first-setup-processor
  '';
}
