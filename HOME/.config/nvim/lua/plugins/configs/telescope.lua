local utils_window = require("core.utils_window")
local telescope_utils = require("plugins.configs.telescope_utils")

local M = {}

local picker_width = vim.o.columns
local picker_height = 0.45

-- https://github.com/nvim-telescope/telescope.nvim/issues/2024
local last_search = nil
M.resume_with_cache = function()
  local status1, telescope = pcall(require, "telescope.builtin")
  local status2, telescope_state = pcall(require, "telescope.state")
  if (status1 and status2) then
    if last_search == nil then
      telescope.resume()

      local cached_pickers = telescope_state.get_global_key("cached_pickers") or {}
      last_search = cached_pickers[1]
    else
      telescope.resume({ picker = last_search })
    end
  end
end

M.options = {
  defaults = {
      vimgrep_arguments = {
        "rg",
        "--follow",
        "--smart-case",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
      },
      scroll_strategy = "limit",
      prompt_prefix = "",
      selection_caret = "  ",
      entry_prefix = "  ",
      initial_mode = "normal",
      selection_strategy = "reset",
      sorting_strategy = "ascending",
      -- https://github.com/nvim-telescope/telescope.nvim/issues/848#issuecomment-1437928837
      layout_strategy = "bottom_pane",
      preview = true,
      layout_config = {
        horizontal = {
          prompt_position = "top",
          preview_width = 0.50,
          results_width = 0.50,
        },
        vertical = {
          mirror = false,
        },
        width = picker_width,
        height = picker_height,
        preview_cutoff = 120,
      },
      fname_width = 50,
      file_sorter = require("telescope.sorters").get_fuzzy_file,
      file_ignore_patterns = {},
      generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
      path_display = { "truncate" },
      winblend = 0,
      border = true,
      borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
      -- borderchars = { "=", "", "", "", "", "", "", "" },
      color_devicons = true,
      set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
      file_previewer = require("telescope.previewers").vim_buffer_cat.new,
      grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
      qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
      -- get_selection_window = function(picker, entry)
      --   -- print(inspect(picker))
      --   local s = picker.original_win_id
      --   vim.ui.input({ prompt = "Pick window: " }, function(input)
      --     s = tonumber(input)
      --   end)
      --   return s
      -- end,
      -- Developer configurations: Not meant for general override
      buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
      mappings = {
        i = {
          ["<C-j>"] = require("telescope.actions").move_selection_next,
          ["<C-k>"] = require("telescope.actions").move_selection_previous,
          ["<A-\\>"] = require("telescope.actions").select_vertical,
          ["<A-_>"] = require("telescope.actions").select_horizontal,
          ["<A-t>"] = require("telescope.actions").select_tab,
          ["<C-A-l>"] = require("telescope.actions").preview_scrolling_right,
          ["<C-A-h>"] = require("telescope.actions").preview_scrolling_left,
          ["<C-A-d>"] = require("telescope.actions").preview_scrolling_down,
          ["<C-A-u>"] = require("telescope.actions").preview_scrolling_up,
          ["<C-u>"] = require("telescope.actions").results_scrolling_up,
          ["<C-d>"] = require("telescope.actions").results_scrolling_down,
          ["<C-h>"] = function()
            local keys = vim.api.nvim_replace_termcodes('<C-h>', false, false, true)
            vim.api.nvim_feedkeys(keys, "n", {})
          end,
          ["<C-l>"] = function()
            vim.fn.feedkeys("\r")
          end,
        },
        n = {
          ["<C-j>"] = require("telescope.actions").move_selection_next,
          ["<C-k>"] = require("telescope.actions").move_selection_previous,
          ["<C-A-l>"] = require("telescope.actions").preview_scrolling_right,
          ["<C-A-h>"] = require("telescope.actions").preview_scrolling_left,
          ["<C-A-d>"] = require("telescope.actions").preview_scrolling_down,
          ["<C-A-u>"] = require("telescope.actions").preview_scrolling_up,
          ["<C-u>"] = require("telescope.actions").results_scrolling_up,
          ["<C-d>"] = require("telescope.actions").results_scrolling_down,
          ["]"] = require("telescope.actions").results_scrolling_right,
          ["["] = require("telescope.actions").results_scrolling_left,
          -- do nothing, to prevent open nvim_tree accidentally
          ["<C-n>"] = function() end,
          ["<A-\\>"] = require("telescope.actions").select_vertical,
          ["<A-_>"] = require("telescope.actions").select_horizontal,
          ["<A-t>"] = require("telescope.actions").select_tab,
          ["q"] = require("telescope.actions").close,
          ["u"] = function()
            vim.cmd("undo")
          end,
          ["<Esc>"] = function() end, -- don't do anything
          ["<C-l>"] = function()
            vim.fn.feedkeys("\r")
          end,
          ["i"] = (function()
            local insert_mode = function()
              vim.cmd("startinsert")
            end
            return insert_mode
          end)(),
          ["/"] = (function()
            local insert_mode = function()
              vim.cmd("startinsert")
            end
            return insert_mode
          end)(),
          -- select window (which split) to open
          ["<BS>"] = telescope_utils.select_window_to_open,
          -- toggle preview
          ["<C-p>"] = require("telescope.actions.layout").toggle_preview,
        },
      },
  },

  extensions_list = { "file_browser", "workspaces", "ui-select", "telescope-tabs" },

  extensions = {
    file_browser = {
      path = "%:p:h",
      cwd = vim.fn.expand("%:p:h"),
      grouped = true,
      hijack_netrw = false,
      hidden = true,
      initial_mode = "normal",
      layout_config = {
        horizontal = {
          prompt_position = "top",
          preview_width = 0.50,
          results_width = 0.50,
        },
        vertical = {
          mirror = false,
        },
        width = picker_width,
        height = picker_height,
        preview_cutoff = 120,
      },
      mappings = {
        i = {
          -- default mappings
          ["<A-c>"] = require("telescope").extensions.file_browser.actions.create,
          ["<S-CR>"] = require("telescope").extensions.file_browser.actions.create_from_prompt,
          ["<A-r>"] = require("telescope").extensions.file_browser.actions.rename,
          ["<A-m>"] = require("telescope").extensions.file_browser.actions.move,
          ["<A-y>"] = require("telescope").extensions.file_browser.actions.copy,
          ["<A-d>"] = require("telescope").extensions.file_browser.actions.remove,
          ["<C-o>"] = require("telescope").extensions.file_browser.actions.open,
          ["<C-g>"] = require("telescope").extensions.file_browser.actions.goto_parent_dir,
          ["<C-e>"] = require("telescope").extensions.file_browser.actions.goto_home_dir,
          ["<C-w>"] = require("telescope").extensions.file_browser.actions.goto_cwd,
          ["<C-t>"] = require("telescope").extensions.file_browser.actions.change_cwd,
          ["<C-f>"] = require("telescope").extensions.file_browser.actions.toggle_browser,
          -- ["<C-h>"] = require("telescope").extensions.file_browser.actions.toggle_hidden,
          ["<C-s>"] = require("telescope").extensions.file_browser.actions.toggle_all,
          ["<bs>"] = require("telescope").extensions.file_browser.actions.backspace,
          ["<C-h>"] = function()
            local keys = vim.api.nvim_replace_termcodes('<C-h>', false, false, true)
            vim.api.nvim_feedkeys(keys, "n", {})
          end,
          ["<C-l>"] = function()
            vim.fn.feedkeys("\r")
          end,
        },
        n = {
          ["q"] = require("telescope.actions").close,
          ["t"] = require("telescope").extensions.file_browser.actions.change_cwd,
          ["T"] = require("telescope").extensions.file_browser.actions.goto_cwd,
          ["n"] = require("telescope").extensions.file_browser.actions.create_from_prompt,
          ["h"] = function()
            local keys = vim.api.nvim_replace_termcodes('h', false, false, true)
            vim.api.nvim_feedkeys(keys, "n", {})
          end,
          ["l"] = function()
            local keys = vim.api.nvim_replace_termcodes('l', false, false, true)
            vim.api.nvim_feedkeys(keys, "n", {})
          end,
          ["<C-h>"] = require("telescope").extensions.file_browser.actions.goto_parent_dir,
          ["<C-l>"] = (function()
            local enter = function()
              vim.fn.feedkeys("\r")
            end
            return enter
          end)(),
          ["."] = require("telescope").extensions.file_browser.actions.toggle_hidden,
          -- default mappings
          ["c"] = require("telescope").extensions.file_browser.actions.create,
          ["r"] = require("telescope").extensions.file_browser.actions.rename,
          ["m"] = require("telescope").extensions.file_browser.actions.move,
          ["y"] = require("telescope").extensions.file_browser.actions.copy,
          ["d"] = require("telescope").extensions.file_browser.actions.remove,
          ["o"] = require("telescope").extensions.file_browser.actions.open,
          ["g"] = require("telescope").extensions.file_browser.actions.goto_parent_dir,
          ["e"] = require("telescope").extensions.file_browser.actions.goto_home_dir,
          ["w"] = require("telescope").extensions.file_browser.actions.goto_cwd,
          ["t"] = require("telescope").extensions.file_browser.actions.change_cwd,
          ["f"] = require("telescope").extensions.file_browser.actions.toggle_browser,
          -- ["h"] = require("telescope").extensions.file_browser.actions.toggle_hidden,
          ["s"] = require("telescope").extensions.file_browser.actions.toggle_all,
        },
      },
    },
  },

  pickers = {
    live_grep = {
      mappings = {
        i = {
          ["<C-f>"] = telescope_utils.ts_select_dir_for_grep_or_find_files(true),
        },
        n = {
          ["<C-f>"] = telescope_utils.ts_select_dir_for_grep_or_find_files(true),
        },
      },
    },

    find_files = {
      mappings = {
        i = {
          ["<C-f>"] = telescope_utils.ts_select_dir_for_grep_or_find_files(false),
        },
        n = {
          ["<C-f>"] = telescope_utils.ts_select_dir_for_grep_or_find_files(false),
        },
      },
    },

    buffers = {
      sort_lastused = true,
      mappings = {
        n = {
          -- close the buffer
          ["d"] = require("telescope.actions").delete_buffer,
        },
      },
    },

    jumplist = {
      show_line = false,
    },

    git_status = {
      mappings = {
        n = {
          ["<BS>"] = telescope_utils.select_window_to_open,
        },
      },
    },
  },
}

return M
