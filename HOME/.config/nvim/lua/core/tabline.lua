-- https://stackoverflow.com/a/76544483
-- Tabline function to show both working directory and open buffer
function MyTabLine()
  local tabline = ""

  for tabnr = 1, vim.fn.tabpagenr("$") do
    -- Select the highlighting for the current tabpage.
    if tabnr == vim.fn.tabpagenr() then
      tabline = tabline .. "%#TabLineSel#"
    else
      tabline = tabline .. "%#TabLine#"
    end

    local win_num = vim.fn.tabpagewinnr(tabnr)
    local working_directory = vim.fn.getcwd(win_num, tabnr)
    local cwd_name = vim.fn.fnamemodify(working_directory, ":t")

    -- Get the name of the open buffer
    local bufnr = vim.fn.tabpagebuflist(tabnr)[vim.fn.tabpagewinnr(tabnr)]
    local bufname = vim.fn.bufname(bufnr)
    local buffer_name = bufname ~= "" and vim.fn.fnamemodify(bufname, ":t") or "No_Name"

    -- Check if the buffer is modified
    local is_modified = vim.fn.getbufvar(bufnr, "&modified") == 1 and "[+]" or ""

    if vim.g.toggle_tab_cwd then -- show tab's cwd (see user command "ToggleTabCwd")
      tabline = tabline .. " 🗎 " .. "<" .. tabnr .. "> " .. "[" .. cwd_name .. "] " .. " "
    else
      tabline = tabline .. " 🗎 " .. buffer_name .. is_modified .. " "
    end
  end

  return tabline .. "%#TabLineFill#%T"
end

-- Set the custom tabline
vim.o.tabline = "%!v:lua.MyTabLine()"
