local M = {}

M.toggle_term = function(direction)
  if vim.g.toggle_term_direction == nil then
    vim.g.toggle_term_direction = direction
  end
  local count = vim.v.count or ""
  if vim.g.toggle_term_direction == direction then
    vim.cmd(count .. 'ToggleTerm direction=' .. direction)
  else
    vim.cmd("ToggleTerm") -- toggle the term
    vim.cmd(count .. "ToggleTerm direction=" .. direction)
  end
  vim.g.toggle_term_direction = direction
end

return M
