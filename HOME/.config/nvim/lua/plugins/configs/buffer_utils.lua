local utils_window = require("core.utils_window")

M = {}

M.force_delete_buffer_switch_to_next = function()
  local current_bufnr = vim.fn.bufnr("%") -- Get the buffer number of the current buffer
  local buffer_type = vim.api.nvim_get_option_value("buftype", { buf = current_bufnr })
  if buffer_type == "nofile" then
    M.switch_to_next_buffer_in_cwd()
  end

  M.force_delete_buffer_create_new()
  M.switch_to_next_buffer_in_cwd()
end

M.force_delete_buffer_switch_to_previous = function()
  local current_bufnr = vim.fn.bufnr("%") -- Get the buffer number of the current buffer
  local buffer_type = vim.api.nvim_get_option_value("buftype", { buf = current_bufnr })
  if buffer_type == "nofile" then
    M.switch_to_previous_buffer_in_cwd()
  end

  M.force_delete_buffer_create_new()
  M.switch_to_previous_buffer_in_cwd()
end

-- Function to force delete buffer and show new buffer
M.force_delete_buffer_create_new = function()
  pcall(function()
    local current_bufnr = vim.fn.bufnr("%") -- Get the buffer number of the current buffer

    -- If modified ask for permission
    if vim.bo[current_bufnr].modified then
      local choice = vim.fn.confirm("Buffer is modified. Do you want to delete it?")
      if choice == 1 then
        -- Delete the current buffer
        local bufname = vim.api.nvim_buf_get_name(0) -- Get the name of the current buffer
        if bufname == "" then
          M.force_delete_buffer_keep_tab(current_bufnr)
          return true
        end

        M.force_delete_buffer_keep_tab(current_bufnr)
        return true
      end
    else
      -- Buffer is not modified, just delete it
      M.force_delete_buffer_keep_tab(current_bufnr)
      return true
    end
    return false
  end)
end

M.force_delete_buffer_keep_tab = function(bufnr)
  -- Check if the buffer number is valid
  if not bufnr or bufnr == 0 then
    print("Invalid buffer number.")
    return
  end

  -- Check if the buffer is empty
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local is_empty = true
  for _, line in ipairs(lines) do
    if line ~= "" then
      is_empty = false
      break
    end
  end

  -- Check the buffer type
  local buffer_type = "nofile"
  buffer_type = vim.api.nvim_get_option_value("buftype", { buf = bufnr })

  -- Check the file type
  local is_no_filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr }) == ""

  local scratch

  -- Check if there is any split window in current tab
  local windows = vim.api.nvim_tabpage_list_wins(0) -- Get the list of windows in the current tab
  local is_split = #windows > 1

  -- If this is not empty buffer, delete the buffer,
  -- otherwise don't delete, to prevent delete the tab accidentally.
  if is_empty and buffer_type == "nofile" then
    if is_split then
      local choice = vim.fn.confirm(
        "Close the window?"
      )
      if choice == 1 then
        vim.cmd("wincmd q")
      end
    else
      local choice =
          vim.fn.confirm("Close the tab?")
      if choice == 1 then
        require("core.utils").close_and_focus_previous_tab()
      end
    end
  else
    -- Iterate through all tab pages
    for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
      -- Get all windows in the tab
      windows = vim.api.nvim_tabpage_list_wins(tabpage)
      for _, win in ipairs(windows) do
        -- Check if the window is displaying the buffer to delete
        if vim.api.nvim_win_get_buf(win) == bufnr then
          -- Get all empty scratch buffers
          local empty_scratch_buffers = M.get_empty_scratch_buffers()
          -- If there is any other scratch buffer, if yes use that scratch buffer.
          -- This is to prevent too many scratch buffer opened.
          if empty_scratch_buffers ~= nil and #empty_scratch_buffers >= 1 then
            -- Check if any scratch buffer is empty, if yes use that scratch buffer, otherwise create a new one
            for _, scratch_bufnr in ipairs(empty_scratch_buffers) do
              -- Check if the buffer is empty
              lines = vim.api.nvim_buf_get_lines(scratch_bufnr, 0, -1, false)
              is_empty = true
              for _, line in ipairs(lines) do
                if line ~= "" then
                  is_empty = false
                  break
                end
              end

              if is_empty and is_no_filetype then
                scratch = scratch_bufnr
                -- Set the buffer to that empty scratch buffer
                vim.api.nvim_win_set_buf(win, scratch)
                break
              else -- Create new scratch buffer
                scratch = vim.api.nvim_create_buf(true, true)
                vim.api.nvim_set_option_value("buftype", "nofile", { buf = scratch })
                vim.api.nvim_set_option_value("bufhidden", "unload", { buf = scratch })
                vim.api.nvim_set_option_value("swapfile", false, { buf = scratch })
                -- Set the buffer to that scratch buffer
                vim.api.nvim_win_set_buf(win, scratch)
              end
            end
          else -- There are none scratch buffers in the memory
            -- Create new scratch buffer
            scratch = vim.api.nvim_create_buf(true, true)
            vim.api.nvim_set_option_value("buftype", "nofile", { buf = scratch })
            vim.api.nvim_set_option_value("bufhidden", "unload", { buf = scratch })
            vim.api.nvim_set_option_value("swapfile", false, { buf = scratch })
            -- Set the buffer to that scratch buffer
            vim.api.nvim_win_set_buf(win, scratch)
          end
        end
      end
    end

    if not vim.api.nvim_buf_is_valid(scratch) then
      scratch = vim.api.nvim_create_buf(true, true)
    end

    -- Open the scratch
    -- So that the window wouldn't be closed
    vim.cmd("buffer " .. scratch)

    -- Delete the buffer
    -- The purpose of using `bdelete` is to keep the buffer in the oldfiles record,
    -- and remove the buffer from the buffer list
    vim.cmd("bdelete! " .. bufnr)
  end
