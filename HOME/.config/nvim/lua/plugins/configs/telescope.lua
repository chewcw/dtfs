local utils_window = require("core.utils_window")

-- when find_files or live_grep, the picker only shows files in the same folder
-- this function can let us select the folder as working direcotory
-- so that the picker can show all files or folders under that directory
-- reference https://github.com/nvim-telescope/telescope.nvim/issues/2201#issuecomment-1284691502
local ts_select_dir_for_grep_or_find_files = function(grep)
  local select_cwd = function(_)
    -- this global variable is set in mappings
    -- to identify this is a "all" search - including .gitignore files
    -- or "normal" search - without .gitignore files
    local no_ignore = false
    if vim.g.find_files_type == "all" then
      no_ignore = true
    end

    local action_state = require("telescope.actions.state")
    local fb = require("telescope").extensions.file_browser
    -- this is live grep or find_files?
    local grep_or_find_files = require("telescope.builtin").live_grep
    if not grep then
      grep_or_find_files = require("telescope.builtin").find_files
    end
    local current_line = action_state.get_current_line()

    fb.file_browser({
      files = false,
      depth = true,
      hidden = false,
      cwd = vim.fn.getcwd(),
      attach_mappings = function(_)
        require("telescope.actions").select_default:replace(function()
          local entry_path = action_state.get_selected_entry().Path
          local dir = entry_path:is_dir() and entry_path or entry_path:parent()
          local relative = dir:make_relative(vim.fn.getcwd())
          local absolute = dir:absolute()
          grep_or_find_files({
            results_title = relative .. "/",
            cwd = absolute,
            default_text = current_line,
            no_ignore = no_ignore,
            follow = true,
          })
        end)
        return true
      end,
    })
  end
  return select_cwd
end

local options = {
  defaults = {
    vimgrep_arguments = {
      "rg",
      "-L",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
    },
    prompt_prefix = "   ",
    selection_caret = "  ",
    entry_prefix = "  ",
    initial_mode = "normal",
    selection_strategy = "reset",
    sorting_strategy = "ascending",
    layout_strategy = "horizontal",
    preview = true,
    layout_config = {
      horizontal = {
        prompt_position = "top",
        preview_width = 0.40,
        results_width = 0.80,
      },
      vertical = {
        mirror = false,
      },
      width = 0.95,
      height = 0.95,
      preview_cutoff = 120,
    },
    fname_width = 50,
    file_sorter = require("telescope.sorters").get_fuzzy_file,
    file_ignore_patterns = { "node_modules" },
    generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
    path_display = { "truncate" },
    winblend = 0,
    border = {},
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
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
      },
      n = {
        ["<C-j>"] = require("telescope.actions").move_selection_next,
        ["<C-k>"] = require("telescope.actions").move_selection_previous,
        ["<A-\\>"] = require("telescope.actions").select_vertical,
        ["<A-_>"] = require("telescope.actions").select_horizontal,
        -- ["l"] = function()
        -- vim.fn.feedkeys("\r")
        -- end,
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
        ["<BS>"] = (function(prompt_bufnr)
          local select_window_to_open = function()
            local entry = require("telescope.actions.state").get_selected_entry(prompt_bufnr)
            -- this is a new file
            if type(entry[1]) == "string" then
              utils_window.open(entry[1], 0, 0)
              -- not a new file i.e. reference, etc.
            elseif entry.value.filename ~= nil and entry.value.lnum ~= nil and entry.value.col ~= nil then
              utils_window.open(entry.value.filename, entry.value.lnum, entry.value.col - 1)
              -- buffer
            elseif entry.filename ~= nil and entry.lnum ~= nil then
              utils_window.open(entry.filename, entry.lnum, 0)
            else
              print("invalid")
            end
          end
          return select_window_to_open
        end)(),
      },
    },
  },

  extensions_list = { "themes", "file_browser", "workspaces", "ui-select" },

  extensions = {
    file_browser = {
      path = "%:p:h",
      cwd = vim.fn.expand("%:p:h"),
      theme = "dropdown",
      grouped = true,
      hijack_netrw = false,
      hidden = true,
      initial_mode = "normal",
      layout_strategy = "horizontal",
      layout_config = {
        horizontal = {
          prompt_position = "top",
          preview_width = 0.30,
          results_width = 0.70,
        },
        vertical = {
          mirror = false,
        },
        width = 0.95,
        height = 0.95,
        preview_cutoff = 120,
      },
      mappings = {
        n = {
          ["q"] = require("telescope.actions").close,
          ["t"] = require("telescope").extensions.file_browser.actions.change_cwd,
          ["T"] = require("telescope").extensions.file_browser.actions.goto_cwd,
          ["n"] = require("telescope").extensions.file_browser.actions.create_from_prompt,
          ["h"] = require("telescope").extensions.file_browser.actions.goto_parent_dir,
          ["l"] = (function()
            local enter = function()
              vim.fn.feedkeys("\r")
            end
            return enter
          end)(),
          ["y"] = require("telescope").extensions.file_browser.actions.copy,
          ["d"] = require("telescope").extensions.file_browser.actions.remove,
          ["m"] = require("telescope").extensions.file_browser.actions.move,
          ["r"] = require("telescope").extensions.file_browser.actions.rename,
          ["."] = require("telescope").extensions.file_browser.actions.toggle_hidden,
        },
      },
    },
  },

  pickers = {
    live_grep = {
      mappings = {
        i = {
          ["<C-f>"] = ts_select_dir_for_grep_or_find_files(true),
        },
        n = {
          ["<C-f>"] = ts_select_dir_for_grep_or_find_files(true),
        },
      },
    },

    find_files = {
      mappings = {
        i = {
          ["<C-f>"] = ts_select_dir_for_grep_or_find_files(false),
        },
        n = {
          ["<C-f>"] = ts_select_dir_for_grep_or_find_files(false),
        },
      },
    },

    buffers = {
      mappings = {
        n = {
          -- close the buffer
          ["d"] = require("telescope.actions").delete_buffer,
        },
      },
    },
  },
}

return options
