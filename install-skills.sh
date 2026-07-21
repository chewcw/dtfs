#!/usr/bin/env bash
# install-skills.sh — Install all ~/.agents/skills from their GitHub sources
#
# Reproducible: every skill references its origin repo so this works on a
# fresh machine with no local skills cache.
#
# Sources discovered by searching the skills.sh registry for each skill name
# and picking the top (most-installed) published package. test-driven-development
# exists in both addyosmani/agent-skills and obra/superpowers — we pick
# addyosmani (original source; obra bundles a copy).
#
# Usage:
#   ./install-skills.sh              # project-level install (cwd: current project)
#   ./install-skills.sh -g           # global install (user-wide)
#   ./install-skills.sh -n           # dry-run, just list what would be installed
#   ./install-skills.sh -h           # this help

set -euo pipefail

DRY_RUN=false
GLOBAL=""

while getopts "gnh" opt; do
  case "$opt" in
    g) GLOBAL="-g" ;;
    n) DRY_RUN=true ;;
    h) sed -n '2,8p' "$0"; exit 0 ;;
    *) exit 1 ;;
  esac
done

# ── Source map ──────────────────────────────────────────────────────────────
# <skill-name> <owner/repo@skill>
# Determined via `npx skills find <name>` — top result by installs.

SKILLS=(
  # ── addyosami/agent-skills ──────────────────────────────────────
  "api-and-interface-design          addyosmani/agent-skills@api-and-interface-design"
  "browser-testing-with-devtools     addyosmani/agent-skills@browser-testing-with-devtools"
  "code-review-and-quality           addyosmani/agent-skills@code-review-and-quality"
  "code-simplification               addyosmani/agent-skills@code-simplification"
  "context-engineering               addyosmani/agent-skills@context-engineering"
  "debugging-and-error-recovery      addyosmani/agent-skills@debugging-and-error-recovery"
  "doubt-driven-development          addyosmani/agent-skills@doubt-driven-development"
  "frontend-ui-engineering           addyosmani/agent-skills@frontend-ui-engineering"
  "idea-refine                       addyosmani/agent-skills@idea-refine"
  "interview-me                      addyosmani/agent-skills@interview-me"
  "performance-optimization          addyosmani/agent-skills@performance-optimization"
  "planning-and-task-breakdown       addyosmani/agent-skills@planning-and-task-breakdown"
  "source-driven-development         addyosmani/agent-skills@source-driven-development"
  "spec-driven-development           addyosmani/agent-skills@spec-driven-development"
  "test-driven-development           addyosmani/agent-skills@test-driven-development"
  # ── obra/superpowers ────────────────────────────────────────────
  "brainstorming                     obra/superpowers@brainstorming"
  "dispatching-parallel-agents       obra/superpowers@dispatching-parallel-agents"
  "executing-plans                   obra/superpowers@executing-plans"
  "finishing-a-development-branch    obra/superpowers@finishing-a-development-branch"
  "receiving-code-review             obra/superpowers@receiving-code-review"
  "requesting-code-review            obra/superpowers@requesting-code-review"
  "subagent-driven-development       obra/superpowers@subagent-driven-development"
  "systematic-debugging              obra/superpowers@systematic-debugging"
  "using-git-worktrees               obra/superpowers@using-git-worktrees"
  "using-superpowers                 obra/superpowers@using-superpowers"
  "verification-before-completion    obra/superpowers@verification-before-completion"
  "writing-plans                     obra/superpowers@writing-plans"
  "writing-skills                    obra/superpowers@writing-skills"
  # ── anthropics/skills ───────────────────────────────────────────
  "frontend-design                   anthropics/skills@frontend-design"
  # ── vercel-labs/skills ──────────────────────────────────────────
  "find-skills                       vercel-labs/skills@find-skills"
  # ── vercel-labs/agent-skills ────────────────────────────────────
  "vercel-react-best-practices       vercel-labs/agent-skills@vercel-react-best-practices"
  "vercel-react-view-transitions     vercel-labs/agent-skills@vercel-react-view-transitions"
  "web-design-guidelines             vercel-labs/agent-skills@web-design-guidelines"
  "writing-guidelines                vercel-labs/agent-skills@writing-guidelines"
  # ── JuliusBrussee/caveman ──────────────────────────────────────
  "caveman                          JuliusBrussee/caveman@caveman"
  "caveman-commit                   JuliusBrussee/caveman@caveman-commit"
  "caveman-compress                 JuliusBrussee/caveman@caveman-compress"
  "caveman-help                     JuliusBrussee/caveman@caveman-help"
  "caveman-review                   JuliusBrussee/caveman@caveman-review"
  "caveman-stats                    JuliusBrussee/caveman@caveman-stats"
  "cavecrew                         JuliusBrussee/caveman@cavecrew"
)

echo "=== Installing 41 skills from published sources ==="
echo "Mode: $([ -n "$GLOBAL" ] && echo "global" || echo "project (cwd: $(pwd))")"

if [ "$DRY_RUN" = true ]; then
  for entry in "${SKILLS[@]}"; do
    name="${entry%%  *}"
    pkg="${entry##* }"
    printf "  %-36s → %s\n" "$name" "$pkg"
  done
  echo ""
  echo "Dry-run complete. Pass no flags to install."
  exit 0
fi

# ── Install ──────────────────────────────────────────────────────────────────
FAILED=()
for entry in "${SKILLS[@]}"; do
  name="${entry%%  *}"
  pkg="${entry##* }"
  # Trim leading/trailing whitespace in case name
  name="$(echo "$name" | xargs)"
  echo ">>> Installing: $name  ($pkg)"
  if npx --yes skills add "$pkg" --all -y $GLOBAL 2>&1; then
    echo "  OK  $name"
  else
    echo "  FAILED  $name" >&2
    FAILED+=("$name")
  fi
  echo ""
done

# ── Summary ──────────────────────────────────────────────────────────────────
echo "=== Summary ==="
echo "  Installed:  $((${#SKILLS[@]} - ${#FAILED[@]}))"
if [ ${#FAILED[@]} -gt 0 ]; then
  echo "  Failed:     ${#FAILED[@]}"
  for f in "${FAILED[@]}"; do
    echo "    - $f"
  done
fi
echo "  Lock file:  $(pwd)/skills-lock.json"
echo ""
echo "Done."