end

M.get_blank_buffers = function()
  local blank_buffers = {}
  for _, bufinfo in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    local bufname = bufinfo.name
    if bufname == "" then
      table.insert(blank_buffers, bufinfo.bufnr)
    end
  end
  return blank_buffers
end

M.get_scratch_buffers = function()
  local scratch_buffers = {}
  -- Get a list of all buffers
  local buffers = vim.api.nvim_list_bufs()
  -- Iterate over each buffer and check if it's a scratch buffer
  for _, bufnr in ipairs(buffers) do
    -- Check if the buffer is a scratch buffer
    if vim.api.nvim_get_option_value("buftype", { buf = bufnr }) == "nofile" then
      table.insert(scratch_buffers, bufnr)
    end
  end
  return scratch_buffers
end

M.get_empty_scratch_buffers = function()
  local scratch_buffers = {}
  -- Get a list of all buffers
  local buffers = vim.api.nvim_list_bufs()
  -- Iterate over each buffer and check if it's a scratch buffer
  for _, bufnr in ipairs(buffers) do
    -- Check if the buffer is a scratch buffer
    if vim.api.nvim_get_option_value("buftype", { buf = bufnr }) == "nofile" then
      -- Check if the buffer is empty
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      local is_empty = true
      for _, line in ipairs(lines) do
        if line ~= "" then
          is_empty = false
          break
        end
      end
      if is_empty then
        table.insert(scratch_buffers, bufnr)
      end
    end
  end
  return scratch_buffers
end

-- Function to delete buffer and show new buffer
M.delete_buffer_create_new = function()
  -- Delete the current buffer
  pcall(function()
    local current_bufnr = vim.fn.bufnr("%")      -- Get the buffer number of the current buffer
    local bufname = vim.api.nvim_buf_get_name(0) -- Get the name of the current buffer
    if bufname == "" then
      return
    end
    vim.cmd("enew")
    vim.cmd("bdelete" .. current_bufnr)
  end)
end

