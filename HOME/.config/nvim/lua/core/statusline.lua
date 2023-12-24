local function filepath()
  local fpath = vim.fn.fnamemodify(vim.fn.expand "%", ":~:.:h")
  if fpath == "" or fpath == "." then
      return " "
  end

  return string.format(" %%<%s/", fpath)
end

local function filename()
  local fname = vim.fn.expand "%:t"
  if fname == "" then
      return ""
  end
  return fname .. " "
end

local function lsp()
  local count = {}
  local levels = {
    errors = "Error",
    warnings = "Warn",
    info = "Info",
    hints = "Hint",
  }

  for k, level in pairs(levels) do
    count[k] = vim.tbl_count(vim.diagnostic.get(0, { severity = level }))
  end

  local errors = ""
  local warnings = ""
  local hints = ""
  local info = ""
  local lsp_server_count = ""

  if count["errors"] ~= 0 then
    errors = " %#LspDiagnosticsSignError#E" .. count["errors"]
  end
  if count["warnings"] ~= 0 then
    warnings = " %#LspDiagnosticsSignWarning#W" .. count["warnings"]
  end
  if count["hints"] ~= 0 then
    hints = " %#LspDiagnosticsSignHint#H" .. count["hints"]
  end
  if count["info"] ~= 0 then
    info = " %#LspDiagnosticsSignInformation#I" .. count["info"]
  end

  lsp_servers = vim.lsp.get_active_clients()
  lsp_server_names = ""
  for _, server in ipairs(lsp_servers) do
    if lsp_server_names == "" then
      lsp_server_names = server.name
    else
      lsp_server_names = lsp_server_names .. "," .. server.name
    end
  end

  return "%#Structure#" .. lsp_server_names .. errors .. warnings .. hints .. info
end

local function filetype()
  return "%#Normal#" .. vim.bo.filetype
end

local function lineinfo()
  if vim.bo.filetype == "alpha" then
    return ""
  end
  return "%#Normal#" .. " %l:%c "
end

local vcs = function()
  local git_info = vim.b.gitsigns_status_dict
  if not git_info or git_info.head == "" then
    return ""
  end
  local added = git_info.added and ("%#GitSignsAdd#+" .. git_info.added .. " ") or ""
  local changed = git_info.changed and ("%#GitSignsChange#~" .. git_info.changed .. " ") or ""
  local removed = git_info.removed and ("%#GitSignsDelete#-" .. git_info.removed .. " ") or ""
  if git_info.added == 0 then
    added = ""
  end
  if git_info.changed == 0 then
    changed = ""
  end
  if git_info.removed == 0 then
    removed = ""
  end
  return table.concat {
     " ",
     added,
     changed,
     removed,
     " ",
     "%#GitSignsAdd#  ",
     git_info.head,
     " %#Normal#",
  }
end

Statusline = {}

Statusline.active = function()
  return table.concat {
    filepath(),
    filename(),
    " | ",
    vcs(),
    " | ",
    "%=%#StatusLineExtra#",
    lsp(),
    " | ",
    lineinfo(),
  }
end

function Statusline.inactive()
  return " %F"
end

function Statusline.short()
  return "%#StatusLineNC#   NvimTree"
end

vim.api.nvim_exec([[
  augroup Statusline
  au!
  au WinEnter,BufEnter * setlocal statusline=%!v:lua.Statusline.active()
  au WinLeave,BufLeave * setlocal statusline=%!v:lua.Statusline.inactive()
  au WinEnter,BufEnter,FileType NvimTree setlocal statusline=%!v:lua.Statusline.short()
  augroup END
]], false)
