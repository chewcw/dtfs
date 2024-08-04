M = {}

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
          return
        end
        --
        vim.cmd("enew")
        vim.cmd("bdelete!" .. current_bufnr)
        return true
      end
    else
      -- Buffer is not modified, just delete it
      local bufname = vim.api.nvim_buf_get_name(0) -- Get the name of the current buffer
      if bufname == "" then
        return
      end
      vim.cmd("enew")
      vim.cmd("bdelete!" .. current_bufnr)
      return true
    end
    return false
  end)
end

-- Function to delete buffer and show new buffer
M.delete_buffer_create_new = function()
  -- Delete the current buffer
  pcall(function()
    local current_bufnr = vim.fn.bufnr("%")    -- Get the buffer number of the current buffer
    local bufname = vim.api.nvim_buf_get_name(0) -- Get the name of the current buffer
    if bufname == "" then
      return
    end
    vim.cmd("enew")
    vim.cmd("bdelete" .. current_bufnr)
  end)
end

M.navigate_to_previous_buffer = function()
  local current_bufnr = vim.fn.bufnr("%")         -- Get the buffer number of the current buffer
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
  local current_bufnr = vim.fn.bufnr("%")         -- Get the buffer number of the current buffer
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
  if vim.o.list then
    vim.o.list = false
  else
    vim.o.list = true
  end
end

-- Function to dynamically show newline symbol
M.toggle_newline_symbol = function()
  local newline = "eol:↵"
  if vim.o.listchars:find("eol:") then
    vim.o.listchars = string.gsub(vim.o.listchars, "," .. newline, "")
  else
    vim.o.listchars = vim.o.listchars .. "," .. newline
  end
end

local function get_buffers_in_cwd()
  local cwd = vim.fn.getcwd()
  local buffers = {}

  for _, bufinfo in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    local bufname = bufinfo.name
    if bufname ~= "" and vim.startswith(bufname, cwd) then
      table.insert(buffers, bufinfo.bufnr)
    end
  end

  return buffers
end

M.switch_to_next_buffer_in_cwd = function()
  if not vim.o.hlsearch then
    vim.cmd("noh")
  end
  local buffers = get_buffers_in_cwd()
  local current_bufnr = vim.api.nvim_get_current_buf()
  local current_index = nil
  for i, bufnr in ipairs(buffers) do
    if bufnr == current_bufnr then
      current_index = i
      break
    end
  end
  if current_index then
    local next_index = (current_index % #buffers) + 1
    vim.api.nvim_set_current_buf(buffers[next_index])
  end
end

M.switch_to_previous_buffer_in_cwd = function()
  if not vim.o.hlsearch then
    vim.cmd("noh")
  end
  local buffers = get_buffers_in_cwd()
  local current_bufnr = vim.api.nvim_get_current_buf()
  local current_index = nil
  for i, bufnr in ipairs(buffers) do
    if bufnr == current_bufnr then
      current_index = i
      break
    end
  end
  if current_index then
    local previous_index = (current_index - 2) % #buffers + 1
    vim.api.nvim_set_current_buf(buffers[previous_index])
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
    vim.api.nvim_command("tabnew " .. file[1])
    vim.fn.cursor(file[2], file[3])
  end
end

M.open_file_in_specific_tab = function(is_visual, count)
  local vimfetch = require("core.utils_vimfetch")

  local file
  if is_visual then
    file = vimfetch.fetch_visual(count)
  else
    file = vimfetch.fetch_cfile(count)
  end

  -- show tab's cwd
  vim.g.toggle_tab_cwd = true

  vim.ui.input({ prompt = "Enter tab number: " }, function(input)
    if input then
      local tabnr = tonumber(input)
      if tabnr and tabnr > 0 and tabnr <= vim.fn.tabpagenr("$") then
        -- Get the list of tab pages
        local tabpages = vim.api.nvim_list_tabpages()
        -- Check if the specified tab exists
        if tabnr < 1 or tabnr > #tabpages then
          print("Invalid tab number: " .. tabnr)
          return
        end

        -- Switch to the specified tab
        vim.cmd("tabn " .. tabnr)
        -- Open the file in the current window of the specified tab
        if file and file[1] then
          vim.cmd("edit " .. file[1])
          vim.fn.cursor(file[2], file[3])
        end
      else
        print("Invalid tab number: " .. input)
      end
    else
      print("Input canceled")
    end
  end)

  vim.g.toggle_tab_cwd = false
end

return M
