local home = os.getenv("HOME")

return {
  filetypes = { "python" },
  cmd = { home .. "/.local/share/nvim/mason/bin/pyright-langserver", "--stdio" },
}