M.navigate_to_previous_buffer = function()
  local current_bufnr = vim.fn.bufnr("%")          -- Get the buffer number of the current buffer
  local current_directory = vim.fn.expand("%:p:h") -- Get the directory of the current buffer
  local previous_bufnr

  -- Iterate backwards through the list of buffers
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if vim.fn.fnamemodify(bufname, ":p:h") == current_directory then
      if bufnr == current_bufnr then
        break -- Stop when reaching the current buffer
      end
      previous_bufnr = bufnr
    end
  end

  -- If a previous buffer in the same directory is found, navigate to it
  if previous_bufnr then
    vim.cmd("buffer " .. previous_bufnr)
  end
end

-- Function to navigate to the next buffer in the same working directory
M.navigate_to_next_buffer = function()
  local current_bufnr = vim.fn.bufnr("%")          -- Get the buffer number of the current buffer
  local current_directory = vim.fn.expand("%:p:h") -- Get the directory of the current buffer
  local next_bufnr

  -- Iterate forwards through the list of buffers
  local buffers = vim.api.nvim_list_bufs()
  for i = #buffers, 1, -1 do
    local bufnr = buffers[i]
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if vim.fn.fnamemodify(bufname, ":p:h") == current_directory then
      if bufnr == current_bufnr then
        break -- Stop when reaching the current buffer
      end
      next_bufnr = bufnr
    end
  end

  -- If a next buffer in the same directory is found, navigate to it
  if next_bufnr then
    vim.cmd("buffer " .. next_bufnr)
  end
end

-- Function to dynamically show listchars
M.toggle_listchars_symbol = function()
  local current_win = vim.api.nvim_get_current_win()
  -- Get the current window's list setting
  local list = vim.api.nvim_get_option_value("list", { win = current_win })
  -- Iterate over all tabpages
  for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    -- Iterate over all windows in the current tabpage
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
      -- Get the current window's list setting
      local win_list = vim.api.nvim_get_option_value("list", { win = win })
      if win_list == list then
        vim.api.nvim_set_option_value("list", not win_list, { win = win })
      end
    end
  end
end

-- Function to dynamically show newline symbol
M.toggle_newline_symbol = function()
  local newline = "eol:↲"
  if vim.o.listchars:find("eol:") then
    vim.o.listchars = string.gsub(vim.o.listchars, "," .. newline, "")
    vim.o.showbreak = ""
  else
    vim.o.listchars = vim.o.listchars .. "," .. newline
    vim.o.showbreak = "↳"
  end
end

M.get_buffers_in_cwd = function()
  local cwd = vim.fn.getcwd()
  local buffers = {}

  for _, bufinfo in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    local bufname = bufinfo.name
    if bufname ~= "" and vim.startswith(bufname, cwd) then
      table.insert(buffers, { bufinfo.bufnr, bufinfo.name })
    end
  end

  return buffers
end

