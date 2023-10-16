local options = {
  ensure_installed = {
    -- lua stuff
    "lua-language-server",
    "stylua",

    -- c, c++
    "clangd",

    -- web dev
    "typescript-language-server",
    "prettierd",
    "emmet-ls",

    -- golang
    "gopls",
    "goimports",
    "delve", -- debugger

    -- dotnet
    "omnisharp",
    "csharpier",
    "netcoredbg", -- debugger

    -- python
    "pyright",
    "debugpy", -- debugger

    -- rust
    "rust-analyzer",
    "corelldb", -- debugger
  },

  PATH = "skip",

  ui = {
    icons = {
      package_pending = " ",
      package_installed = "󰄳 ",
      package_uninstalled = " 󰚌",
    },

    border = "rounded",

    keymaps = {
      toggle_server_expand = "<CR>",
      install_server = "i",
      update_server = "u",
      check_server_version = "c",
      update_all_servers = "U",
      check_outdated_servers = "C",
      uninstall_server = "X",
      cancel_installation = "<C-c>",
    },
  },

  max_concurrent_installers = 10,
}

return options
