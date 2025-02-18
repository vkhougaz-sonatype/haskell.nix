{ checkMaterialization ? false  # Allows us to easily switch on materialization checking
, system ? builtins.currentSystem
, sourcesOverride ? {}
, ... }@args: rec {
  sources  = (import ./nix/sources.nix { inherit pkgs; }) // sourcesOverride;
  config   = import ./config.nix;
  overlays = [ allOverlays.combined ] ++ (
    if checkMaterialization == true
      then [(
        final: prev: {
          haskell-nix = prev.haskell-nix // {
            checkMaterialization = true;
          };
        }
      )]
      else []
  );
  allOverlays = import ./overlays args;
  nixpkgsArgs = { inherit config overlays system; };
  pkgs = import sources.nixpkgs nixpkgsArgs;
  pkgs-unstable = import sources.nixpkgs-unstable nixpkgsArgs;
  hix = import ./hix/default.nix;
}
