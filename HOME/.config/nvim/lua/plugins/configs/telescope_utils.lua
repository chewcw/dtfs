local utils_window = require("core.utils_window")
local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

-- https://github.com/nvim-telescope/telescope.nvim/issues/2024
local last_search = nil
M.resume_with_cache = function()
  local status1, telescope = pcall(require, "telescope.builtin")
  local status2, telescope_state = pcall(require, "telescope.state")
  if status1 and status2 then
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
M.ts_select_dir_for_grep_or_find_files = function(picker_name)
  local select_cwd = function(_)
    -- this global variable is set in mappings
    -- to identify this is a "all" search - including .gitignore files
    -- or "normal" search - without .gitignore files
    local no_ignore = false
    if vim.g.find_files_type == "all" then
      no_ignore = true
    end

    local fb = require("telescope").extensions.file_browser
    -- this is live grep or find_files?
    -- local grep_or_find_files = require("telescope.builtin").live_grep
    local grep_or_find_files
    if picker_name == "find_files" then
      grep_or_find_files = require("telescope.builtin").find_files
    elseif picker_name == "live_grep" then
      grep_or_find_files = M.custom_rg
    else
      print("Unsupported picker name")
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
            attach_mappings = function(_, map)
              map("n", "<C-w>", function()
                M.set_temporary_cwd_from_file_browser("live_grep_custom")
              end)
              return true
            end,
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

M.rg_args = {
  "--follow",
  "--color=never",
  "--smart-case",
  "--no-heading",
  "--with-filename",
  "--line-number",
  "--column",
  "--auto-hybrid-regex",
}

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

  local custom_grep = finders.new_async_job({
    command_generator = function(prompt)
      if not prompt or prompt == "" then
        return nil
      end

      local prompt_split = vim.split(prompt, "  ")

      local args = { "rg" }
      table.insert(args, M.rg_args)

      if prompt_split[1] then
        table.insert(args, "-e")
        table.insert(args, prompt_split[1])
      end

      if prompt_split[2] then
        local prompt_split2_split = vim.split(prompt_split[2], " ")
        table.insert(args, prompt_split2_split)
      end

      return flatten({ args })
    end,
    entry_maker = make_entry.gen_from_vimgrep(opts),
    cwd = opts.cwd,
  })

  pickers
      .new(opts, {
        debounce = 100,
        prompt_title = "Live Grep (custom)",
        finder = custom_grep,
        previewer = conf.values.grep_previewer(opts),
        sorter = require("telescope.sorters").empty(),
        attach_mappings = function(_, map)
          map("i", "<C-f>", M.ts_select_dir_for_grep_or_find_files("live_grep"))
          map("n", "<C-f>", M.ts_select_dir_for_grep_or_find_files("live_grep"))
          map("n", "<C-w>", M.set_temporary_cwd_from_file_browser("live_grep_custom"))
          return true
        end,
      })
      :find()
end

-- Function to delete the current buffer and prompt for the next buffer using Telescope
M.delete_and_select_buffer = function()
  local buffer_utils = require("plugins.configs.buffer_utils")
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
    local deleted = buffer_utils.force_delete_buffer_create_new()
    if not deleted then
      return
    end

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
      require("telescope.builtin").buffers({
        cwd_only = true,
        attach_mappings = function(_, map)
          map("i", "<CR>", function()
            vim.api.nvim_command("buffer " .. next_bufnr)
            require("telescope.actions").close()
          end)
          map("n", "q", function() -- not selecting buffer, just close the window
            vim.cmd("q!")     -- close the telescope picker
            vim.cmd("wincmd c") -- close the window
          end)
          return true
        end,
      })
    end
  else
    -- If it's the last buffer, create a new blank buffer
    vim.cmd("enew")

    -- Delete the original buffer without closing the window
    buffer_utils.force_delete_buffer_create_new()
  end
end

-- Function to delete the current buffer and prompt for the oldfiles using Telescope
M.delete_and_select_old_buffer = function()
  local buffer_utils = require("plugins.configs.buffer_utils")
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
    local deleted = buffer_utils.force_delete_buffer_create_new()
    if not deleted then
      return
    end

    -- Open oldfiles
    -- vim.cmd("Telescope oldfiles ignore_current_buffer=true cwd_only=true")
    require("telescope.builtin").oldfiles({
      cwd_only = true,
      ignore_current_buffer = true,
      attach_mappings = function(_, map)
        map("n", "q", function() -- not selecting old file, just close the window
          pcall(function()
            vim.cmd("q!")    -- close the telescope picker
            vim.cmd("wincmd c") -- close the window
          end)
        end)
        return true
      end,
    })
  else
    -- If it's the last buffer, create a new blank buffer
    vim.cmd("enew")

    -- Delete the original buffer without closing the window
    buffer_utils.force_delete_buffer_create_new()
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
  if vim.fn.expand("%:e") == "cs" then
    require("omnisharp_extended").telescope_lsp_definitions(opts)
    return
  end
  require("telescope.builtin").lsp_definitions(opts)
