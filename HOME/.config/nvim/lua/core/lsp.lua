local utils = require("core.utils")

local on_attach = function(client, bufnr)
  utils.load_mappings("lsp", { buffer = bufnr })
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

-- LSP floating window
-- override lsp floating window border
-- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization
local function border(hl_name)
  return {
    { "╔", hl_name },
    { "═", hl_name },
    { "╗", hl_name },
    { "║", hl_name },
    { "╝", hl_name },
    { "═", hl_name },
    { "╚", hl_name },
    { "║", hl_name },
  }
end
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
---@diagnostic disable-next-line: duplicate-set-field
function vim.lsp.util.open_floating_preview(contents, syntax, opts)
  opts = opts or {}
  opts.border = border("FloatBorder")
  opts.width = 50
  opts.max_width = 150
  return orig_util_open_floating_preview(contents, syntax, opts)
end

-- Global defaults, common for all LSPs
vim.lsp.config("*", {
  on_attach = on_attach,
  capabilities = capabilities,
})
vim.lsp.config["*"].capabilities = vim.tbl_deep_extend(
  "force",
  vim.lsp.config["*"].capabilities,
  {
    textDocument = {
      completion = {
        completionItem = {
          documentationFormat = { "markdown", "plaintext" },
          snippetSupport = true,
          preselectSupport = true,
          insertReplaceSupport = true,
          labelDetailsSupport = true,
          deprecatedSupport = true,
          commitCharactersSupport = true,
          tagSupport = { valueSet = { 1 } },
          resolveSupport = {
            properties = {
              "documentation",
              "detail",
              "additionalTextEdits",
            },
          },
        },
      },
      foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      },
    },
  }
)

-- lua
vim.lsp.config("luals", {})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.lsp.enable("luals")
  end,
})

-- typescript, javascript
vim.lsp.config("ts_ls", {
  on_attach = function(client, bufnr)
    on_attach()
    -- Auto format on save
    if client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
    end
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  callback = function()
    vim.lsp.enable("ts_ls")
  end,
})

-- c, cpp
vim.lsp.config("clangd", {})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "h", "hpp" },
  callback = function()
    vim.lsp.enable("clangd")
  end,
})

-- golang
vim.lsp.config("gopls", {
  on_attach = function(client, bufnr)
    on_attach()
    -- Enable formatting and auto import on save
    if client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
    end
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go" },
  callback = function()
    vim.lsp.enable("gopls")
  end,
})

-- csharp
vim.lsp.config("omnisharp", {})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "csharp", "razor" },
  callback = function()
    vim.lsp.enable("omnisharp")
  end,
})

-- python
vim.lsp.config("pyright", {
  capabilities = capabilities,
  settings = {
    -- Disable linting, code formatting, and organizing imports, and use ruff's
    pyright = {
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        ignore = { "*" },
      },
    },
  }
})
vim.lsp.config("ruff", {
  on_attach = function(client, bufnr)
    on_attach()
    -- Disable the ruff's hover capability and use Pyright's
    if client.server_capabilities.hoverProvider then
      client.server_capabilities.hoverProvider = false
    end
    -- Auto organize imports on save
    if client.server_capabilities.codeActionProvider then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function()
          print("run here")
          vim.lsp.buf.code_action({
            context = {
              triggerKind = 1,
              ---@diagnostic disable-next-line: assign-type-mismatch
              only = { "source.organizeImports.ruff" },
              diagnostics = {},
            },
            apply = true,
          })
        end,
      })
    end
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python" },
  callback = function()
    vim.lsp.enable("pyright")
    vim.lsp.enable("ruff")
  end,
})

-- rust
vim.lsp.config("rust_analyzer", {
  on_init = function()
    -- This fix the error when using rust_analyzer
    -- https://github.com/neovim/neovim/issues/30985#issuecomment-2447329525
    for _, method in ipairs({ 'textDocument/diagnostic', 'workspace/diagnostic' }) do
      local default_diagnostic_handler = vim.lsp.handlers[method]
      vim.lsp.handlers[method] = function(err, result, context, config)
        if err ~= nil and err.code == -32802 then
          return
        end
        return default_diagnostic_handler(err, result, context, config)
      end
    end
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "rust" },
  callback = function()
    vim.lsp.enable("rust_analyzer")
  end,
})

-- html, css, scss, less
vim.lsp.config("emmet_ls", {})
vim.lsp.config("cssls", {})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "html", "css", "scss", "less" },
  callback = function()
    vim.lsp.enable("emmet_ls")
    vim.lsp.enable("cssls")
  end,
})
