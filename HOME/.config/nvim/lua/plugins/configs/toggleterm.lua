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
  hide_numbers = false,
  autochdir = true,
  shell = "/usr/bin/zsh",
  float_opts = {
    border = "double",
  },
  winbar = {
    enabled = true,
  },
}

return options
