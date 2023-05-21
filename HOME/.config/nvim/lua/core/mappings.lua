local utils_comment = require("core.utils_comment")

-- n, v, i, t = mode names

local M = {}

M.general = {
  i = {
    -- navigate within insert mode
    ["<A-h>"] = { "<Left>", "move left" },
    ["<A-l>"] = { "<Right>", "move right" },
    ["<A-j>"] = { "<Down>", "move down" },
    ["<A-k>"] = { "<Up>", "move up" },
  },

  n = {
    ["<leader>n"] = { ":nohl <CR>", "clear highlights" },

    -- switch between windows
    ["<C-h>"] = { "<C-w>h", "window left" },
    ["<C-l>"] = { "<C-w>l", "window right" },
    ["<C-j>"] = { "<C-w>j", "window down" },
    ["<C-k>"] = { "<C-w>k", "window up" },

    -- Copy all
    ["<C-c>"] = { "<cmd> %y+ <CR>", "copy whole file" },

    -- line numbers
    ["<leader>ln"] = { "<cmd> set nu! <CR>", "toggle line number" },
    ["<leader>rn"] = { "<cmd> set rnu! <CR>", "toggle relative number" },

    -- Allow moving the cursor through wrapped lines with j, k, <Up> and <Down>
    -- http://www.reddit.com/r/vim/comments/2k4cbr/problem_with_gj_and_gk/
    -- empty mode is same as using <cmd> :map
    -- also don't use g[j|k] when in operator pending mode, so it doesn't alter d, y or c behaviour
    ["j"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', "move down", opts = { expr = true } },
    ["k"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', "move up", opts = { expr = true } },
    ["<Up>"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', "move up", opts = { expr = true } },
    ["<Down>"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', "move down", opts = { expr = true } },

    -- new buffer
    ["<leader>bb"] = { "<cmd> enew <CR>", "new buffer" },
    ["<leader>b\\"] = { "<cmd> vnew <CR>", "new buffer" },
    ["<leader>b_"] = { "<cmd> new <CR>", "new buffer" },

    -- marks
    ["<leader>m"] = { ':delmarks a-zA-Z0-9"^.[] <CR>', "delete all marks" },

    -- split
    ["<A-\\>"] = { ":vsplit <CR>", "split vertically" },
    ["<A-_>"] = { ":split <CR>", "split horizontally" },
    ["<A-=>"] = { ":resize +5 <CR>", "resize horizontally" },
    ["<A-->"] = { ":resize -5 <CR>", "resize horizontally" },
    ["<A-]>"] = { ":vertical resize +5 <CR>", "resize vertically" },
    ["<A-[>"] = { ":vertical resize -5 <CR>", "resize vertically" },

    -- macro
    ["-"] = { "@@", "repeat macro" },

    -- tab
    ["<A-S-t>"] = { ":tabedit <CR>", "new tab" },
    ["<A-S-w>"] = { ":tabclose <CR>", "close tab" },
    ["<A-S-h>"] = { ":tabprevious <CR>", "previous tab" },
    ["<A-S-l>"] = { ":tabnext <CR>", "next tab" },

    -- link
    ["gx"] = { ":execute '!xdg-open ' .. shellescape(expand('<cfile>'), v:true)<CR>", "open link" },

    -- wrap
    ["gw"] = { "<cmd> set wrap! <CR>", "toggle line wrapping" },

    -- insert new line above
    ["<A-CR>"] = { "O<Esc>" },

    -- write comment
    ["<leader>ch"] = { utils_comment.insert_comment_with_trails, "write comment with trails" },
    ["<leader>cs"] = { utils_comment.insert_comment_with_solid_line, "write comment with solid line" },
    ["<leader>cH"] = { utils_comment.insert_comment_with_header, "write comment with header" },
  },

  v = {
    ["<Up>"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', "move up", opts = { expr = true } },
    ["<Down>"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', "move down", opts = { expr = true } },
  },

  x = {
    ["j"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', "move down", opts = { expr = true } },
    ["k"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', "move up", opts = { expr = true } },
    -- Don't copy the replaced text after pasting in visual mode
    -- https://vim.fandom.com/wiki/Replace_a_word_with_yanked_text#Alternative_mapping_for_paste
    ["p"] = { 'p:let @+=@0<CR>:let @"=@0<CR>', "dont copy replaced text", opts = { silent = true } },
  },

  c = {
    ["<A-k>"] = { "<Up>", "move up in command mode" },
    ["<A-j>"] = { "<Down>", "move down in command mode" },
    ["<A-h>"] = { "<Left>", "move backward in command mode" },
    ["<A-l>"] = { "<Right>", "move forward in command mode" },
  },
}

M.tabufline = {
  plugin = true,

  n = {
    -- cycle through buffers
    ["<A-l>"] = {
      function()
        require("nvchad_ui.tabufline").tabuflineNext()
      end,
      "goto next buffer",
    },

    ["<A-h>"] = {
      function()
        require("nvchad_ui.tabufline").tabuflinePrev()
      end,
      "goto prev buffer",
    },

    -- close buffer + hide terminal buffer
    ["<A-w>"] = {
      function()
        require("nvchad_ui.tabufline").close_buffer()
      end,
      "close buffer",
    },

    ["<A-d>"] = { "<cmd> bd! <CR>", "delete the buffer from buffer list" },
  },
}

M.lspconfig = {
  plugin = true,

  -- See `<cmd> :help vim.lsp.*` for documentation on any of the below functions

  n = {
    -- ["gD"] = {
    -- 	function()
    -- 		vim.lsp.buf.declaration()
    -- 	end,
    -- 	"lsp declaration",
    -- },

    -- ["gd"] = {
    -- 	function()
    -- 		vim.lsp.buf.definition()
    -- 	end,
    -- 	"lsp definition",
    -- },

    ["gh"] = {
      function()
        vim.lsp.buf.hover()
      end,
      "lsp hover",
    },

    -- ["gi"] = {
    -- 	function()
    -- 		vim.lsp.buf.implementation()
    -- 	end,
    -- 	"lsp implementation",
    -- },

    ["<leader>ls"] = {
      function()
        vim.lsp.buf.signature_help()
      end,
      "lsp signature_help",
    },

    -- ["<leader>D"] = {
    -- 	function()
    -- 		vim.lsp.buf.type_definition()
    -- 	end,
    -- 	"lsp definition type",
    -- },

    ["gn"] = {
      function()
        require("nvchad_ui.renamer").open()
      end,
      "lsp rename",
    },

    ["g."] = {
      function()
        vim.lsp.buf.code_action()
      end,
      "lsp code_action",
    },

    -- ["gr"] = {
    -- 	function()
    -- 		vim.lsp.buf.references()
    -- 	end,
    -- 	"lsp references",
    -- },

    -- ["<leader>f"] = {
    -- 	function()
    -- 		vim.diagnostic.open_float({ border = "rounded" })
    -- 	end,
    -- 	"floating diagnostic",
    -- },

    ["ge"] = {
      function()
        vim.diagnostic.open_float()
      end,
      "show diagnostics message",
    },

    ["gE"] = {
      function()
        if vim.diagnostic.config().virtual_text then
          vim.diagnostic.config({ virtual_text = false })
        else
          vim.diagnostic.config({ virtual_text = true })
        end
      end,
      "show diagnostics message",
    },

    ["[d"] = {
      function()
        vim.diagnostic.goto_prev()
      end,
      "goto prev",
    },

    ["]d"] = {
      function()
        vim.diagnostic.goto_next()
      end,
      "goto_next",
    },

    -- ["<leader>q"] = {
    -- 	function()
    -- 		vim.diagnostic.setloclist()
    -- 	end,
    -- 	"diagnostic setloclist",
    -- },

    ["<A-f>"] = {
      function()
        vim.lsp.buf.format({ async = true })
      end,
      "Format document",
    },

    -- ["<leader>wa"] = {
    -- 	function()
    -- 		vim.lsp.buf.add_workspace_folder()
    -- 	end,
    -- 	"add workspace folder",
    -- },

    -- ["<leader>wr"] = {
    -- 	function()
    -- 		vim.lsp.buf.remove_workspace_folder()
    -- 	end,
    -- 	"remove workspace folder",
    -- },

    -- ["<leader>wl"] = {
    -- 	function()
    -- 		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    -- 	end,
    -- 	"list workspace folders",
    -- },
  },
}

M.nvimtree = {
  plugin = true,

  n = {
    -- toggle
    ["<C-n>"] = { "<cmd> NvimTreeToggle <CR>", "toggle nvimtree" },
  },
}

M.telescope = {
  plugin = true,

  n = {
    -- file browser
    ["<leader>fs"] = { "<cmd> Telescope file_browser <CR>", "file browser" },

    -- find
    -- set global variable here so that the telescope picker knows this is a normal finder
    -- see telescope config file for more information
    ["<leader>ff"] = { "<cmd> let g:find_files_type='normal' | Telescope find_files <CR>", "find files" },
    ["<leader>fa"] = {
      "<cmd> let g:find_files_type='all' | Telescope find_files follow=true no_ignore=true hidden=true <CR>",
      "find all",
    },
    ["<leader>fg"] = { "<cmd> Telescope live_grep <CR>", "live grep" },
    ["<leader>fb"] = { "<cmd> Telescope buffers <CR>", "find buffers" },
    ["<leader>fh"] = { "<cmd> Telescope help_tags <CR>", "help page" },
    ["<leader>fo"] = { "<cmd> Telescope oldfiles <CR>", "find oldfiles" },
    ["<leader>fz"] = { "<cmd> Telescope current_buffer_fuzzy_find <CR>", "find in current buffer" },
    ["<leader>f*"] = { "<cmd> Telescope grep_string <CR>", "search for string under cursor in cwd" },

    -- git
    ["<leader>gc"] = { "<cmd> Telescope git_commits <CR>", "git commits" },
    ["<leader>gt"] = { "<cmd> Telescope git_status <CR>", "git status" },

    -- theme switcher
    ["<leader>th"] = { "<cmd> Telescope themes <CR>", "nvchad themes" },

    -- terminal switcher
    ["<leader>tt"] = { "<cmd> TermSelect <CR>", "select terminal" },

    -- workspaces
    ["<leader>fw"] = { "<cmd> Telescope workspaces <CR>", "list workspaces" },

    -- lsp
    ["gi"] = { "<cmd> Telescope lsp_implementations show_line=false <CR>", "lsp implementation" },
    ["gI"] = {
      "<cmd> Telescope lsp_implementations show_line=false jump_type=never <CR>",
      "lsp implementation in vsplit",
    },
    ["gr"] = { "<cmd> Telescope lsp_references show_line=false <CR>", "lsp references" },
    ["gR"] = { "<cmd> Telescope lsp_references show_line=false jump_type=never <CR>", "lsp references in vsplit" },
    ["gd"] = { "<cmd> Telescope lsp_definitions show_line=false <CR>", "lsp definitions" },
    ["gD"] = {
      "<cmd> Telescope lsp_definitions show_line=false jump_type=never <CR>",
      "lsp definitions in vsplit",
    },
    ["gt"] = { "<cmd> Telescope lsp_type_definitions show_line=false <CR>", "lsp type definitions" },
    ["gT"] = {
      "<cmd> Telescope lsp_type_definitions show_line=false jump_type=never <CR>",
      "lsp type definitions in vsplit",
    },
    ["gs"] = { "<cmd> Telescope lsp_document_symbols symbol_width=60 <CR>", "lsp document symbols" },
    ["gS"] = { "<cmd> Telescope lsp_workspace_symbols  symbol_width=60 <CR>", "lsp workspace symbols" },

    -- diagnostic
    ["<leader>fQ"] = { "<cmd> Telescope diagnostics <CR>", "open workspace diagnostics" },
    ["<leader>fq"] = { "<cmd> Telescope diagnostics bufnr=0 <CR>", "open current buffer diagnostics" },
  },
}

M.whichkey = {
  plugin = true,

  n = {
    ["<leader>wK"] = {
      function()
        vim.cmd("WhichKey")
      end,
      "which-key all keymaps",
    },
    ["<leader>wk"] = {
      function()
        local input = vim.fn.input("WhichKey: ")
        vim.cmd("WhichKey " .. input)
      end,
      "which-key query lookup",
    },
  },
}

M.blankline = {
  plugin = true,

  n = {
    ["<leader>cc"] = {
      function()
        local ok, start = require("indent_blankline.utils").get_current_context(
          vim.g.indent_blankline_context_patterns,
          vim.g.indent_blankline_use_treesitter_scope
        )

        if ok then
          vim.api.nvim_win_set_cursor(vim.api.nvim_get_current_win(), { start, 0 })
          vim.cmd([[normal! _]])
        end
      end,

      "Jump to current_context",
    },
  },
}

M.gitsigns = {
  plugin = true,

  n = {
    -- Navigation through hunks
    ["]c"] = {
      function()
        if vim.wo.diff then
          return "]c"
        end
        vim.schedule(function()
          require("gitsigns").next_hunk()
        end)
        return "<Ignore>"
      end,
      "Jump to next hunk",
      opts = { expr = true },
    },

    ["[c"] = {
      function()
        if vim.wo.diff then
          return "[c"
        end
        vim.schedule(function()
          require("gitsigns").prev_hunk()
        end)
        return "<Ignore>"
      end,
      "Jump to prev hunk",
      opts = { expr = true },
    },

    -- Actions
    ["<leader>gr"] = {
      function()
        require("gitsigns").reset_hunk()
      end,
      "Reset hunk",
    },

    ["<leader>gp"] = {
      function()
        require("gitsigns").preview_hunk()
      end,
      "Preview hunk",
    },

    ["<leader>gb"] = {
      function()
        package.loaded.gitsigns.blame_line()
      end,
      "Blame line",
    },

    ["<leader>gd"] = {
      function()
        require("gitsigns").toggle_deleted()
      end,
      "Toggle deleted",
    },
  },
}

M.easymotion = {
  plugin = true,

  n = {
    ["<leader>s"] = {
      "<Plug>(easymotion-s)",
      "Easymotion search 1 character",
    },
    ["<leader>S"] = {
      "<Plug>(easymotion-s2)",
      "Easymotion search 2 character",
    },
  },
}

M.toggleterm = {
  plugin = true,

  n = {
    ["<A-.>"] = { ":ToggleTerm direction=horizontal <CR>", "toggle term in horizontal mode" },
  },

  t = {
    ["<A-.>"] = { ":ToggleTerm direction=horizontal <CR>", "toggle term in horizontal mode" },
    ["<Esc>"] = { vim.api.nvim_replace_termcodes("<C-\\><C-N>", true, true, true), "escape terminal mode" },
  },
}

M.codeium = {
  plugin = true,

  i = {
    ["<A-\\>"] = {
      function()
        return vim.fn["codeium#Accept"]()
      end,
      opts = { expr = true },
    },
  },
}

-- these are mappings and configuration for vim-visual-multi
M.vm = {
  plugin = true,

  init = function()
    vim.cmd("let g:VM_default_mappings = 0")
    vim.cmd("let g:VM_maps = {}")
    vim.cmd("let g:VM_mouse_mappings = 1")
    vim.cmd('let g:VM_maps["Find Under"] = "gb"')
    vim.cmd('let g:VM_maps["Find Subword Under"] = "gB"')
    vim.cmd('let g:VM_maps["Select Cursor Down"] = "<M-C-j>"')
    vim.cmd('let g:VM_maps["Select Cursor Up"] = "<M-C-k>"')
    vim.cmd('let g:VM_maps["Skip Region"] = "<M-C-x>"')
    vim.cmd("let g:VM_set_statusline = 0")
    vim.cmd("let g:VM_silent_exit = 1")
  end,
}

return M
