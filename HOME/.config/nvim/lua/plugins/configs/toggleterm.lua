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
  autochdir = false,
  highlights = {
    FloatBorder = {
      link = "FloatBorder",
    },
  },
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
    border = "double",
    shade_terminals = false,
  },
  winbar = {
    enabled = true,
  },
  on_open = function(term)
    vim.opt_local.colorcolumn = "0"
    vim.opt_local.cursorline = true
    vim.opt_local.cursorlineopt = "both"
    vim.opt_local.textwidth = 0
  end,
  on_exit = function(term, job, exit_code, name)
    -- more information in plugins/configs/toggleterm_utils.lua
    local utils = require("core.utils")
    if utils.table_contains(vim.g.toggle_term_opened_term_ids, term.id) then
      local x = vim.g.toggle_term_opened_term_ids
      table.remove(x, term.id)
      vim.g.toggle_term_opened_term_ids = x
    end

    -- randomly pick one for the vim.g.toggle_term_count record
    for _, opened_term_id in ipairs(vim.g.toggle_term_opened_term_ids) do
      vim.g.toggle_term_count = opened_term_id
      break
    end

    -- if there is none left, assign 0 to vim.g.toggle_term_count
    vim.g.toggle_term_count = 0

    -- set vim.g.toggle_term_opened to false
    vim.g.toggle_term_opened = false
  end,
}

return options
