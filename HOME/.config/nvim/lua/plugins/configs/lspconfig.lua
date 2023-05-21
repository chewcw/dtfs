dofile(vim.g.base46_cache .. "lsp")
require("nvchad_ui.lsp")

local M = {}
local utils = require("core.utils")

-- export on_attach & capabilities for custom lspconfigs

M.on_attach = function(client, bufnr)
  utils.load_mappings("lspconfig", { buffer = bufnr })

  if client.server_capabilities.signatureHelpProvider then
    require("nvchad_ui.signature").setup(client)
  end

  if not utils.load_config().ui.lsp_semantic_tokens then
    client.server_capabilities.semanticTokensProvider = nil
  end
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()

M.capabilities.textDocument.completion.completionItem = {
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
}

local lspconfig = require("lspconfig")
local home = os.getenv("HOME")

lspconfig.lua_ls.setup({
  on_attach = M.on_attach,
  capabilities = M.capabilities,

  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
          [vim.fn.stdpath("data") .. "/lazy/extensions/nvchad_types"] = true,
          [vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy"] = true,
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
    },
  },
})

-- golang
lspconfig.gopls.setup({
  on_attach = M.on_attach,
  capabilities = M.capabilities,
  cmd = { home .. "/.local/share/nvim/mason/bin/gopls" },
})

-- csharp
local pid = vim.fn.getpid()
lspconfig.omnisharp.setup({
  on_attach = M.on_attach,
  capabilities = M.capabilities,
  cmd = { home .. "/.local/share/nvim/mason/bin/omnisharp", "--languageserver", "--hostPID", tostring(pid) },
})

-- python
lspconfig.pylsp.setup({
  on_attach = M.on_attach,
  capabilities = M.capabilities,
  cmd = { home .. "/.local/share/nvim/mason/bin/pylsp" },
})

-- javascript / typescript
lspconfig.tsserver.setup({
  on_attach = M.on_attach,
  capabilities = M.capabilities,
  cmd = { home .. "/.local/share/nvim/mason/bin/typescript-language-server", "--stdio" },
})

-- rust
lspconfig.rust_analyzer.setup({
  granularity = {
    group = "module",
  },
  cargo = {
    buildScripts = {
      enable = true,
    },
    procMacro = {
      enable = true,
    },
  },
  cmd = { home .. "/.local/share/nvim/mason/bin/rust-analyzer" }
})

return M
