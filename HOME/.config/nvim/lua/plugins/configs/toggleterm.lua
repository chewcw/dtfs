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
  shell = "/bin/bash",
  float_opts = {
    border = "single",
  },
  winbar = {
    enabled = true,
  },
}

return options
