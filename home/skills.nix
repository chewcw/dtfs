{ config, pkgs, lib, ... }:

# ------------------------------------------------------------------
# Agent skills — ~/.agents/skills
#
# Replaces install-skills.sh (npx skills add ...) with the nix way:
# each source repo is pinned by commit and fetched with
# `builtins.fetchGit` (content-addressed — no sha256 to maintain),
# then every skill directory is symlinked into ~/.agents/skills.
#
# Source map generated from ~/.agents/.skill-lock.json (the skills.sh
# lock file) — 76 skills across 12 repos. `npx skills add` installed
# whole skill folders (dir containing SKILL.md), so we symlink the
# whole directory, not just SKILL.md.
# ------------------------------------------------------------------

let
  fetchSkillRepo = { url, rev }:
    builtins.fetchGit { inherit url rev; shallow = true; };

  repos = {
    addyosmani = fetchSkillRepo {
      url = "https://github.com/addyosmani/agent-skills.git";
      rev = "7829ffd90d973b6325f5f12f1b1226dcace74443";
    };
    superpowers = fetchSkillRepo {
      url = "https://github.com/obra/superpowers.git";
      rev = "44c9b2d6e889982ac18c27d05a19fefe335194e1";
    };
    anthropic = fetchSkillRepo {
      url = "https://github.com/anthropics/skills.git";
      rev = "b29e7cf65e5cb78a5ac33d582270551bc74a14eb";
    };
    vercel-skills = fetchSkillRepo {
      url = "https://github.com/vercel-labs/skills.git";
      rev = "1164afa5f0e21ebd01e6fc11249759353f494ad1";
    };
    vercel-agent-skills = fetchSkillRepo {
      url = "https://github.com/vercel-labs/agent-skills.git";
      rev = "7c180d9044c9ae2b442b567aad4e42a28dd5ed62";
    };
    caveman = fetchSkillRepo {
      url = "https://github.com/JuliusBrussee/caveman.git";
      rev = "0d95a81d35a9f2d123a5e9430d1cfc43d55f1bb0";
    };
    agentmemory = fetchSkillRepo {
      url = "https://github.com/rohitg00/agentmemory.git";
      rev = "8c90741c633c020d5d24c34b6aa0ba53e2dd2226";
    };
    stitch = fetchSkillRepo {
      url = "https://github.com/google-labs-code/stitch-skills.git";
      rev = "535b0889a46868c9b08f8a7f7084db3c1958a2b6";
    };
    lavish = fetchSkillRepo {
      url = "https://github.com/kunchenguid/lavish-axi.git";
      rev = "7c64184adce8b2b18c1cb072779305303b8079d9";
    };
    herdr = fetchSkillRepo {
      url = "https://github.com/herdrdev/herdr.git";
      rev = "9a4ce5e13c1d4622ca63c2947d0eaa018ec35715";
    };
    mattpocock = fetchSkillRepo {
      url = "https://github.com/mattpocock/skills.git";
      rev = "2ab958093e83e0ec752e6c1c5932da465bf23e0c";
    };
    agent-browser = fetchSkillRepo {
      url = "https://github.com/vercel-labs/agent-browser.git";
      rev = "93cdda5709e8861c0c26b0b955d8d746e9fda0d7";
    };
  };

  # skill = { name = <installed dir name>; repo = <repos.x>; path = <repo-relative skill dir>; }
  skills = [
    # addyosmani/agent-skills (skills/<name>)
    { name = "api-and-interface-design"; repo = repos.addyosmani; path = "skills/api-and-interface-design"; }
    { name = "browser-testing-with-devtools"; repo = repos.addyosmani; path = "skills/browser-testing-with-devtools"; }
    { name = "code-review-and-quality"; repo = repos.addyosmani; path = "skills/code-review-and-quality"; }
    { name = "code-simplification"; repo = repos.addyosmani; path = "skills/code-simplification"; }
    { name = "context-engineering"; repo = repos.addyosmani; path = "skills/context-engineering"; }
    { name = "debugging-and-error-recovery"; repo = repos.addyosmani; path = "skills/debugging-and-error-recovery"; }
    { name = "doubt-driven-development"; repo = repos.addyosmani; path = "skills/doubt-driven-development"; }
    { name = "frontend-ui-engineering"; repo = repos.addyosmani; path = "skills/frontend-ui-engineering"; }
    { name = "idea-refine"; repo = repos.addyosmani; path = "skills/idea-refine"; }
    { name = "interview-me"; repo = repos.addyosmani; path = "skills/interview-me"; }
    { name = "performance-optimization"; repo = repos.addyosmani; path = "skills/performance-optimization"; }
    { name = "planning-and-task-breakdown"; repo = repos.addyosmani; path = "skills/planning-and-task-breakdown"; }
    { name = "source-driven-development"; repo = repos.addyosmani; path = "skills/source-driven-development"; }
    { name = "spec-driven-development"; repo = repos.addyosmani; path = "skills/spec-driven-development"; }
    { name = "test-driven-development"; repo = repos.addyosmani; path = "skills/test-driven-development"; }

    # obra/superpowers (skills/<name>)
    { name = "brainstorming"; repo = repos.superpowers; path = "skills/brainstorming"; }
    { name = "dispatching-parallel-agents"; repo = repos.superpowers; path = "skills/dispatching-parallel-agents"; }
    { name = "executing-plans"; repo = repos.superpowers; path = "skills/executing-plans"; }
    { name = "finishing-a-development-branch"; repo = repos.superpowers; path = "skills/finishing-a-development-branch"; }
    { name = "receiving-code-review"; repo = repos.superpowers; path = "skills/receiving-code-review"; }
    { name = "requesting-code-review"; repo = repos.superpowers; path = "skills/requesting-code-review"; }
    { name = "subagent-driven-development"; repo = repos.superpowers; path = "skills/subagent-driven-development"; }
    { name = "systematic-debugging"; repo = repos.superpowers; path = "skills/systematic-debugging"; }
    { name = "using-git-worktrees"; repo = repos.superpowers; path = "skills/using-git-worktrees"; }
    { name = "using-superpowers"; repo = repos.superpowers; path = "skills/using-superpowers"; }
    { name = "verification-before-completion"; repo = repos.superpowers; path = "skills/verification-before-completion"; }
    { name = "writing-plans"; repo = repos.superpowers; path = "skills/writing-plans"; }
    { name = "writing-skills"; repo = repos.superpowers; path = "skills/writing-skills"; }

    # anthropics/skills
    { name = "frontend-design"; repo = repos.anthropic; path = "skills/frontend-design"; }

    # vercel-labs/skills
    { name = "find-skills"; repo = repos.vercel-skills; path = "skills/find-skills"; }

    # vercel-labs/agent-skills — note: repo dirs differ from installed names
    { name = "web-design-guidelines"; repo = repos.vercel-agent-skills; path = "skills/web-design-guidelines"; }
    { name = "writing-guidelines"; repo = repos.vercel-agent-skills; path = "skills/writing-guidelines"; }
    { name = "vercel-react-best-practices"; repo = repos.vercel-agent-skills; path = "skills/react-best-practices"; }
    { name = "vercel-react-view-transitions"; repo = repos.vercel-agent-skills; path = "skills/react-view-transitions"; }

    # JuliusBrussee/caveman
    { name = "caveman"; repo = repos.caveman; path = "skills/caveman"; }
    { name = "caveman-commit"; repo = repos.caveman; path = "skills/caveman-commit"; }
    { name = "caveman-compress"; repo = repos.caveman; path = "skills/caveman-compress"; }
    { name = "cavecrew"; repo = repos.caveman; path = "skills/cavecrew"; }
    { name = "caveman-help"; repo = repos.caveman; path = "skills/caveman-help"; }
    { name = "caveman-review"; repo = repos.caveman; path = "skills/caveman-review"; }
    { name = "caveman-stats"; repo = repos.caveman; path = "skills/caveman-stats"; }

    # rohitg00/agentmemory (plugin/skills/<name>)
    { name = "agentmemory-agents"; repo = repos.agentmemory; path = "plugin/skills/agentmemory-agents"; }
    { name = "agentmemory-architecture"; repo = repos.agentmemory; path = "plugin/skills/agentmemory-architecture"; }
    { name = "agentmemory-config"; repo = repos.agentmemory; path = "plugin/skills/agentmemory-config"; }
    { name = "agentmemory-hooks"; repo = repos.agentmemory; path = "plugin/skills/agentmemory-hooks"; }
    { name = "agentmemory-mcp-tools"; repo = repos.agentmemory; path = "plugin/skills/agentmemory-mcp-tools"; }
    { name = "agentmemory-rest-api"; repo = repos.agentmemory; path = "plugin/skills/agentmemory-rest-api"; }
    { name = "commit-context"; repo = repos.agentmemory; path = "plugin/skills/commit-context"; }
    { name = "commit-history"; repo = repos.agentmemory; path = "plugin/skills/commit-history"; }
    { name = "forget"; repo = repos.agentmemory; path = "plugin/skills/forget"; }
    { name = "handoff"; repo = repos.agentmemory; path = "plugin/skills/handoff"; }
    { name = "recall"; repo = repos.agentmemory; path = "plugin/skills/recall"; }
    { name = "recap"; repo = repos.agentmemory; path = "plugin/skills/recap"; }
    { name = "remember"; repo = repos.agentmemory; path = "plugin/skills/remember"; }
    { name = "session-history"; repo = repos.agentmemory; path = "plugin/skills/session-history"; }
    { name = "write-agentmemory-skill"; repo = repos.agentmemory; path = "plugin/skills/write-agentmemory-skill"; }

    # google-labs-code/stitch-skills (plugins/stitch-{utilities,build,design}/skills/<name>)
    { name = "design-md"; repo = repos.stitch; path = "plugins/stitch-utilities/skills/design-md"; }
    { name = "enhance-prompt"; repo = repos.stitch; path = "plugins/stitch-utilities/skills/enhance-prompt"; }
    { name = "stitch-loop"; repo = repos.stitch; path = "plugins/stitch-utilities/skills/stitch-loop"; }
    { name = "taste-design"; repo = repos.stitch; path = "plugins/stitch-utilities/skills/taste-design"; }
    { name = "react-vite-dashboard"; repo = repos.stitch; path = "plugins/stitch-build/skills/react-vite-dashboard"; }
    { name = "remotion"; repo = repos.stitch; path = "plugins/stitch-build/skills/remotion"; }
    { name = "shadcn-ui"; repo = repos.stitch; path = "plugins/stitch-build/skills/shadcn-ui"; }
    { name = "stitch-react-components"; repo = repos.stitch; path = "plugins/stitch-build/skills/react-components"; }
    { name = "stitch-react-native"; repo = repos.stitch; path = "plugins/stitch-build/skills/react-native"; }
    { name = "stitch-code-to-design"; repo = repos.stitch; path = "plugins/stitch-design/skills/code-to-design"; }
    { name = "stitch-extract-design-md"; repo = repos.stitch; path = "plugins/stitch-design/skills/extract-design-md"; }
    { name = "stitch-extract-static-html"; repo = repos.stitch; path = "plugins/stitch-design/skills/extract-static-html"; }
    { name = "stitch-generate-design"; repo = repos.stitch; path = "plugins/stitch-design/skills/generate-design"; }
    { name = "stitch-manage-design-system"; repo = repos.stitch; path = "plugins/stitch-design/skills/manage-design-system"; }
    { name = "stitch-upload-to-stitch"; repo = repos.stitch; path = "plugins/stitch-design/skills/upload-to-stitch"; }

    # kunchenguid/lavish-axi
    { name = "lavish"; repo = repos.lavish; path = "skills/lavish"; }

    # herdrdev/herdr — skill moved to skills/herdr (old ogulcancelik/herdr
    # had SKILL.md at repo root; installed dir name stays `herdr`)
    { name = "herdr"; repo = repos.herdr; path = "skills/herdr"; }

    # mattpocock/skills (skills/productivity/<name>)
    { name = "grilling"; repo = repos.mattpocock; path = "skills/productivity/grilling"; }
    { name = "teach"; repo = repos.mattpocock; path = "skills/productivity/teach"; }

    # vercel-labs/agent-browser
    { name = "agent-browser"; repo = repos.agent-browser; path = "skills/agent-browser"; }
  ];
in
{
  # Symlink every skill dir into ~/.agents/skills/<name>.
  # Sources point into the nix store → read-only (same as all HM files).
  home.file = lib.listToAttrs (map
    (s: {
      name = ".agents/skills/${s.name}";
      value.source = "${s.repo}/${s.path}";
    })
    skills);
}
