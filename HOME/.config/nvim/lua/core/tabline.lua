-- https://stackoverflow.com/a/76544483
-- Tabline function to show both working directory and open buffer
function MyTabLine()
  local fname = vim.fn.expand("%:p")
  local bufname = fname ~= "" and fname or "No_Name"
  local is_modified = vim.fn.getbufvar("%", "&modified") == 1 and "[+]" or ""
  local fugitive_mark = fname:match("^fugitive://", 1) and " [Fugitive]" or ""
  return "%#TabLineSel# " .. bufname .. is_modified .. fugitive_mark .. " %#TabLineFill#%T"
end

vim.o.tabline = "%!v:lua.MyTabLine()"
