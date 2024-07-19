local M = {}

M.toggle_term = function(direction)
  if vim.g.toggle_term_direction == nil and vim.g.toggle_term_opened == nil then
    vim.g.toggle_term_direction = direction
    vim.g.toggle_term_opened = false
  end

  local count = vim.v.count or ""

  if vim.g.toggle_term_direction == direction and vim.g.toggle_term_opened == false then
      vim.cmd(count .. "ToggleTerm direction=" .. direction)
      vim.g.toggle_term_opened = true
  elseif vim.g.toggle_term_direction == direction and vim.g.toggle_term_opened == true then
    if count == "" then
      vim.cmd("ToggleTerm")
      vim.g.toggle_term_opened = false
    end
    if vim.g.toggle_term_count == count then
      vim.cmd(count .. "ToggleTerm direction=" .. direction)
      vim.g.toggle_term_opened = false
    else
      vim.cmd(count .. "ToggleTerm direction=" .. direction)
      vim.g.toggle_term_opened = true
    end
  elseif vim.g.toggle_term_direction ~= direction and vim.g.toggle_term_opened == false then
    vim.cmd(count .. "ToggleTerm direction=" .. direction)
    vim.g.toggle_term_opened = true
  elseif vim.g.toggle_term_direction ~= direction and vim.g.toggle_term_opened == true then
    vim.cmd("ToggleTerm")
    vim.g.toggle_term_opened = false
    vim.cmd(count .. "ToggleTerm direction=" .. direction)
    vim.g.toggle_term_opened = true
  end
  vim.g.toggle_term_direction = direction
  vim.g.toggle_term_count = count
end

return M
