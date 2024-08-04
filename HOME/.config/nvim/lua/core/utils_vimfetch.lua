-- reference: https://github.com/wsdjeg/vim-fetch
-- Open the file when cursor pointing to file path with line number and column number
-- For example: /path/to/file.lua:3:11
-- 3 is the line number, 11 is the colum number

local M = {}
local specs = {}

-- Position specs Dictionary
-- /path/to/file:1:3
specs.colon = {
  pattern = "\\m\\%(:\\d\\+\\)\\{1,2\\}\\%(:.*\\)\\?",
  parse = function(file)
    local file_paths = vim.split(file, ":")
    local pos = vim.split(vim.fn.matchstr(file, specs.colon.pattern), ":")
    return { file_paths[1], tonumber(pos[2]) or 1, tonumber(pos[3]) or 1 }
  end,
}

-- /path/to/file(1:3)
specs.paren = {
  pattern = "\\m(\\(\\d\\+\\%(:\\d\\+\\)*\\))",
  parse = function(file)
    local matches = vim.fn.matchlist(file, "\\v^(.*)\\(")
    local file_path = matches[2] or ""
    matches = vim.fn.matchstr(file, "\\m(\\d\\+\\%(:\\d\\+\\)*)")
    matches = matches:gsub("%(", "")
    matches = matches:gsub("%)", "")
    local pos = vim.split(matches, ":")
    return { file_path, pos[1] or 1, pos[2] or 1 }
  end,
}

-- /path/to/file(1,3)
specs.paren_comma = {
  pattern = "\\m(\\(\\d\\+\\%(,\\d\\+\\)*\\))",
  parse = function(file)
    local matches = vim.fn.matchlist(file, "\\v^(.*)\\(")
    local file_path = matches[2] or ""
    matches = vim.fn.matchstr(file, "\\m(\\d\\+\\%(,\\d\\+\\)*)")
    matches = matches:gsub("%(", "")
    matches = matches:gsub("%)", "")
    local pos = vim.split(matches, ",")
    return { file_path, pos[1] or 1, pos[2] or 1 }
  end,
}

-- specs.equals = {
--   pattern = "\\m.*=\\(\\d\\+\\)=\\%(.*\\)\\?",
--   parse = function(file)
--     -- local tfile = file:gsub(specs.equals.pattern, "")
--     local pos = vim.fn.matchlist(file, specs.equals.pattern)[1]
--     -- return { tfile, { "cursor", { tonumber(pos), 0 } } }
--     return { pos[1], tonumber(pos[2]) or 1, tonumber(pos[3]) or 1 }
--   end,
-- }

-- specs.dash = {
--   pattern = "\\m.*-\\(\\d\\+\\)-\\%(.*\\)\\?",
--   parse = function(file)
--     -- local tfile = file:gsub(specs.dash.pattern, "")
--     local pos = vim.fn.matchlist(file, specs.dash.pattern)[1]
--     -- return { tfile, { "cursor", { tonumber(pos), 0 } } }
--     return { pos[1], tonumber(pos[2]) or 1, tonumber(pos[3]) or 1 }
--   end,
-- }

-- specs.plan9 = {
--   pattern = "\\m.*:#\\(\\d\\+\\)",
--   parse = function(file)
--     -- local tfile = file:gsub(specs.plan9.pattern, "")
--     local pos = vim.fn.matchlist(file, specs.plan9.pattern)[1]
--     -- return { tfile, { "cursor", { tonumber(pos), 0 } } }
--     return { pos[1], tonumber(pos[2]) or 1, tonumber(pos[3]) or 1 }
--   end,
-- }

-- /path/to/file#L1
specs.github_line = {
  pattern = "\\m#L\\(\\d\\+\\)",
  parse = function(file)
    local file_paths = vim.split(file, "#")
    local file_path = file_paths[1]
    local pos = vim.fn.matchlist(file, specs.github_line.pattern)
    return { file_path, pos[2], 1 }
  end,
}

-- /path/to/file#L1-L3
specs.github_range = {
  pattern = "\\m#L\\(\\d\\+\\)-L\\(\\d\\+\\)",
  parse = function(file)
    local file_paths = vim.split(file, "#")
    local lines = vim.split(file_paths[2], "-")
    lines[1] = lines[1]:gsub("L", "")
    lines[2] = lines[2]:gsub("L", "")
    return { file_paths[1], lines[1], 1 }
  end,
}

M.fetch_specs = function()
  return vim.deepcopy(specs)
end

