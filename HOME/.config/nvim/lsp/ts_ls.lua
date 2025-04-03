local home = os.getenv("HOME")

return {
  cmd = { home .. "/.local/share/nvim/mason/bin/typescript-language-server", "--stdio" },
  root_markers = { "package.json", "tsconfig.json" },
}
