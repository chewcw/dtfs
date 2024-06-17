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
  char = "│",
  context_char = "│",
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
    add          = { text = '│' },
    change       = { text = '│' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
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
  reject_key = "<C-q>",
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
  separator = "·",
  max_lines = 5,
  multiline_threshold = 2,
  mode = "cursor",
}

M.diffview = function(actions)
  return {
    view = {
      default = {
        layout = "diff2_horizontal",
        winbar_info = true,
      },
      merge_tool = {
        layout = "diff3_mixed",
        winbar_info = true,
      },
      file_history = {
        layout = "diff2_horizontal",
        winbar_info = false,
      },
    },
    keymaps = {
      view ={
        { "n", "<leader>Gl",  actions.conflict_choose("ours"),        { desc = "Choose the OURS version of a conflict" } },
        { "n", "<leader>Gr",  actions.conflict_choose("theirs"),      { desc = "Choose the THEIRS version of a conflict" } },
        { "n", "<leader>Gb",  actions.conflict_choose("base"),        { desc = "Choose the BASE version of a conflict" } },
        { "n", "<leader>Ga",  actions.conflict_choose("all"),         { desc = "Choose all the versions of a conflict" } },
        { "n", "<leader>Gx",  actions.conflict_choose("none"),        { desc = "Delete the conflict region" } },
        { "n", "<leader>GL",  actions.conflict_choose_all("ours"),    { desc = "Choose the OURS version of a conflict for the whole file" } },
        { "n", "<leader>GR",  actions.conflict_choose_all("theirs"),  { desc = "Choose the THEIRS version of a conflict for the whole file" } },
        { "n", "<leader>GB",  actions.conflict_choose_all("base"),    { desc = "Choose the BASE version of a conflict for the whole file" } },
        { "n", "<leader>GA",  actions.conflict_choose_all("all"),     { desc = "Choose all the versions of a conflict for the whole file" } },
        { "n", "<leader>GX",  actions.conflict_choose_all("none"),    { desc = "Delete the conflict region for the whole file" } },
      },
      file_panel = {
        { "n", "u",              actions.toggle_stage_entry,             { desc = "Stage / unstage the selected entry" } },
        { "n", "<leader>GL",     actions.conflict_choose_all("ours"),    { desc = "Choose the OURS version of a conflict for the whole file" } },
        { "n", "<leader>GR",     actions.conflict_choose_all("theirs"),  { desc = "Choose the THEIRS version of a conflict for the whole file" } },
        { "n", "<leader>GB",     actions.conflict_choose_all("base"),    { desc = "Choose the BASE version of a conflict for the whole file" } },
        { "n", "<leader>GA",     actions.conflict_choose_all("all"),     { desc = "Choose all the versions of a conflict for the whole file" } },
        { "n", "<leader>GX",     actions.conflict_choose_all("none"),    { desc = "Delete the conflict region for the whole file" } },
      },
    },
  }
end

M.yanky = {
  ring = {
    history_length = 20,
    storage = "shada",
    sync_with_numbered_registers = true,
    cancel_event = "update",
    ignore_registers = { "_" },
    update_register_on_cycle = false,
  },
  system_clipboard = {
    sync_with_ring = true,
  },
  highlight = {
    on_put = false,
    on_yank = false,
  },
}

return M
