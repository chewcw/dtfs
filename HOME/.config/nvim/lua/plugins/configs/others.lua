local M = {}
local utils = require("core.utils")

M.blankline = {
  -- indentLine_enabled = 1,
  -- buftype_exclude = {
  --   "terminal",
  --   "quickfix",
  --   "nofile",
  --   "prompt",
  -- },
  -- show_trailing_blankline_indent = false,
  -- show_first_indent_level = true,
  -- char = "│",
  -- context_char = "│",
  scope = {
    enabled = true,
    show_start = false,
    show_end = false,
    char = "",
    highlight = {
      "IndentBlanklineScope",
    },
  },
  exclude = {
    filetypes = {
      "help",
      "terminal",
      "lazy",
      "lspinfo",
      "TelescopePrompt",
      "TelescopeResults",
      "mason",
      "",
    },
    buftypes = {
      "^fugitive:.*",
      "terminal",
      "nofile",
      "quickfix",
      "prompt",
    },
  },
  indent = {
    char = "│",
  },
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
    add = { text = "+" },
    change = { text = "±" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
    untracked = { text = "┆" },
  },
  signs_staged = {
    add = { text = "+" },
    change = { text = "±" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
    untracked = { text = "┆" },
  },
  signs_staged_enable = true,
  on_attach = function(bufnr)
    utils.load_mappings("gitsigns", { buffer = bufnr, silent = true })
  end,
}

M.webdevicons = {
  default = true,
  strict = true,
}

M.workspaces = {
  hooks = {
    open_pre = {
      "TabAutoCwd 0",      -- if using workspaces, don't need auto cwd
      "TabCwdByProject 1", -- each tab represent each workspace selected from workspaces
      "TabCwd 3",          -- if using workspaces, the tab show the workspace name
    },
    -- open = {
    --   "Telescope find_files",
    -- },
  },
  cd_type = "tab",
}

M.whichkey = {
  win = {
    border = "single",
  },
}

M.nvim_autopairs = {
  enable_afterquote = false,
}

M.treesitter_context = {
  -- separator = "⏤",
  max_lines = 0,
  multiline_threshold = 10,
  mode = "cursor",
}

M.treesitter_textobjects = {
  textobjects = {
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["i,"] = "@parameter.inner",
        ["a,"] = "@parameter.outer",
        -- You can optionally set descriptions to the mappings (used in the desc parameter of
        -- nvim_buf_set_keymap) which plugins like which-key display
        ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
        -- You can also use captures from other query groups like `locals.scm`
        ["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },
        -- Markdown code blocks (fenced by ```)
        ["a`"] = { query = "@block.outer", desc = "Select a markdown code block (with backticks)" },
        ["i`"] = { query = "@block.inner", desc = "Select inside a markdown code block" },
      },
      -- You can choose the select mode (default is charwise 'v')
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * method: eg 'v' or 'o'
      -- and should return the mode ('v', 'V', or '<c-v>') or a table
      -- mapping query_strings to modes.
      selection_modes = {
        ['@parameter.outer'] = 'v', -- charwise
        ['@function.outer'] = 'V',  -- linewise
        ['@class.outer'] = 'V',     -- linewise
        ['@block.outer'] = 'V',     -- linewise
      },
      -- If you set this to `true` (default is `false`) then any textobject is
      -- extended to include preceding or succeeding whitespace. Succeeding
      -- whitespace has priority in order to act similarly to eg the built-in
      -- `ap`.
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * selection_mode: eg 'v'
      -- and should return true or false
      include_surrounding_whitespace = true,
    },
    swap = {
      enable = true,
      swap_next = {
        ["<leader>wa"] = "@parameter.inner",
      },
      swap_previous = {
        ["<leader>wA"] = "@parameter.inner",
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = { query = "@class.outer", desc = "Next class start" },
        ["]`"] = { query = "@block.outer", desc = "Next block start" },

        -- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queries.
        ["]o"] = "@loop.*",
        -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }

        -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
        -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
        -- ["]s"] = { query = "@local.scope", query_group = "locals", desc = "Next scope" },
        -- ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer",
        ["]O"] = "@loop.*",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
        ["[o"] = "@loop.*",
        ["[`"] = { query = "@block.outer", desc = "Previous block start" },
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
        ["[O"] = "@loop.*",
      },
      -- Below will go to either the start or the end, whichever is closer.
      -- Use if you want more granular movements
      -- Make it even more gradual by adding multiple queries and regex.
      goto_next = {
        ["]d"] = "@conditional.outer",
      },
      goto_previous = {
        ["[d"] = "@conditional.outer",
      }
    },
  },
}

