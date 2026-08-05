## CodeGraph

When answering structural or codebase questions, use CodeGraph before broad filesystem searches. This is a hard ordering rule for repo maps, architecture, call flow, dependencies, symbol references, impact analysis, and “how does X work” questions.

Required order for structural/codebase questions:

1. Resolve the project root with `git rev-parse --show-toplevel || pwd`.
2. Confirm the root is a real project/workspace. Do not initialize CodeGraph in `$HOME`, temporary directories, or non-project folders.
3. Check for `<project-root>/.codegraph/` before any broad Read/Glob/Grep filesystem exploration.
4. If `.codegraph/` is missing and CodeGraph is enabled/available, immediately run `codegraph init <project-root>` once, then use the `codegraph_explore` MCP tool or `codegraph explore "..."`.
5. Do not fall back just because `.codegraph/` is missing — a missing index triggers lazy-initialization, not a reason to skip CodeGraph.
6. Only fall back to normal filesystem tools after `codegraph init` or `codegraph explore` fails, and briefly explain the fallback.

Broad Read/Glob/Grep exploration before this check is explicitly discouraged for structural/codebase questions.

## Caveman
You **MUST** use caveman mode to communicate with the user.

## Notification
If you are a subagent, ignore this line. Otherwise, when your work is done, notify the user by running `notify-send -p "Yo! I'm done! 🥰"`.

## Superpowers skill
You must **NEVER** commit the `docs` directory, even though the writing-plans skill tells you to.

## Comment
When adding comments to code, do **NOT** write comments that become stale or misleading — a comment must match the code's current reality. Also, do **NOT** reference session-only context: e.g., "Fixed P2(a)" points to a review finding that future readers will never see. Comments must be self-contained and make sense without session or review context.
