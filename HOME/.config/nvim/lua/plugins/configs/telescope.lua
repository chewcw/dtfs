local telescope_utils = require("plugins.configs.telescope_utils")
local buffer_utils = require("plugins.configs.buffer_utils")

local M = {}

local picker_width = vim.o.columns
local picker_height = 0.85

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
        ["<A-e>"] = require("plugins.configs.telescope_utils").open_file_in_new_tab_and_set_cwd,
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
        ["<C-l>"] = function(prompt_bufnr)
          telescope_utils.open_multiple_files_in_find_files_picker(prompt_bufnr, "edit")
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
        ["<A-e>"] = require("plugins.configs.telescope_utils").open_file_in_new_tab_and_set_cwd,
        -- toggle all
        ["<C-a>"] = require("telescope.actions").toggle_all,
        ["q"] = require("telescope.actions").close,
        ["u"] = function()
          vim.cmd("undo")
        end,
        ["<Esc>"] = function() end, -- don't do anything
        ["<C-l>"] = function(prompt_bufnr)
          telescope_utils.open_multiple_files_in_find_files_picker(prompt_bufnr, "edit")
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
          local file_path = selected_entry.path or selected_entry[1] or selected_entry.filename

          if file_path then
            local parent_dir = vim.fn.fnamemodify(file_path, ":h")
            if parent_dir then
              vim.g.new_tab_buf_cwd = parent_dir
            end
          end

          -- selected_entry.filename and row, col are for something like
          -- lsp_definitions, with filename and specific cursor position
          local row = selected_entry.lnum or 1
          local col = selected_entry.col or 1

          if not file_path or file_path == "" then
            print("Invalid file path")
            return
          end

          -- show tab's cwd
          local original_tab_cwd_visibility = vim.g.toggle_tab_cwd
          vim.g.toggle_tab_cwd = "1"

          -- vim.ui.input({ prompt = "Enter tab number: " }, function(input)
          --   pcall(function()
          --     if input then
          --       local tabnr = tonumber(input)
          --       local tabnr_ordinal = vim.api.nvim_tabpage_get_number(tabnr)
          --       if tabnr_ordinal and tabnr_ordinal > 0 and tabnr_ordinal <= vim.fn.tabpagenr("$") then
          --         vim.api.nvim_command("tabnext " .. tabnr_ordinal)
          --         vim.api.nvim_command("edit " .. file_path)
          --         vim.fn.cursor(row, col)
          --       else
          --         print("Invalid tab number: " .. input)
          --       end
          --     else
          --       print("Input canceled")
          --     end
          --   end)
          -- end)

          require("plugins.configs.telescope_tabs").list_tabs({
            title = "Open in tab",
            on_open = function(tid)
              local tabnr_ordinal = vim.api.nvim_tabpage_get_number(tid)
              vim.api.nvim_command("tabnext " .. tabnr_ordinal)
              vim.api.nvim_command("edit " .. file_path)
              vim.fn.cursor(row, col)
            end,
          })

          if original_tab_cwd_visibility ~= "1" then
            vim.g.toggle_tab_cwd = original_tab_cwd_visibility
          end
        end,
        -- toggle preview
        ["<C-p>"] = require("telescope.actions.layout").toggle_preview,
        -- copy absolute path
        ["<A-y>"] = require("plugins.configs.telescope_utils").copy_absolute_file_path_in_picker(),
        -- open previous picker
        ["<Backspace>"] = require("plugins.configs.telescope_utils").resume_with_cache,
      },
    },
  },

  extensions_list = { "file_browser", "workspaces", "ui-select", "fzf" },

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
          ["<C-f>"] = require("telescope").extensions.file_browser.actions.toggle_browser,
          -- ["<C-h>"] = require("telescope").extensions.file_browser.actions.toggle_hidden,
          ["<C-a>"] = require("telescope").extensions.file_browser.actions.toggle_all,
          ["<BS>"] = require("telescope").extensions.file_browser.actions.backspace,
          ["<C-h>"] = function()
            local keys = vim.api.nvim_replace_termcodes("<C-h>", false, false, true)
            vim.api.nvim_feedkeys(keys, "n", {})
          end,
          ["<C-l>"] = function(prompt_bufnr)
            telescope_utils.open_multiple_files_in_find_files_picker(prompt_bufnr, "edit")
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
            local enter = function(prompt_bufnr)
              telescope_utils.open_multiple_files_in_find_files_picker(prompt_bufnr, "edit")
            end
            return enter
          end)(),
          ["."] = require("telescope").extensions.file_browser.actions.toggle_hidden,
          ["<C-a>"] = require("telescope").extensions.file_browser.actions.toggle_all,
          ["s"] = function()
            local keys = vim.api.nvim_replace_termcodes("s", false, false, true)
            vim.api.nvim_feedkeys(keys, "n", {})
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
          ["g<Space>"] = require("plugins.configs.telescope_utils").go_to_directory(
            function(input, prompt_bufnr, current_line)
              -- Close the current picker
              require("telescope.actions").close(prompt_bufnr)
              if vim.g.telescope_picker_temporary_cwd_from_file_browser then
                -- just precaution
                if vim.g.telescope_picker_type == nil then
                  print("`vim.g.telescope_picker_type` is not set, use default value: find_files")
                  vim.g.telescope_picker_type = "find_files"
                end
                telescope_utils.set_temporary_cwd_from_file_browser(vim.g.telescope_picker_type, input)(
                  prompt_bufnr
                )
              else
                -- Open file_browser with the specified path
                local fb = require("telescope").extensions.file_browser
                fb.file_browser({ path = input, default_text = current_line })
              end
            end
          ),
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
          ["<A-w>"] = telescope_utils.set_temporary_cwd_from_file_browser("live_grep"),
        },
        n = {
          ["<C-f>"] = telescope_utils.ts_select_dir_for_grep_or_find_files("live_grep"),
          ["W"] = telescope_utils.set_temporary_cwd_from_file_browser("live_grep"),
        },
      },
    },

    find_files = {
      mappings = {
        i = {
          ["<C-f>"] = telescope_utils.ts_select_dir_for_grep_or_find_files("find_files"),
          ["<A-w>"] = telescope_utils.set_temporary_cwd_from_file_browser("find_files"),
          ["<CR>"] = function(prompt_bufnr)
            telescope_utils.open_multiple_files_in_find_files_picker(prompt_bufnr, "edit")
          end,
          ["<A-e>"] = function(prompt_bufnr)
            telescope_utils.open_multiple_files_in_find_files_picker_and_set_cwd(prompt_bufnr, "tabe")
          end,
          ["<A-_>"] = function(prompt_bufnr)
            telescope_utils.open_multiple_files_in_find_files_picker(prompt_bufnr, "split")
          end,
          ["<A-\\>"] = function(prompt_bufnr)
            telescope_utils.open_multiple_files_in_find_files_picker(prompt_bufnr, "vsplit")
          end,
        },
        n = {
          ["<C-f>"] = telescope_utils.ts_select_dir_for_grep_or_find_files("find_files"),
          ["W"] = telescope_utils.set_temporary_cwd_from_file_browser("find_files"),
          ["<CR>"] = function(prompt_bufnr)
            telescope_utils.open_multiple_files_in_find_files_picker(prompt_bufnr, "edit")
          end,
          ["<A-e>"] = function(prompt_bufnr)
            telescope_utils.open_multiple_files_in_find_files_picker_and_set_cwd(prompt_bufnr, "tabe")
          end,
          ["<A-_>"] = function(prompt_bufnr)
            telescope_utils.open_multiple_files_in_find_files_picker(prompt_bufnr, "split")
          end,
          ["<A-\\>"] = function(prompt_bufnr)
            telescope_utils.open_multiple_files_in_find_files_picker(prompt_bufnr, "vsplit")
          end,
        },
      },
    },

    buffers = {
      sort_lastused = true,
      sort_mru = true,
      mappings = {
        i = {
          ["<A-w>"] = telescope_utils.set_temporary_cwd_from_file_browser("buffers"),
        },
        n = {
          -- close the buffer
          ["d"] = require("telescope.actions").delete_buffer,
          ["D"] = telescope_utils.force_delete_buffer,
          -- open the selected buffer to exisiting tab by specifying the tabnr
          ["<leader>ot"] = function()
            local selected_entry = require("telescope.actions.state").get_selected_entry()
            local buffer_number = selected_entry.bufnr

            if buffer_number then
              local bufname = vim.api.nvim_buf_get_name(buffer_number)
              vim.g.new_tab_buf_cwd = vim.fn.fnamemodify(bufname, ":p:h")
            end

            -- show tab's cwd
            local original_tab_cwd_visibility = vim.g.toggle_tab_cwd
            vim.g.toggle_tab_cwd = "1"

            -- vim.ui.input({ prompt = "Enter tab number: " }, function(input)
            --   if input then
            --     local tabnr = tonumber(input)
            --     local tabnr_ordinal = vim.api.nvim_tabpage_get_number(tabnr)
            --     if tabnr_ordinal and tabnr_ordinal > 0 and tabnr_ordinal <= vim.fn.tabpagenr("$") then
            --       buffer_utils.open_buffer_in_specific_tab(tabnr_ordinal, buffer_number)
            --     else
            --       print("Invalid tab number: " .. input)
            --     end
            --   else
            --     print("Input canceled")
            --   end
            -- end)

            require("plugins.configs.telescope_tabs").list_tabs({
              title = "Open in tab",
              on_open = function(tid)
                local tabnr_ordinal = vim.api.nvim_tabpage_get_number(tid)
                buffer_utils.open_buffer_in_specific_tab(tabnr_ordinal, buffer_number)
              end,
            })

            if original_tab_cwd_visibility ~= "1" then
              vim.g.toggle_tab_cwd = original_tab_cwd_visibility
            end
          end,
          ["W"] = telescope_utils.set_temporary_cwd_from_file_browser("buffers"),
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
        i = {
          ["<A-w>"] = telescope_utils.set_temporary_cwd_from_file_browser("oldfiles"),
        },
        n = {
          ["W"] = telescope_utils.set_temporary_cwd_from_file_browser("oldfiles"),
        },
      },
    },

    grep_string = {
      mappings = {
        i = {
          ["<A-w>"] = telescope_utils.set_temporary_cwd_from_file_browser("grep_string"),
        },
        n = {
          ["W"] = telescope_utils.set_temporary_cwd_from_file_browser("grep_string"),
        },
      },
    },
  },
}

return M
