local options = {
  size = function(term)
    if term.direction == "horizontal" then
      return 15
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.4
    end
  end,
  start_in_insert = false,
  insert_mappings = true,
  terminal_mappings = true,
  hide_numbers = true,
  autochdir = true,
  shade_terminals = false,
  shell = function()
    if vim.fn.executable("zsh") == 1 then
      return "zsh"
    elseif vim.fn.executable("fish") == 1 then
      return "fish"
    elseif vim.fn.executable("bash") == 1 then
      return "bash"
    else
      return "sh"
    end
  end,
  float_opts = {
    border = "single",
  },
  winbar = {
    enabled = false,
  },
}

return options
