local home = os.getenv("HOME")

return {
  cmd = { home .. "/.local/share/nvim/mason/bin/vscode-css-language-server", "--stdio" },
}