M.switch_to_next_buffer_in_cwd = function()
  if not vim.o.hlsearch then
    vim.cmd("nohlsearch")
  end
  local buffers = M.get_buffers_in_cwd()
  local current_bufnr = vim.api.nvim_get_current_buf()
  local current_index = nil
  for i, buf in ipairs(buffers) do
    if buf[1] == current_bufnr then
      current_index = i
      break
    end
  end
  if current_index then
    pcall(function()
      local next_index = (current_index % #buffers) + 1
      vim.api.nvim_set_current_buf(buffers[next_index][1])
    end)
  else
    pcall(function()
      local next_index = #buffers
      vim.api.nvim_set_current_buf(buffers[next_index][1])
    end)
  end
end

M.switch_to_previous_buffer_in_cwd = function()
  if not vim.o.hlsearch then
    vim.cmd("nohlsearch")
  end
  local buffers = M.get_buffers_in_cwd()
  local current_bufnr = vim.api.nvim_get_current_buf()
  local current_index = nil
  for i, buf in ipairs(buffers) do
    if buf[1] == current_bufnr then
      current_index = i
      break
    end
  end
  if current_index then
    pcall(function()
      local previous_index = (current_index - 2) % #buffers + 1
      vim.api.nvim_set_current_buf(buffers[previous_index][1])
    end)
  else
    pcall(function()
      local previous_index = 1
      vim.api.nvim_set_current_buf(buffers[previous_index][1])
    end)
  end
end

M.open_buffer_in_specific_tab = function(tabnr, bufnr)
  -- Get the list of tab pages
  local tabpages = vim.api.nvim_list_tabpages()
  -- Check if the specified tab exists
  if tabnr < 1 or tabnr > #tabpages then
    print("Invalid tab number: " .. tabnr)
    return
  end

  -- Get the list of buffers
  local buffers = vim.api.nvim_list_bufs()
  -- Check if the specified buffer exists
  local buffer_exists = false
  for _, b in ipairs(buffers) do
    if b == bufnr then
      buffer_exists = true
      break
    end
  end

  if not buffer_exists then
    print("Invalid buffer number: " .. bufnr)
    return
  end

  if vim.g.toggle_term_opened then
    vim.cmd("wincmd q") -- first need to close this toggleterm
    vim.g.toggle_term_opened = false
  end

  -- Switch to the specified tab
  vim.api.nvim_set_current_tabpage(tabpages[tabnr])
  -- Open the specified buffer in the current window of the specified tab
  vim.api.nvim_set_current_buf(bufnr)
end

M.open_file_in_current_window = function(is_visual, count)
  local vimfetch = require("core.utils_vimfetch")
  local file
  if is_visual then
    file = vimfetch.fetch_visual(count)
  else
    file = vimfetch.fetch_cfile(count)
  end

  if file and file[1] then
    -- if this is toggleterm then close it first
    local buf_nr = vim.api.nvim_get_current_buf()
    local buf_name = vim.api.nvim_buf_get_name(buf_nr)
    if buf_name:lower():find("toggleterm") then
      vim.cmd("wincmd q")
      vim.g.toggle_term_opened = false
    end

    vim.api.nvim_command("edit " .. file[1])
    vim.fn.cursor(file[2], file[3])
  end
end

M.open_file_in_new_tab = function(is_visual, count)
  local vimfetch = require("core.utils_vimfetch")
  local file
  if is_visual then
    file = vimfetch.fetch_visual(count)
  else
    file = vimfetch.fetch_cfile(count)
  end

  if file and file[1] then
    local parent_dir = vim.fn.fnamemodify(file[1], ":h")
    if parent_dir then
      vim.g.new_tab_buf_cwd = parent_dir
    end

    vim.api.nvim_command("tabnew " .. file[1])
    vim.fn.cursor(file[2], file[3])
  end
end

M.open_file_or_buffer_in_specific_tab = function(is_visual, count)
  local vimfetch = require("core.utils_vimfetch")

  local file
  if is_visual then
    file = vimfetch.fetch_visual(count)
  else
    file = vimfetch.fetch_cfile(count)
  end

  local current_buf_nr = vim.api.nvim_get_current_buf()
  local current_win_id = vim.fn.bufwinid(current_buf_nr)

  if file == nil or #file == 0 then
    -- if no path on the cursor, then record current buffer to the file variable
    file = {}
    local buf_name = vim.api.nvim_buf_get_name(current_buf_nr)

    -- ignore if this is a term
    if buf_name:match("^term:") then
      return
    end

    -- ignore if this is fugitive
    if buf_name:match("^fugitive:") then
      return
    end

    -- ignore if this is Gll related
    if buf_name:match("/tmp/nvim.ccw/*") then
      return
    end

    file[1] = vim.fn.fnamemodify(buf_name, ":p")
    file[2], file[3] = vim.api.nvim_win_get_cursor(0)
  end

  local file_path = file[1]
  local row = file[2] or 1
  local col = file[3] or 1

  -- show tab's cwd
  local original_tab_cwd_visibility = vim.g.TabCwd
  vim.g.TabCwd = "1"

  require("plugins.configs.telescope_tabs").list_tabs({
    title = "Open in tab",
    on_open = function(tid)
      -- if there are multiple windows in current screen,
      -- close current window as we are opening current buffer in new tab anyway
      if vim.fn.winnr("$") > 1 then
        vim.api.nvim_win_close(current_win_id, false)
      end
      local tabnr_ordinal = vim.api.nvim_tabpage_get_number(tid)
      -- Switch to the specified tab
      vim.cmd("tabn " .. tabnr_ordinal)
      -- Open the file in the current window of the specified tab
      if file and file_path then
        local parent_dir = vim.fn.fnamemodify(file[1], ":h")
        if parent_dir then
          vim.g.new_tab_buf_cwd = parent_dir
        end

        vim.cmd("edit " .. file_path)
        vim.fn.cursor(row, col)
      end
    end,
  })

  if original_tab_cwd_visibility ~= "1" then
    vim.g.TabCwd = original_tab_cwd_visibility
  end
end

M.open_file_or_buffer_in_tab = function(
    is_visual,
    count,
    dont_care_just_open_in_new_tab,
    selected_entry,
    callback
)
  -- Ignore if this is certain file type or buffer type
  local file_type = vim.api.nvim_get_option_value("filetype", { buf = 0 })
  local buf_type = vim.api.nvim_get_option_value("buftype", { buf = 0 })
  if file_type == "copilot-chat" then
    return
  end
  if buf_type == "nofile" then
    return
  end

  local vimfetch = require("core.utils_vimfetch")

  if dont_care_just_open_in_new_tab == nil then
    dont_care_just_open_in_new_tab = false
  end

  if is_visual == nil then
    is_visual = false
  end

  if count == nil then
    count = 0
  end

  local command = ""
  local row = 0
  local col = 0
  local found_tab = false
  local current_buf_nr = vim.api.nvim_get_current_buf()
  local file_path = ""
  -- Check current_buf_nr file type
  local filetype = vim.fn.getbufvar(current_buf_nr, "&filetype")
  local is_called_from_oil = filetype == "oil"                   -- This is calling from Oil picker
  local is_called_from_telescope = filetype == "TelescopePrompt" -- This is calling from Telescope picker

  -- selected_entry ~= nil and callback ~= nil
  -- If the CopilotChat is installed
  if pcall(require, "CopilotChat") then
    vim.api.nvim_command("CopilotChatClose")
  end

  -- This is calling from a Telescope picker or oil
  if selected_entry ~= nil then
    file_path = selected_entry.path or selected_entry[1] or selected_entry.filename
  else
    local file
    if is_visual then
      file = vimfetch.fetch_visual(count)
    else
      file = vimfetch.fetch_cfile(count)
    end

    if file == nil or #file == 0 then
      -- if no path on the cursor, then record current buffer to the file variable
      file = {}

      local buf_name = vim.api.nvim_buf_get_name(current_buf_nr)
      -- ignore if this is a term
      if buf_name:match("^term:") then
        return
      end

      -- ignore if this is fugitive
      if buf_name:match("^fugitive:") then
        return
      end

      -- ignore if this is Gll related
      if buf_name:match("/tmp/nvim.ccw/*") then
        return
      end

      file[1] = vim.fn.fnamemodify(buf_name, ":p")
      file[2], file[3] = vim.api.nvim_win_get_cursor(0)
    end

    file_path = file[1]
    row = file[2] or 1
    col = file[3] or 1
  end

  if file_path and file_path ~= "" then
    -- special case, omnisharp_extended file
    if file_path:match("%$metadata%$") then
      if is_called_from_telescope then
        callback()
        return
      end
      if vim.g.toggle_term_opened then
        command = ":q | " -- first need to close this toggleterm
      end

      if selected_entry ~= nil then -- This is calling from Telescope picker
        command = ":q! | "
      end

      command = command .. "tabnew | buffer " .. current_buf_nr
      goto continue
    end

    if vim.g.TabAutoCwd == "1" and vim.g.TabCwdByProject == "0" then -- Auto CWD, open file in new tab with its cwd
      local parent_dir = vim.fn.fnamemodify(file_path, ":p:h")
      if dont_care_just_open_in_new_tab then
        if is_called_from_oil then
          command = ":q! | "
        end
        -- if is_called_from_telescope then
          -- command = ":q! | "
        -- end
        goto next
      end
      if parent_dir then
        -- find all tabs
        for _, tid in ipairs(vim.api.nvim_list_tabpages()) do
          local tabnr_ordinal = vim.api.nvim_tabpage_get_number(tid)
          local win_num = vim.fn.tabpagewinnr(tabnr_ordinal)
          local working_directory = vim.fn.getcwd(win_num, tabnr_ordinal)
          local cwd_name = vim.fn.fnamemodify(working_directory, ":p:h")
          if cwd_name == parent_dir then
            if vim.g.toggle_term_opened then
              command = ":q | " -- first need to close this toggleterm
            end
            if is_called_from_oil then
              command = ":q! |"
            end
            -- if current_tab_tabnr_ordinal == tabnr_ordinal then
            --   command = ":q! | "
            -- end
            -- Check if the new tab is opening fugitive related buffer, if yes then
            -- ignore that tab, open in new tab instead
            local win_id = vim.api.nvim_tabpage_get_win(tid)
            local buf_id = vim.api.nvim_win_get_buf(win_id)
            local buf_name = vim.api.nvim_buf_get_name(buf_id)
            if not buf_name:match("fugitive://") and not buf_name:match("/tmp/nvim.ccw/") then
              command = command .. "tabnext" .. tabnr_ordinal .. " | edit " .. file_path
              found_tab = true
              vim.g.new_tab_buf_cwd = vim.fn.fnamemodify(file_path, ":h")
              break
            end
          end
        end
        if not found_tab then
          if selected_entry ~= nil then -- This is calling from Telescope picker
            command = ":q! | "
          end
          if vim.g.toggle_term_opened then
            command = ":q | " -- first need to close this toggleterm
          end
          if is_called_from_oil then
            command = ":q! |"
          end
          command = command .. "tabnew " .. file_path
          vim.g.new_tab_buf_cwd = vim.fn.fnamemodify(file_path, ":h")
          goto continue
        end
      else
        print("Parent dir not found")
        return
      end
    elseif vim.g.TabAutoCwd == "0" and vim.g.TabCwdByProject == "1" then -- Auto CWD by project
      if dont_care_just_open_in_new_tab then
        if is_called_from_oil then
          command = ":q! | "
        end
        -- if is_called_from_telescope then
          -- command = ":q! | "
        -- end
        goto next
      end
      -- Not auto cwd but is cwd by project, find if that file is inside any of
      -- the tab's cwd folder tree or not
      local matched_tab_working_dirs = {}
      local matched_tab_ids = {}
      -- Get working directory of current window in current tab
      local original_tabpage = vim.api.nvim_get_current_tabpage()
      for _, tid in ipairs(vim.api.nvim_list_tabpages()) do
        local tabnr_ordinal = vim.api.nvim_tabpage_get_number(tid)
        -- Temporarily switch to the tab to get its cwd
        vim.api.nvim_set_current_tabpage(tid)

        local win_num = vim.fn.tabpagewinnr(tabnr_ordinal)
        local working_directory = vim.fn.getcwd(win_num, tabnr_ordinal)
        local file_path_is_inside_folder_tree = M.is_buffer_in_folder_tree(working_directory, file_path)
        if file_path_is_inside_folder_tree then
          -- The reason to not return from this loop immediately is because, say I
          -- have tab 1 working directory: A/B/C, tab 2 working directory: A/B, and I
          -- open a file in the A/B/C/ working directory, I want the file to be opened in the closest
          -- parent directory tab, which is tab 1, to do that, I need to iterate every
          -- tab and record its working directory, and do the next step after this
          -- iteration, if I don't do so, the file might get opened in tab 2.
          table.insert(matched_tab_working_dirs, working_directory)
          table.insert(matched_tab_ids, tabnr_ordinal)
        end
      end
      -- Restore original tab
      vim.api.nvim_set_current_tabpage(original_tabpage)

      if #matched_tab_working_dirs > 0 and #matched_tab_ids > 0 then
        local longest_directory_name = ""
        local target_tab_id = 1
        for i, matched_tab_working_dir in ipairs(matched_tab_working_dirs) do
          if #matched_tab_working_dir > #longest_directory_name then
            longest_directory_name = matched_tab_working_dir
            target_tab_id = matched_tab_ids[i]
          end
        end
        if vim.g.toggle_term_opened then
          if vim.g.toggle_term_direction then
            require("configs.toggleterm_utils").toggle_term(vim.g.toggle_term_direction)
          else
            command = ":q | " -- first need to close this toggleterm
          end
        end
        if is_called_from_oil then
          command = ":q! |"
        end
        -- if is_called_from_telescope then
          -- command = ":q! | "
        -- end
        -- If the current tab page has multiple windows, close the current window,
        -- beause we are opening the file in new tab anyway
        -- local window_count_in_current_tab = vim.fn.tabpagewinnr(vim.fn.tabpagenr(), "$")

        -- command = ":q! | "
        -- end
        command = command .. "tabnext" .. target_tab_id .. "| edit " .. file_path
        found_tab = true
        -- No tabs matched
      else
        local file_path_dir = vim.fn.fnamemodify(file_path, ":p:h")
        local message = "No project opened in this file_path: " ..
        file_path_dir .. ". Open this file_path in new tab and set its parent directory as Project?"
        local choice = vim.fn.confirm(message)
        if choice == 1 then
          -- Open in new tab
          if is_called_from_oil then
            command = ":q! | "
          end
          -- if is_called_from_telescope then
            -- command = ":q! | "
          -- end
          command = command .. "tabnew " .. file_path
          -- Below setting the working directory in new tab
          -- this action is normally only available to vim.g.TabAutoCwd in TabNewEntered
          -- this case is an exception
          vim.g.new_tab_buf_cwd = vim.fn.fnamemodify(file_path, ":p:h")
          command = command .. " | tcd " .. vim.g.new_tab_buf_cwd
          goto continue
        else
          -- Do nothing
          goto continue
        end
      end
    else -- Not auto cwd and not cwd by project, find if there is any tab that is opening that file currently
      if dont_care_just_open_in_new_tab then
        command = ":q! | "
        goto next
      end
      if selected_entry ~= nil then -- This is calling from Telescope picker
        vim.api.nvim_command(":q!")
      end
      -- First, look for currently opened or active window in each tab (cwd)
      for _, tid in ipairs(vim.api.nvim_list_tabpages()) do
        local tabnr_ordinal = vim.api.nvim_tabpage_get_number(tid)
        local win = vim.api.nvim_tabpage_get_win(tid)
        local buf = vim.api.nvim_win_get_buf(win)
        local buf_name = vim.api.nvim_buf_get_name(buf)
        if buf_name == file_path then
          if vim.g.toggle_term_opened then
            command = ":q | " -- first need to close this toggleterm
          end
          if is_called_from_oil then
            command = ":q! |"
          end
          command = command .. "tabnext " .. tabnr_ordinal .. " | edit " .. file_path
          found_tab = true
          goto next
        end
      end

      -- If there is no active window opened for all tabs,
      -- look for the all open buffers in each tab instead (cwd)
      -- for _, tid in ipairs(vim.api.nvim_list_tabpages()) do
      --   local tabnr_ordinal = vim.api.nvim_tabpage_get_number(tid)
      --   -- Temporarily switch to the tab to get its cwd
      --   vim.api.nvim_set_current_tabpage(tid)
      --
      --   local buffers = require("plugins.configs.buffer_utils").get_buffers_in_cwd()
      --   -- Iterate each buffers in that cwd
      --   for _, buf in ipairs(buffers) do
      --     if file_path == buf[2] then
      --       if vim.g.toggle_term_opened then
      --         command = ":q | " -- first need to close this toggleterm
      --       end
      --       command = "tabnext" .. tabnr_ordinal .. "| edit " .. file_path
      --       found_tab = true
      --       goto next
      --     end
      --   end
      --   -- The file is in the same tab cwd, just open the file in this tab
      --   if vim.g.toggle_term_opened then
      --     command = ":q | " -- first need to close this toggleterm
      --   end
      --   command = command .. "tabnext" .. tabnr_ordinal .. "| edit " .. file_path
      --   found_tab = true
      --   goto next
      -- end
    end
    ::next::
    if not found_tab then
      command = command .. "tabnew " .. file_path
    end
  else
    print("Invalid file path")
    return
  end

  ::continue::

  if selected_entry ~= nil then -- This is calling from Telescope picker
    -- selected_entry.filename and row, col are for something like
    -- lsp_definitions, with filename and specific cursor position
    row = selected_entry.lnum or 1
    col = selected_entry.col or 1
    pcall(function()
      vim.api.nvim_command(command)
      vim.g.toggle_term_opened = false
      vim.fn.cursor(row, col)
    end)
  else
    pcall(function()
      vim.api.nvim_command(command)
      vim.g.toggle_term_opened = false
      vim.fn.cursor(row, col)
    end)
  end
end

-- Run Git custom user command when the buffer name matches
M.run_git_related_when_the_buffer_name_matches = function()
  local buf_path = vim.api.nvim_buf_get_name(0)
  require("core.utils_window").save_window_sizes_and_restore(function()
    if buf_path:match("^/tmp/nvim%.ccw/") then
      vim.g.gll_reload_manually_or_open_new = true
      vim.api.nvim_command(":Gll")
      vim.cmd("wincmd k")
      vim.cmd("wincmd q")
      vim.cmd("wincmd p") -- make sure to focus on the Gll window
    elseif buf_path:match("^fugitive://") then
      pcall(function()
        vim.notify("Fetching remote...")
        vim.api.nvim_command("Git fetch --all")
        vim.notify("Done fetching remote.")
      end)
    else
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-r>", true, false, true), "n", true)
    end
  end)
end

M.focus_window_by_selecting_it = function()
  local target_winid = utils_window.get_target_winid()
  if not target_winid then
    return
  end
  vim.api.nvim_set_current_win(target_winid)
end

M.open_file_or_buffer_in_window = function(is_visual, count)
  local vimfetch = require("core.utils_vimfetch")

  local file
  if is_visual then
    file = vimfetch.fetch_visual(count)
  else
    file = vimfetch.fetch_cfile(count)
  end

  local current_buf_nr = vim.api.nvim_get_current_buf()

  if file == nil or #file == 0 then
    -- if no path on the cursor, then record current buffer to the file variable
    file = {}
    local buf_name = vim.api.nvim_buf_get_name(current_buf_nr)
    -- ignore if this is a term
    if buf_name:match("^term:") then
      return
    end

    -- ignore if this is fugitive
    if buf_name:match("^fugitive:") then
      return
    end

    -- ignore if this is Gll related
    if buf_name:match("/tmp/nvim.ccw/*") then
      return
    end

    file[1] = vim.fn.fnamemodify(buf_name, ":p")
    file[2], file[3] = vim.api.nvim_win_get_cursor(0)
  end

  local file_path = file[1]
  local row = file[2] or 1
  local col = file[3] or 1

  if file_path then
    utils_window.open(file_path, row, col)
  end

  if not file_path or file_path == "" then
    print("Invalid file path")
    return
  end
end

M.new_tab_with_scratch_buffer = function()
  vim.cmd("tabedit")
  vim.opt_local.textwidth = 0
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = 0 })
  vim.api.nvim_set_option_value("bufhidden", "unload", { buf = 0 })
  vim.api.nvim_set_option_value("swapfile", false, { buf = 0 })
end

-- Find if the buffer is inside the folder tree
M.is_buffer_in_folder_tree = function(folder_path, buffer)
  -- Check if the buffer's path starts with the folder path
  return buffer:sub(1, #folder_path) == folder_path
end

return M