M.fetch_buffer = function(bufname)
  local bufwinnr = vim.fn.bufwinnr(bufname)
  if bufwinnr == -1 then
    return false
  end

  local spec
  for _, s in pairs(specs) do
    if vim.fn.matchend(bufname, s.pattern) == #bufname then
      spec = s
      break
    end
  end

  if not spec then
    return false
  end

  local file, jump = spec.parse(bufname)
  if not vim.fn.filereadable(file) or not M.detect_buffer(bufname) then
    return false
  end

  local oldwinnr = M.goto_win(bufwinnr)
  local cmd = vim.fn.index(vim.fn.argv(), bufname) ~= -1 and "argedit" or "edit"

  vim.cmd("keepalt " .. cmd .. " " .. vim.fn.fnameescape(file))

  if vim.fn.exists("v:swapcommand") then
    vim.cmd("normal " .. vim.fn["v:swapcommand"])
  end

  return M.setpos(jump)
end

M.fetch_cfile = function(count)
  local cfile = vim.fn.expand("<cfile>")
  if cfile ~= "" then
    local pattern = "\\M" .. vim.fn.escape(cfile, "\\")
    local position = vim.fn.searchpos(pattern, "bcn", vim.fn.line("."))
    if position[1] == 0 and position[2] == 0 then
      position = vim.fn.searchpos(pattern, "cn", vim.fn.line("."))
    end

    local lines = vim.fn.split(cfile, "\n")
    local line = vim.fn.getline(position[1] + #lines - 1)
    local offset = (#lines > 1 and 0 or position[2]) + #lines[#lines] - 1

    for _, s in pairs(specs) do
      if vim.fn.match(line, s.pattern, offset) == offset then
        local match = vim.fn.matchstr(line, s.pattern, offset)
        local pos = s.parse(cfile .. match)
        return { pos[1], pos[2], pos[3] }
      end
    end
  end
end

M.fetch_visual = function(count)
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local startline, startcol = start_pos[2], start_pos[3]
  local endline, endcol = end_pos[2], end_pos[3]
  endcol = math.min(endcol, vim.fn.col({ endline, "$" })) -- 'V' col nr. bug
  endcol = endcol - (vim.o.selection == "inclusive" and 0 or 1)

  local lines = vim.fn.getline(startline, endline)

  if vim.fn.visualmode() ~= "v" then
    -- character-wise selection
    lines[#lines] = vim.fn.matchstr(lines[#lines], "\\m^.*%" .. endcol .. "c.\\?")
    lines[1] = string.sub(lines[1], startcol - 1)
  else
    -- block-wise selection
    ---@diagnostic disable-next-line: param-type-mismatch
    for i, line in ipairs(lines) do
      lines[i] = string.sub(vim.fn.matchstr(line, "\\m^.*\\%" .. endcol .. "c.\\?"), startcol - 1)
    end
  end

  ---@diagnostic disable-next-line: param-type-mismatch
  local selection = table.concat(lines, "\n")

  if selection ~= "" then
    local line = vim.fn.getline(endline)
    for _, spec in pairs(specs) do
      if vim.fn.match(line, spec.pattern, endcol) == endcol then
        local match = vim.fn.matchstr(line, spec.pattern, endcol)
        local pos = spec.parse(selection .. match)
        return { pos[1], pos[2], pos[3] }
      end
    end
  end

  -- M.do_visual(count .. 'gF')
  -- return true
end

M.detect_buffer = function(bufnr)
  local bufname = vim.fn.bufname(bufnr)
  local buftype = vim.fn.getbufvar(bufnr, "&buftype")

  if vim.tbl_contains({ "", "nowrite" }, buftype) then
    return false
  end

  if not vim.fn.filereadable(bufname) then
    return false
  end

  return true
end

M.goto_win = function(winnr)
  local curwinnr = vim.fn.bufwinnr("%")
  if winnr ~= -1 and curwinnr ~= winnr then
    vim.cmd("silent keepjumps noautocmd " .. winnr .. "wincmd w")
  end
  return curwinnr
end

M.setpos = function(calldata)
  M.do_autocmd("BufFetchPosPre")
  vim.fn.call("call", calldata)
  local pos = vim.fn.getpos(".")
  vim.b.fetch_lastpos = { pos[2], pos[3] }
  vim.cmd("silent! foldopen!")
  vim.cmd("silent! normal! zz")
  M.do_autocmd("BufFetchPosPost")
  return true
end

M.do_autocmd = function(pattern)
  if vim.fn.exists("#User#" .. pattern) then
    vim.cmd("doautocmd <nomodeline> User" .. pattern)
  end
end

M.do_visual = function(command)
  local cmd = vim.fn.index({ "v", "V", "" }, vim.fn.mode()) == -1 and "gv" .. command or command
  vim.cmd("normal! " .. cmd)
end

return M
