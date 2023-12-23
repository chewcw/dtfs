local M = {}

-- when find_files or live_grep, the picker only shows files in the same folder
-- this function can let us select the folder as working direcotory
-- so that the picker can show all files or folders under that directory
-- reference https://github.com/nvim-telescope/telescope.nvim/issues/2201#issuecomment-1284691502
M.ts_select_dir_for_grep_or_find_files = function(grep)
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
    -- local grep_or_find_files = require("telescope.builtin").live_grep
    local grep_or_find_files = M.custom_rg
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

M.select_window_to_open = function(prompt_bufnr)
  local entry = require("telescope.actions.state").get_selected_entry(prompt_bufnr)

  -- new file
  if type(entry[1]) == "string" and entry.lnum == nil and entry.col == nil then
    utils_window.open(entry[1], 0, 0)
    -- live grep
  elseif
      type(entry[1]) == "string"
      and string.match(entry[1], ":") == ":"
      and entry.lnum ~= nil
      and entry.col ~= nil
      and getmetatable(entry) ~= nil
  then
    local end_of_file_name = string.find(entry[1], ":")
    local file_name = string.sub(entry[1], 1, end_of_file_name - 1)
    local cwd = getmetatable(entry).cwd
    utils_window.open(cwd .. "/" .. file_name, entry.lnum, entry.col - 1)
    -- not a new file i.e. reference, etc.
  elseif entry.value.filename ~= nil and entry.value.lnum ~= nil and entry.value.col ~= nil then
    utils_window.open(entry.value.filename, entry.value.lnum, entry.value.col - 1)
    -- buffer
  elseif entry.filename ~= nil and entry.lnum ~= nil then
    utils_window.open(entry.filename, entry.lnum, 0)
    -- git status
  elseif type(entry[1]) ~= "string" and entry.path ~= nil then
    utils_window.open(entry.path, 0, 0)
  else
    print("invalid")
  end
end

-- able to put rg's argument after the search pattern followed by two spaces
-- in the Telescope prompt, check `rg --help` or `man rg` for more information
-- reference: https://github.com/tjdevries/config_manager/blob/master/xdg_config/nvim/lua/tj/telescope/custom/multi_rg.lua
M.custom_rg = function(opts)
  local conf = require("telescope.config")
  local finders = require("telescope.finders")
  local make_entry = require("telescope.make_entry")
  local pickers = require("telescope.pickers")
  local flatten = vim.tbl_flatten

  opts = opts or {}
  opts.cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.loop.cwd()

  local custom_grep = finders.new_async_job {
    command_generator = function(prompt)
      if not prompt or prompt == "" then
        return nil
      end

      local prompt_split = vim.split(prompt, "  ")

      local args = { "rg" }
      table.insert(args, { 
        "--follow",
        "--color=never",
        "--smart-case",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
      })

      if prompt_split[1] then
        table.insert(args, "-e")
        table.insert(args, prompt_split[1])
      end

      if prompt_split[2] then
        local prompt_split2_split = vim.split(prompt_split[2], " ")
        table.insert(args, prompt_split2_split)
      end

      return flatten { args }
    end,
    entry_maker = make_entry.gen_from_vimgrep(opts),
    cwd = opts.cwd,
  }

  pickers
    .new(opts, {
      debounce = 100,
      prompt_title = "Live Grep (custom)",
      finder = custom_grep,
      previewer = conf.values.grep_previewer(opts),
      sorter = require("telescope.sorters").empty(),
      attach_mappings = function(_, map)
        map("i", "<C-f>", M.ts_select_dir_for_grep_or_find_files(true))
        map("n", "<C-f>", M.ts_select_dir_for_grep_or_find_files(true))
        return true
      end
    })
    :find()
end

return M