end

-- Function to open new split and prompt for the oldfiles using Telescope
M.open_new_split_and_select_buffer = function(split_type)
  -- Split type
  if split_type == "vertical" then
    vim.cmd("vnew")
  else
    vim.cmd("new")
  end

  -- Open find files
  vim.cmd("let g:find_files_type='normal'")
  require("telescope.builtin").find_files({
    follow = true,
    attach_mappings = function(_, map)
      map("n", "q", function() -- not selecting file, just close the window
        pcall(function()
          vim.cmd("q!")     -- close the telescope picker
          vim.cmd("wincmd c") -- close the window
        end)
      end)
      return true
    end,
  })
end

M.open_new_tab_and_select_buffer = function()
  vim.cmd("tabnew")

  -- Open find files
  vim.cmd("let g:find_files_type='normal'")
  require("telescope.builtin").find_files({
    follow = true,
    attach_mappings = function(_, map)
      map("n", "q", function() -- not selecting file, just close the window
        pcall(function()
          vim.cmd("q!")     -- close the telescope picker
          vim.cmd("tabclose") -- close the tab
        end)
      end)
      return true
    end,
  })
end

-- Don't preview binary file
-- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#dont-preview-binaries
M.dont_preview_binaries = function()
  local previewers = require("telescope.previewers")
  local Job = require("plenary.job")
  local new_maker = function(filepath, bufnr, opts)
    filepath = vim.fn.expand(filepath)
    Job:new({
      command = "file",
      args = { "--mime-type", "-b", filepath },
      on_exit = function(j)
        local binary_mime_patterns = {
          "application/octet-stream",
          "image/",
          "video/",
          "audio/",
          "application/zip",
          "application/x-executable",
          "application/vnd.microsoft.portable-executable",
        }

        for _, pattern in ipairs(binary_mime_patterns) do
          if j:result()[1]:match(pattern) then
            vim.schedule(function()
              vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "BINARY" })
            end)
            break
          end
        end

        previewers.buffer_previewer_maker(filepath, bufnr, opts)
      end,
    }):sync()
  end
  return new_maker
end

M.force_delete_buffer = function(prompt_bufnr)
  local current_picker = action_state.get_current_picker(prompt_bufnr)
  local selected_entry = action_state.get_selected_entry()

  if selected_entry then
    vim.api.nvim_buf_delete(selected_entry.bufnr, { force = true })
    current_picker:refresh(current_picker.finder, { reset_prompt = true })
    vim.schedule(function()
      actions._close(prompt_bufnr, true)  -- Close the current Telescope window
      require("telescope.builtin").buffers() -- Reopen the buffer picker
    end)
  end
end

-- Say i am opening live_grep or find_files in a cwd called A, i want to search files
-- in another directory B, i call this function to temporarily select another cwd, to
-- search the files I want, and open it.
M.set_temporary_cwd_from_file_browser = function(picker_name)
  return function(prompt_bufnr)
    -- Open the file_browser picker
    local fb = require("telescope").extensions.file_browser
    fb.file_browser({
      prompt_title = "Select temporary cwd",
      attach_mappings = function(_, map)
        -- Replace the default select action with custom behavior
        map("i", "<CR>", function()
          local selection = action_state.get_selected_entry()
          local selected_path = selection.path

          if vim.fn.isdirectory(selected_path) == 1 then
            -- Replace default action to open picker with new cwd
            actions.select_default:replace(function()
              -- Open the specified picker with the selected cwd
              if picker_name == "find_files" then
                builtin.find_files({ cwd = selected_path })
              elseif picker_name == "live_grep" then
                builtin.live_grep({ cwd = selected_path })
              elseif picker_name == "buffers" then
                builtin.buffers({ cwd = selected_path })
              elseif picker_name == "live_grep_custom" then
                M.custom_rg({
                  cwd = selected_path,
                })
              else
                print("Unsupported picker name")
              end
            end)

            -- Trigger the replaced action
            actions.select_default(prompt_bufnr)
          else
            print("Selected item is not a directory")
          end
        end)
        return true
      end,
    })
  end
end

return M