M.diffview = function(actions)
  return {
    enhanced_diff_hl = true,
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
    file_panel = {
      -- win_config = function()
      --   local c = { type = "float" }
      --   local editor_width = vim.o.columns
      --   local editor_height = vim.o.lines
      --   c.width = math.min(100, editor_width)
      --   c.height = math.min(24, editor_height)
      --   c.col = math.floor(editor_width * 0.5 - c.width * 0.5)
      --   c.row = math.floor(editor_height * 0.5 - c.height * 0.5)
      --   return c
      -- end,
      win_config = {
        position = "bottom",
        height = 16,
        win_opts = {},
      },
    },
    keymaps = {
      view = {
        { "n", "<leader>Gl", actions.conflict_choose("ours"),       { desc = "Choose the OURS version of a conflict" } },
        { "n", "<leader>Gr", actions.conflict_choose("theirs"),     { desc = "Choose the THEIRS version of a conflict" } },
        { "n", "<leader>Gb", actions.conflict_choose("base"),       { desc = "Choose the BASE version of a conflict" } },
        { "n", "<leader>Ga", actions.conflict_choose("all"),        { desc = "Choose all the versions of a conflict" } },
        { "n", "<leader>Gx", actions.conflict_choose("none"),       { desc = "Delete the conflict region" } },
        { "n", "<leader>GL", actions.conflict_choose_all("ours"),   { desc = "Choose the OURS version of a conflict for the whole file" } },
        { "n", "<leader>GR", actions.conflict_choose_all("theirs"), { desc = "Choose the THEIRS version of a conflict for the whole file" } },
        { "n", "<leader>GB", actions.conflict_choose_all("base"),   { desc = "Choose the BASE version of a conflict for the whole file" } },
        { "n", "<leader>GA", actions.conflict_choose_all("all"),    { desc = "Choose all the versions of a conflict for the whole file" } },
        { "n", "<leader>GX", actions.conflict_choose_all("none"),   { desc = "Delete the conflict region for the whole file" } },
        { "n", "<leader>b",  actions.toggle_files,                  { desc = "Toggle the file panel" } },
        { "n", "]m",         actions.select_next_entry,             { desc = "Open the diff for the next file" } },
        { "n", "[m",         actions.select_prev_entry,             { desc = "Open the diff for the previous file" } },
      },
      file_panel = {
        { "n", "s",          actions.toggle_stage_entry,            { desc = "Stage / unstage the selected entry" } },
        { "n", "u",          actions.toggle_stage_entry,            { desc = "Stage / unstage the selected entry" } },
        { "n", "<leader>GL", actions.conflict_choose_all("ours"),   { desc = "Choose the OURS version of a conflict for the whole file" } },
        { "n", "<leader>GR", actions.conflict_choose_all("theirs"), { desc = "Choose the THEIRS version of a conflict for the whole file" } },
        { "n", "<leader>GB", actions.conflict_choose_all("base"),   { desc = "Choose the BASE version of a conflict for the whole file" } },
        { "n", "<leader>GA", actions.conflict_choose_all("all"),    { desc = "Choose all the versions of a conflict for the whole file" } },
        { "n", "<leader>GX", actions.conflict_choose_all("none"),   { desc = "Delete the conflict region for the whole file" } },
        { "n", "gq",         actions.toggle_files,                  { desc = "Toggle the file panel" } },
        { "n", "<A-q>",      actions.toggle_files,                  { desc = "Toggle the file panel" } },
      },
    },
    hooks = {
      diff_buf_win_enter = function(bufnr)
        pcall(function()
          require("gitsigns").detach(bufnr)
        end)
      end,
    },
  }
end

M.yanky = {
  ring = {
    history_length = 50,
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

M.trouble = {
  cycle_results = false,
}

return M
