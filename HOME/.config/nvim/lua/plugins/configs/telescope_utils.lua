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
      vim.g.telescope_picker_type = "find_files"
      grep_or_find_files = require("telescope.builtin").find_files
    elseif picker_name == "live_grep" then
      vim.g.telescope_picker_type = "live_grep_custom"
      grep_or_find_files = M.custom_rg
    else
      print("Unsupported picker name")
    end
    local current_line = action_state.get_current_line()

    -- this function is opening the default file_browser
    -- so set below to false
    vim.g.telescope_picker_temporary_cwd_from_file_browser = false

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
              map("n", "W", function()
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

  vim.g.telescope_picker_type = "live_grep_custom"

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
          map("n", "W", M.set_temporary_cwd_from_file_browser("live_grep_custom"))
          map("n", "<A-e>", M.open_file_in_specifc_tab_and_set_cwd)
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
  vim.g.telescope_picker_type = "find_files"
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
  vim.g.telescope_picker_type = "find_files"
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
-- in another directory B, i call this function to temporarily select another cwd to
-- B, to search the files I want in B, and then open it.
M.set_temporary_cwd_from_file_browser = function(picker_name, path)
  return function(prompt_bufnr)
    -- Open the file_browser picker
    local fb = require("telescope").extensions.file_browser
    -- below global variable is set because of this scenario:
    -- 1. do global grep
    -- 2. W to open this temporary cwd file browser
    -- 3. g<Space> to go to other direcotory
    -- 4. should go back to this temporary cwd file browser instead of normal file
    -- browser
    vim.g.telescope_picker_temporary_cwd_from_file_browser = true
    vim.g.telescope_picker_type = picker_name

    local select_tmp_cwd = function()
      local selection = action_state.get_selected_entry()
      local selected_path = selection.path

      if vim.fn.isdirectory(selected_path) == 1 then
        -- Replace default action to open picker with new cwd
        actions.select_default:replace(function()
          -- Open the specified picker with the selected cwd
          if picker_name == "find_files" then
            builtin.find_files({ cwd = selected_path })
            -- this global variable is for this kind of scenario:
            -- 1. do global grep
            -- 2. W to open this temporary cwd file browser
            -- 3. select a temporary cwd
            -- 4. open a file in new tab
            -- 5. the new tab should use the selected_path parent as its cwd instead
            -- of the global grep's cwd
            vim.g.temp_cwd = selected_path
          elseif picker_name == "live_grep" then
            builtin.live_grep({ cwd = selected_path })
            vim.g.temp_cwd = selected_path
          elseif picker_name == "buffers" then
            builtin.buffers({ cwd = selected_path })
            vim.g.temp_cwd = selected_path
          elseif picker_name == "live_grep_custom" then
            M.custom_rg({
              cwd = selected_path,
            })
            vim.g.temp_cwd = selected_path
          elseif picker_name == "oldfiles" then
            builtin.oldfiles({ cwd = selected_path })
            vim.g.temp_cwd = selected_path
            -- TODO: this is not working
            -- Need to get the selected word and put it into the search opt below
            -- elseif picker_name == "grep_string" then
            --   builtin.grep_string({ cwd = selected_path, search = "" })
            --   vim.g.temp_cwd = selected_path
          else
            print("Unsupported picker name")
          end
        end)

        -- Trigger the replaced action
        actions.select_default(prompt_bufnr)
      else
        print("Selected item is not a directory")
      end
    end

    fb.file_browser({
      path = path,
      prompt_title = "Select temporary cwd",
      attach_mappings = function(_, map)
        -- Replace the default select action with custom behavior
        map("i", "<A-CR>", select_tmp_cwd)
        map("n", "<A-CR>", select_tmp_cwd)
        return true
      end,
    })
  end
end

-- Open multiple files at once
-- https://github.com/nvim-telescope/telescope.nvim/issues/1048#issuecomment-993956937
M.open_multiple_files_in_find_files_picker = function(prompt_bufnr, open_cmd)
  local picker = action_state.get_current_picker(prompt_bufnr)
  local num_selections = #picker:get_multi_selection()
  if not num_selections or num_selections <= 1 then
    actions.add_selection(prompt_bufnr)
  end
  actions.send_selected_to_qflist(prompt_bufnr)
  if open_cmd == "tabe" then
    vim.cmd("tabnew")
  elseif open_cmd == "vsplit" then
    vim.cmd("vsplit")
  elseif open_cmd == "split" then
    vim.cmd("split")
  end
  vim.cmd("cfdo " .. open_cmd)
  if open_cmd == "tabe" then
    vim.cmd("tabclose")
  elseif open_cmd == "vsplit" or open_cmd == "split" then
    vim.cmd("wincmd q")
  end
end

M.open_file_in_specifc_tab_and_set_cwd = function(prompt_bufnr)
  local selection = require("telescope.actions.state").get_selected_entry()
  if not selection then
    require("telescope.actions").select_tab(prompt_bufnr)
    return
  end

  if selection.value then
    local file_path = selection.value
    -- the selection is done after selecting a temporary cwd
    if vim.g.temp_cwd ~= nil then
      local parent_dir = vim.fn.fnamemodify(vim.g.temp_cwd, ":p:h")
      if parent_dir then
        vim.g.new_tab_buf_cwd = parent_dir
        vim.g.temp_cwd = ""
      end
      require("telescope.actions").select_tab(prompt_bufnr)
      return
    end

    if file_path then
      local parent_dir = vim.fn.fnamemodify(file_path, ":p:h")
      if parent_dir then
        vim.g.new_tab_buf_cwd = parent_dir
      end
    end
    require("telescope.actions").select_tab(prompt_bufnr)
    return
  end

  if selection.bufnr then
    local bufnr = selection.bufnr
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    vim.g.new_tab_buf_cwd = vim.fn.fnamemodify(bufname, ":p:h")
    require("telescope.actions").select_tab(prompt_bufnr)
    return
  end
end

return M
