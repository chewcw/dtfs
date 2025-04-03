local home = os.getenv("HOME")

return {
  filetypes = { "python" },
  root_markers = { "pyproject.toml", ".ruff.toml", ".ruff.ini", ".flake8" },
  cmd = { home .. "/.local/share/nvim/mason/bin/ruff", "server" },
}
