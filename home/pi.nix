{ config, pkgs, lib, ... }:

let
  piDir = "${config.home.homeDirectory}/.pi/agent";
in
{
  # ------------------------------------------------------------------
  # pi — terminal coding agent
  #
  # Official home-manager module `programs.pi-coding-agent`:
  #   * installs the binary
  #   * writes settings.json / models.json / keybindings.json / AGENTS.md
  #     into `configDir` (default ~/.pi/agent)
  #   * `extraPackages` are appended to the wrapped `pi` binary's PATH
  # ------------------------------------------------------------------
  programs.pi-coding-agent = {
    enable = true;

    # Default package: nixpkgs `pi-coding-agent` (0.79.1, unstable-only).
    # For a fresher build (0.83.0, matches the npm release, updated daily)
    # enable the numtide/llm-agents.nix overlay in flake.nix, then:
    #   package = pkgs.llm-agents.pi;
    # package = pkgs.llm-agents.pi;

    # node/bun MUST be on PATH: pi npm-installs packages (npm:pi-mcp-adapter)
    # and 5 of the MCP servers below spawn via `npx`. Without these, installs
    # fail with npm ENOENT against the read-only nix store (see plan Step 14).
    extraPackages = with pkgs; [ nodejs bun ];

    # Mirrors ~/.pi/agent/settings.json (minus `lastChangelogVersion`,
    # which is pi's own change-tracking field).
    settings = {
      theme = "dark";
      defaultProvider = "opencode";
      defaultModel = "deepseek-v4-flash-free";
      defaultThinkingLevel = "auto";
      hideThinkingBlock = true;
      packages = [ "npm:pi-mcp-adapter" ];
      showCacheMissNotices = true;
      defaultProjectTrust = "always";
      doubleEscapeAction = "tree";
      treeFilterMode = "default";
    };

    # Custom model providers (→ models.json). Not needed today: you use the
    # built-in `opencode` provider. Uncomment to add e.g. ollama:
    # models = {
    #   providers = {
    #     ollama = {
    #       baseUrl = "http://localhost:11434/v1";
    #       api = "openai-completions";
    #       apiKey = "ollama";
    #       models = [ { id = "llama3.1:8b"; } ];
    #     };
    #   };
    # };
  };

  # ------------------------------------------------------------------
  # Files the official module does NOT manage
  # ------------------------------------------------------------------
  home.file = {
    # 14 MCP servers. Secrets are NOT in this file (repo is public):
    #   * github-mcp-server → reads GITHUB_PERSONAL_ACCESS_TOKEN from env
    #   * tavily-mcp        → reads TAVILY_API_KEY from env
    #   * stitch            → key redacted, fill in locally or via sops
    "${piDir}/mcp.json".source = ../HOME/.pi/agent/mcp.json;

    # Global system-prompt additions (CodeGraph guidance + caveman mode)
    "${piDir}/APPEND_SYSTEM.md".source = ../HOME/.pi/agent/APPEND_SYSTEM.md;
  };

  # MCP server binaries referenced by mcp.json (bare names resolve via PATH):
  #   * github-mcp-server — nixpkgs
  #   * agent-browser     — llm-agents overlay
  #   * codegraph         — local tool, keep on PATH
  #   * engram, lightpanda — still absolute paths in mcp.json; package them
  #                          later (or keep manual installs) — out of scope
  home.packages = with pkgs; [
    github-mcp-server
    llm-agents.agent-browser
  ];

  # ------------------------------------------------------------------
  # Session environment
  # ------------------------------------------------------------------
  home.sessionVariables = {
    # Writable dir for pi's npm-installed packages (pi-mcp-adapter & friends).
    # Keeps pi's own package installs out of the read-only nix store.
    PI_PACKAGE_DIR = "${config.home.homeDirectory}/.pi/agent/npm";

    # MCP servers read these directly (no secrets in mcp.json):
    #   GITHUB_PERSONAL_ACCESS_TOKEN  — github-mcp-server
    #   TAVILY_API_KEY                — tavily-mcp (already exported in your shell)
    #   OPENCODE_API_KEY              — opencode provider (replaces auth.json)
    # Set them via sops (phase 2) or your shell profile — do NOT commit.
  };

  # ------------------------------------------------------------------
  # Secrets (phase 2, recommended) — install sops-nix, then:
  #
  #   sops.secrets.pi-auth-json = { };        # age-encrypted ~/.pi/agent/auth.json
  #   sops.secrets.github-token = { };
  #
  #   home.file."${piDir}/auth.json".source =
  #     config.sops.secrets.pi-auth-json.path;
  #
  #   home.sessionVariables.GITHUB_PERSONAL_ACCESS_TOKEN = ...  # via sops env hook
  # ------------------------------------------------------------------
}
