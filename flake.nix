{
  description = "ChewCW's dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Daily-updated AI coding agent packages (pi, claude-code, ...).
    # No `follows`: uses its own pinned nixpkgs so its binary cache hits.
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
    };
    # Plugins sourced from nixpkgs or fetched directly
    flake-utils.url = "github:Numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, llm-agents, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # nixos-unstable required: pi-coding-agent + its home-manager module
        # don't exist on nixos-24.11. Overlay adds pkgs.llm-agents.* (pi at 0.83.0).
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ llm-agents.overlays.shared-nixpkgs ];
        };
        lib = nixpkgs.lib;
      in
      {
        homeConfigurations = {
          ccw = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
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
