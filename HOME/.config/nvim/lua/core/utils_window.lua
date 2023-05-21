-- these codes I take references and modified from nvim.tree (open-file.lua, etc.)
-- https://github.com/nvim-tree/nvim-tree.lua/tree/master
-- so that I can use its window picker implementation to select window in telescope

local M = {}

local target_winid = nil
local tabpages = {}
local window_picker = {
  chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
  exclude = {
    filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
    buftype = { "nofile", "terminal", "help", "TelescopePrompt", "TelescopeResults", "prompt" },
  },
}

local function clear_prompt()
  if vim.opt.cmdheight._value ~= 0 then
    vim.cmd("normal! :")
  end
end

local function usable_win_ids()
  local tabpage = vim.api.nvim_get_current_tabpage()
  local win_ids = vim.api.nvim_tabpage_list_wins(tabpage)

  local filter = vim.tbl_filter(function(id)
    local bufid = vim.api.nvim_win_get_buf(id)
    for option, v in pairs(window_picker.exclude) do
      local ok, option_value = pcall(vim.api.nvim_buf_get_option, bufid, option)
      if ok and vim.tbl_contains(v, option_value) then
        return false
      end
    end

    local win_config = vim.api.nvim_win_get_config(id)
    return id ~= win_config.focusable and not win_config.external
  end, win_ids)

  return filter
end

local function get_user_input_char()
  local c = vim.fn.getchar()
  while type(c) ~= "number" do
    c = vim.fn.getchar()
  end
  return vim.fn.nr2char(c)
end

---Get user to pick a window in the tab that is not NvimTree.
---@return integer|nil -- If a valid window was picked, return its id. If an
---       invalid window was picked / user canceled, return nil. If there are
---       no selectable windows, return -1.
local function pick_win_id()
  local selectable = usable_win_ids()

  -- If there are no selectable windows: return. If there's only 1, return it without picking.
  if #selectable == 0 then
    return -1
  end
  if #selectable == 1 then
    return selectable[1]
  end

  if #window_picker.chars < #selectable then
    print("More windows than window_picker.chars in core.utils.window.lua, please add more.")
    return nil
  end

  local i = 1
  local win_opts = {}
  local win_map = {}
  local laststatus = vim.o.laststatus
  vim.o.laststatus = 2

  local tabpage = vim.api.nvim_get_current_tabpage()
  local win_ids = vim.api.nvim_tabpage_list_wins(tabpage)

  local not_selectable = vim.tbl_filter(function(id)
    return not vim.tbl_contains(selectable, id)
  end, win_ids)

  if laststatus == 3 then
    for _, win_id in ipairs(not_selectable) do
      local ok_status, statusline = pcall(vim.api.nvim_win_get_option, win_id, "statusline")
      local ok_hl, winhl = pcall(vim.api.nvim_win_get_option, win_id, "winhl")

      win_opts[win_id] = {
        statusline = ok_status and statusline or "",
        winhl = ok_hl and winhl or "",
      }

      -- Clear statusline for windows not selectable
      vim.api.nvim_win_set_option(win_id, "statusline", " ")
    end
  end

  -- Setup UI
  for _, id in ipairs(selectable) do
    local char = window_picker.chars:sub(i, i)
    local ok_status, statusline = pcall(vim.api.nvim_win_get_option, id, "statusline")
    local ok_hl, winhl = pcall(vim.api.nvim_win_get_option, id, "winhl")

    win_opts[id] = {
      statusline = ok_status and statusline or "",
      winhl = ok_hl and winhl or "",
    }
    win_map[char] = id

    vim.api.nvim_win_set_option(id, "statusline", "%=" .. char .. "%=")
    vim.api.nvim_win_set_option(id, "winhl", "StatusLine:Italic,StatusLineNC:Italic")

    i = i + 1
    if i > #window_picker.chars then
      break
    end
  end

  vim.cmd("redraw")
  if vim.opt.cmdheight._value ~= 0 then
    print("Pick window: ")
  end
  local _, resp = pcall(get_user_input_char)
  resp = (resp or ""):upper()
  clear_prompt()

  -- Restore window options
  for _, id in ipairs(selectable) do
    for opt, value in pairs(win_opts[id]) do
      vim.api.nvim_win_set_option(id, opt, value)
    end
  end

  if laststatus == 3 then
    for _, id in ipairs(not_selectable) do
      for opt, value in pairs(win_opts[id]) do
        vim.api.nvim_win_set_option(id, opt, value)
      end
    end
  end

  vim.o.laststatus = laststatus

  if not vim.tbl_contains(vim.split(window_picker.chars, ""), resp) then
    return
  end

  return win_map[resp]
end

local function get_target_winid()
  -- pick a window
  target_winid = pick_win_id()

  if target_winid == nil then
    -- pick failed/canceled
    return
  end

  return target_winid
end

-- This is only to avoid the BufEnter for nvim-tree to trigger
-- which would cause find-file to run on an invalid file.
local function set_current_win_no_autocmd(winid, autocmd)
  local eventignore = vim.opt.eventignore:get()
  vim.opt.eventignore:append(autocmd)
  vim.api.nvim_set_current_win(winid)
  vim.opt.eventignore = eventignore
end

--- Returns the window number for nvim-tree within the tabpage specified
---@param tabpage number|nil (optional) the number of the chosen tabpage. Defaults to current tabpage.
---@return number|nil
local function get_winnr(tabpage)
  tabpage = tabpage or vim.api.nvim_get_current_tabpage()
  local tabinfo = tabpages[tabpage]
  if tabinfo ~= nil then
    return tabinfo.winnr
  end
end

local function set_target_win()
  local id = vim.api.nvim_get_current_win()
  local tree_id = get_winnr()
  if tree_id and id == tree_id then
    target_winid = 0
    return
  end

  target_winid = id
end

local function get_win_buf_from_path(path)
  for _, w in pairs(vim.api.nvim_tabpage_list_wins(0)) do
    local b = vim.api.nvim_win_get_buf(w)
    if vim.api.nvim_buf_get_name(b) == path then
      return w, b
    end
  end
  return nil, nil
end

M.open = function(filename, line_number, column_number)
  local found_win = get_win_buf_from_path(filename)
  if found_win then
    vim.api.nvim_set_current_win(found_win)
    vim.bo.bufhidden = ""
  end

  target_winid = get_target_winid()
  if not target_winid then
    return
  end

  local fname = vim.fn.fnameescape(filename)
  local cmd = string.format("edit %s", fname)

  set_current_win_no_autocmd(target_winid, { "BufEnter" })

  pcall(vim.cmd, cmd)
  pcall(vim.api.nvim_win_set_cursor, target_winid, { line_number, column_number })
  set_target_win()
end

return M
