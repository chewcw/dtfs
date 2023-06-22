local M = {}

M.dapui = {
  "rcarriga/nvim-dap-ui",
  config = function()
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
  end,
}

M.virtual_text = {
  "theHamsta/nvim-dap-virtual-text",
  config = function()
    require("nvim-dap-virtual-text").setup({
      commented = true,
    })
  end,
}

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

M.csharp = {
  setup = function()
    local dap = require("dap")
    dap.adapters.coreclr = {
      type = "executable",
      command = home .. "/.local/share/nvim/mason/packages/netcoredbg/netcoredbg",
      args = { "--interpreter=vscode" },
    }
    dap.configurations.cs = {
      {
        type = "coreclr",
        name = "launch - netcoredbg",
        request = "launch",
        program = function()
          return vim.fn.input("Path to dll", vim.fn.getcwd() .. "/bin/Debug/", "file")
        end,
      },
    }
  end,
}

return M
