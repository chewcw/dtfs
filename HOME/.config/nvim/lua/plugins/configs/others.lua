local M = {}
local utils = require("core.utils")

M.blankline = {
  indentLine_enabled = 1,
  filetype_exclude = {
    "help",
    "terminal",
    "lazy",
    "lspinfo",
    "TelescopePrompt",
    "TelescopeResults",
    "mason",
    "",
  },
  buftype_exclude = {
    "terminal",
    "quickfix",
    "nofile",
    "prompt",
  },
  bufname_exclude = {
    "^fugitive:.*",
  },
  show_trailing_blankline_indent = false,
  show_first_indent_level = true,
  show_current_context = true,
  show_current_context_start = false,
  char = "⸾",
  context_char = "⸾",
}

M.luasnip = function(opts)
  require("luasnip").config.set_config(opts)

  -- vscode format
  require("luasnip.loaders.from_vscode").lazy_load()
  require("luasnip.loaders.from_vscode").lazy_load({ paths = vim.g.vscode_snippets_path or "" })

  -- snipmate format
  require("luasnip.loaders.from_snipmate").load()
  require("luasnip.loaders.from_snipmate").lazy_load({ paths = vim.g.snipmate_snippets_path or "" })

  -- lua format
  require("luasnip.loaders.from_lua").load()
  require("luasnip.loaders.from_lua").lazy_load({ paths = vim.g.lua_snippets_path or "" })

  vim.api.nvim_create_autocmd("InsertLeave", {
    callback = function()
      if
          require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()]
          and not require("luasnip").session.jump_active
      then
        require("luasnip").unlink_current()
      end
    end,
  })
end

M.gitsigns = {
  signs = {
    add = { hl = "DiffAdd", text = " " },
    change = { hl = "DiffChange", text = " " },
    delete = { hl = "DiffDelete", text = " " },
    topdelete = { hl = "DiffDelete", text = " " },
    changedelete = { hl = "DiffChangeDelete", text = " " },
    untracked = { hl = "GitSignsAdd", text = " " },
  },
  on_attach = function(bufnr)
    utils.load_mappings("gitsigns", { buffer = bufnr })
  end,
}

M.webdevicons = {
  default = true,
  strict = true,
}

M.wilder = {
  modes = { ":", "/", "?" },
  next_key = "<C-j>",
  previous_key = "<C-k>",
  accept_key = "<C-l>",
  reject_key = "<C-h>",
}

M.workspaces = {
  -- hooks = {
  -- open = {
  -- "NvimTreeToggle",
  -- "Telescope file_files",
  -- },
  -- },
  cd_type = "tab",
}

M.whichkey = {
  window = {
    border = "single",
  },
}

M.nvim_autopairs = {
  enable_afterquote = false,
}

M.treesitter_context = {
  separator = "┉",
  max_lines = 5,
  multiline_threshold = 2,
  mode = "topline",
}

return M
