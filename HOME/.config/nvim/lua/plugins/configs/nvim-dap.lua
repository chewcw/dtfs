local M = {}

M.config = function()
  require("nvim-dap-virtual-text").setup({
    commented = true,
  })

  local dap, dapui = require("dap"), require("dapui")
  dapui.setup({})

  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end
end

local home = os.getenv("HOME")
M.python = {
  "mfussenegger/nvim-dap-python",
  config = function()
    require("dap-python").setup(home .. "/.local/share/nvim/mason/packages/debugpy/venv/bin/python")
  end,
}

M.go = {
  "leoluz/nvim-dap-go",
  config = function()
    require("dap-go").setup()
  end,
  opts = {
      delve = {
        path = home .. "/.local/share/nvim/mason/packages/delve/dlv",
      },
  },
}

return M
