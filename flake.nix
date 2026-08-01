{
  description = "ChewCW's dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Plugins sourced from nixpkgs or fetched directly
    flake-utils.url = "github:Numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;
      in
      {
        homeConfigurations = {
          ccw = home-manager.lib.homeManagerConfiguration {
            pkgs = pkgs;
            modules = [
              ./home/default.nix
            ];
            # Pass extra args to modules
            extraSpecialArgs = {
              inherit self;
              isDarwin = false;
            };
          };
        };
      }
    );
}
