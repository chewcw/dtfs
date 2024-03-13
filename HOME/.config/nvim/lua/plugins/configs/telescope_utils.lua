local utils_window = require("core.utils_window")

local M = {}

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

-- Function to delete the current buffer and prompt for the next buffer using Telescope
M.delete_and_select_buffer = function()
  local current_bufnr = vim.fn.bufnr("%")

  -- Get a list of buffer names before deletion
  local buffer_names_before = vim.fn.getbufinfo({ buflisted = 1 })
  local buffer_numbers_before = {}
  for _, buf in ipairs(buffer_names_before) do
      table.insert(buffer_numbers_before, buf.bufnr)
  end

  local num_buffers = vim.fn.bufnr("$")
  if num_buffers > 1 or vim.fn.buflisted(current_bufnr) == 0 then

    -- Delete the current buffer
    vim.cmd("bprevious|bdelete!" .. current_bufnr)

    -- Get a list of buffer names after deletion
    local buffer_names_after = vim.fn.getbufinfo({ buflisted = 1 })
    local buffer_numbers_after = {}
    for _, buf in ipairs(buffer_names_after) do
        table.insert(buffer_numbers_after, buf.bufnr)
    end

    -- Find the buffer that is still open after deletion
    local next_bufnr
    for _, bufnr in ipairs(buffer_numbers_before) do
        if not vim.tbl_contains(buffer_numbers_after, bufnr) then
            next_bufnr = bufnr
            break
        end
    end

    -- Open the next buffer using Telescope
    if next_bufnr then
        require('telescope.builtin').buffers({
            cwd_only = true,
            attach_mappings = function(_, map)
                map('i', '<CR>', function()
                    vim.api.nvim_command('buffer ' .. next_bufnr)
                    require('telescope.actions').close()
                end)
                return true
            end,
        })
    end
  else
    -- If it's the last buffer, create a new blank buffer
    vim.cmd("enew")

    -- Delete the original buffer without closing the window
    vim.cmd("bdelete!" .. current_bufnr)
  end
end

-- Function to delete the current buffer and prompt for the oldfiles using Telescope
M.delete_and_select_old_buffer = function()
  local current_bufnr = vim.fn.bufnr("%")

  -- Get a list of buffer names before deletion
  local buffer_names_before = vim.fn.getbufinfo({ buflisted = 1 })
  local buffer_numbers_before = {}
  for _, buf in ipairs(buffer_names_before) do
      table.insert(buffer_numbers_before, buf.bufnr)
  end

  local num_buffers = vim.fn.bufnr("$")
  if num_buffers > 1 or vim.fn.buflisted(current_bufnr) == 0 then
    -- Delete the current buffer
    vim.cmd("bprevious|bdelete!" .. current_bufnr)

    -- Open oldfiles
    vim.cmd("Telescope oldfiles ignore_current_buffer=true cwd_only=true")
  else
    -- If it's the last buffer, create a new blank buffer
    vim.cmd("enew")

    -- Delete the original buffer without closing the window
    vim.cmd("bdelete!" .. current_bufnr)
  end
end

-- Function to open lsp_definitions using Telescope, handle special case for
-- Omnisharp
M.open_lsp_definitions_conditional = function(opts)
  -- local bufnr = vim.api.nvim_get_current_buf()
  -- local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
  -- local this_bufnr = vim.api.nvim_get_current_buf()
  -- local buf_clients = vim.lsp.get_active_clients({ bufnr = this_bufnr })
  -- local clients = vim.lsp.buf_get_clients(0)

  -- for _, client in ipairs(buf_clients) do
  --   if client.name == "omnisharp" then
  --     require('omnisharp_extended').lsp_definitions()
  --   else
  --     require("telescope.builtin").lsp_definitions(opts)
  --   end
  -- end
  if vim.fn.expand('%:e') == 'cs' then
    require('omnisharp_extended').telescope_lsp_definitions(opts)
    return
  end
  require('telescope.builtin').lsp_definitions(opts)
end

-- Function to open new split and prompt for the open buffer using Telescope
M.open_new_split_and_select_buffer = function(split_type)
    -- Split type
    if split_type == 'vertical' then
      vim.cmd("vnew")
    else
      vim.cmd("new")
    end

    -- Get a list of buffer names
    local buffer_names = vim.fn.getbufinfo({ buflisted = 1 })
    local buffer_numbers = {}
    for _, buf in ipairs(buffer_names) do
        table.insert(buffer_numbers, buf.bufnr)
    end

  print(buffer_numbers)

    -- Open the next buffer using Telescope
    if buffer_numbers then
        require('telescope.builtin').buffers({
            cwd_only = true,
            attach_mappings = function(_, map)
                map('i', '<CR>', function()
                    vim.api.nvim_command('buffer ' .. buffer_numbers)
                    require('telescope.actions').close()
                end)
                return true
            end,
        })
    end
end

return M
