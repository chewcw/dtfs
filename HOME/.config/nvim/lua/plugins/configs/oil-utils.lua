local M = {}

M.open_toggleterm_and_send_selection_parent_path_to_toggleterm = function(direction)
  return {
    desc = "Open toggleterm in specific direction",
    callback = function()
      local oil = require("oil")
      local cwd = oil.get_current_dir()
      -- Close the oil
      oil.close()
      -- Open toggleterm
      pcall(function()
        require("plugins.configs.toggleterm_utils").toggle_term(direction, true, cwd)
      end)
    end,
  }
end

return M
