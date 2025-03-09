local M = {}

M.open_trouble = function(scope)
  -- First need to check if the toggleterm is opened
  if vim.g.toggle_term_opened then
    if vim.g.toggle_term_direction then
      -- Toggle it if it is opened
      require("plugins.configs.toggleterm_utils").toggle_term(vim.g.toggle_term_direction)
    end
  end
  require("trouble").toggle(scope)
end

return M
