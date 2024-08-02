local telescope_utils = require("plugins.configs.telescope_utils")
local buffer_utils = require("plugins.configs.buffer_utils")

local M = {}

local picker_width = vim.o.columns
local picker_height = 0.45

M.options = {
  defaults = {
    -- remember to update telescope_utils file custom_rg as well
    vimgrep_arguments = {
      "rg",
      unpack(telescope_utils.rg_args),
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
    cache_picker = {
      num_pickers = -1,
    },
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
    buffer_previewer_maker = telescope_utils.dont_preview_binaries(),
    mappings = {
      i = {
        ["<C-j>"] = require("telescope.actions").move_selection_next,
        ["<C-k>"] = require("telescope.actions").move_selection_previous,
        ["<A-\\>"] = require("telescope.actions").select_vertical,
        ["<A-_>"] = require("telescope.actions").select_horizontal,
        ["<A-e>"] = require("telescope.actions").select_tab,
        ["<C-A-l>"] = require("telescope.actions").preview_scrolling_right,
        ["<C-A-h>"] = require("telescope.actions").preview_scrolling_left,
        ["<C-A-d>"] = require("telescope.actions").preview_scrolling_down,
        ["<C-A-u>"] = require("telescope.actions").preview_scrolling_up,
        ["<C-u>"] = require("telescope.actions").results_scrolling_up,
        ["<C-d>"] = require("telescope.actions").results_scrolling_down,
        ["<C-t>"] = require("trouble.sources.telescope").open,
        ["<C-h>"] = function()
          local keys = vim.api.nvim_replace_termcodes("<C-h>", false, false, true)
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
        ["<C-t>"] = require("trouble.sources.telescope").open,
        ["]"] = require("telescope.actions").results_scrolling_right,
        ["["] = require("telescope.actions").results_scrolling_left,
        -- do nothing, to prevent open nvim_tree accidentally
        ["<C-n>"] = function() end,
        ["<A-\\>"] = require("telescope.actions").select_vertical,
        ["<A-_>"] = require("telescope.actions").select_horizontal,
        ["<A-e>"] = require("telescope.actions").select_tab,
        -- toggle all
        ["<C-a>"] = require("telescope.actions").toggle_all,
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
        ["<leader>ow"] = telescope_utils.select_window_to_open,
        -- open the selected file to exisiting tab by specifying the tabnr
        ["<leader>ot"] = function()
          local selected_entry = require("telescope.actions.state").get_selected_entry()
          local file_path = selected_entry.path or selected_entry[1]

          vim.ui.input({ prompt = "Enter tab number: " }, function(input)
            if input then
              local tabnr = tonumber(input)
              if tabnr and tabnr > 0 and tabnr <= vim.fn.tabpagenr("$") then
                vim.api.nvim_command("tabnext " .. tabnr)
                vim.api.nvim_command("edit " .. file_path)
              else
                print("Invalid tab number: " .. input)
              end
            else
              print("Input canceled")
            end
          end)
        end,
        -- toggle preview
        ["<C-p>"] = require("telescope.actions.layout").toggle_preview,
      },
    },
  },

  extensions_list = { "file_browser", "workspaces", "ui-select", "telescope-tabs", "fzf" },

  extensions = {
    file_browser = {
      path = "%:p:h",
      -- cwd = vim.fn.expand("%:p:h"),
      -- cwd_to_path = true,
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
          ["<C-f>"] = require("telescope").extensions.file_browser.actions.toggle_browser,
          -- ["<C-h>"] = require("telescope").extensions.file_browser.actions.toggle_hidden,
          ["<C-a>"] = require("telescope").extensions.file_browser.actions.toggle_all,
          ["<BS>"] = require("telescope").extensions.file_browser.actions.backspace,
          ["<C-h>"] = function()
            local keys = vim.api.nvim_replace_termcodes("<C-h>", false, false, true)
            vim.api.nvim_feedkeys(keys, "n", {})
          end,
          ["<C-l>"] = function()
            vim.fn.feedkeys("\r")
          end,
        },
        n = {
          ["q"] = require("telescope.actions").close,
          ["t"] = function(prompt_bufnr)
            -- https://github.com/nvim-telescope/telescope-file-browser.nvim/blob/master/lua/telescope/_extensions/file_browser/actions.lua
            local action_state = require("telescope.actions.state")
            local current_picker = action_state.get_current_picker(prompt_bufnr)
            local finder = current_picker.finder
            local entry_path = action_state.get_selected_entry().Path
            local fb_utils = require("telescope._extensions.file_browser.utils")
            finder.path = entry_path:is_dir() and entry_path:absolute() or entry_path:parent():absolute()
            finder.cwd = finder.path
            vim.cmd("tcd " .. finder.path)

            fb_utils.redraw_border_title(current_picker)
            current_picker:refresh(finder, {
              new_prefix = fb_utils.relative_path_prefix(finder),
              reset_prompt = true,
              multi = current_picker._multi,
            })
            fb_utils.notify("action.change_cwd", {
              msg = "Set the current working directory for this tab!",
              level = "INFO",
              quiet = finder.quiet,
            })
          end,
          ["T"] = require("telescope").extensions.file_browser.actions.goto_cwd,
          ["n"] = require("telescope").extensions.file_browser.actions.create_from_prompt,
          ["h"] = function()
            local keys = vim.api.nvim_replace_termcodes("h", false, false, true)
            vim.api.nvim_feedkeys(keys, "n", {})
          end,
          ["l"] = function()
            local keys = vim.api.nvim_replace_termcodes("l", false, false, true)
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
          ["<C-a>"] = require("telescope").extensions.file_browser.actions.toggle_all,
          ["s"] = function()
            local keys = vim.api.nvim_replace_termcodes("s", false, false, true)
            vim.api.nvim_feedkeys(keys, "n", {})
          end,
          -- Copy absolute file path
          -- https://github.com/nvim-telescope/telescope-file-browser.nvim/issues/327#issuecomment-1793591898
          ["<C-y>"] = function()
            local entry = require("telescope.actions.state").get_selected_entry()
            local cb_opts = vim.opt.clipboard:get()
            if vim.tbl_contains(cb_opts, "unnamed") then
              vim.fn.setreg("*", entry.path)
            end
            if vim.tbl_contains(cb_opts, "unnamedplus") then
              vim.fn.setreg("+", entry.path)
            end
            vim.fn.setreg("", entry.path)
          end,
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
          -- ["t"] = require("telescope").extensions.file_browser.actions.change_cwd,
          ["f"] = require("telescope").extensions.file_browser.actions.toggle_browser,
          -- ["h"] = require("telescope").extensions.file_browser.actions.toggle_hidden,
          ["g<Space>"] = function(prompt_bufnr)
            -- Prompt for the path input
            local input = vim.fn.input("Enter absolute path: ")
            if input then
              local expanded_input = vim.fn.expand(input) -- to handle something like "~"
              if vim.fn.isdirectory(expanded_input) == 1 then
                -- Close the current picker
                require("telescope.actions").close(prompt_bufnr)
                -- Open file_browser with the specified path
                local fb = require("telescope").extensions.file_browser
                fb.file_browser({ path = input })
              else
                print("Not directory entered")
              end
            end
          end,
        },
      },
    },

    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
  },

  pickers = {
    live_grep = {
      mappings = {
        i = {
          ["<C-f>"] = telescope_utils.ts_select_dir_for_grep_or_find_files("live_grep"),
        },
        n = {
          ["<C-f>"] = telescope_utils.ts_select_dir_for_grep_or_find_files("live_grep"),
          ["<C-w>"] = telescope_utils.set_temporary_cwd_from_file_browser("live_grep"),
        },
      },
    },

    find_files = {
      mappings = {
        i = {
          ["<C-f>"] = telescope_utils.ts_select_dir_for_grep_or_find_files("find_files"),
        },
        n = {
          ["<C-f>"] = telescope_utils.ts_select_dir_for_grep_or_find_files("find_files"),
          ["<C-w>"] = telescope_utils.set_temporary_cwd_from_file_browser("find_files"),
        },
      },
    },

    buffers = {
      sort_lastused = true,
      sort_mru = true,
      mappings = {
        n = {
          -- close the buffer
          ["d"] = require("telescope.actions").delete_buffer,
          ["D"] = telescope_utils.force_delete_buffer,
          -- open the selected buffer to exisiting tab by specifying the tabnr
          ["<leader>ot"] = function()
            local selected_entry = require("telescope.actions.state").get_selected_entry()
            local buffer_number = selected_entry.bufnr

            vim.ui.input({ prompt = "Enter tab number: " }, function(input)
              if input then
                local tabnr = tonumber(input)
                if tabnr and tabnr > 0 and tabnr <= vim.fn.tabpagenr("$") then
                  buffer_utils.open_buffer_in_tab(tabnr, buffer_number)
                else
                  print("Invalid tab number: " .. input)
                end
              else
                print("Input canceled")
              end
            end)
          end,
          ["<C-w>"] = telescope_utils.set_temporary_cwd_from_file_browser("buffers"),
        },
      },
    },

    jumplist = {
      show_line = false,
    },

    git_status = {
      mappings = {
        n = {
          ["<leader>ow"] = telescope_utils.select_window_to_open,
        },
      },
    },

    oldfiles = {
      mappings = {
        n = {
          ["<C-w>"] = telescope_utils.set_temporary_cwd_from_file_browser("file_files"),
        },
      },
    },
  },
}

return M
