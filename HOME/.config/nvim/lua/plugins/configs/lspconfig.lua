local M = {}
local utils = require("core.utils")

-- export on_attach & capabilities for custom lspconfigs

M.on_attach = function(client, bufnr)
  utils.load_mappings("lspconfig", { buffer = bufnr })

  -- if client.server_capabilities.signatureHelpProvider then
  -- require("nvchad.signature").setup(client)
  -- end

  -- if not utils.load_config().ui.lsp_semantic_tokens then
  -- client.server_capabilities.semanticTokensProvider = nil
  -- end

  -- gopls auto format and organize imports on save
  -- https://github.com/neovim/nvim-lspconfig/issues/115#issuecomment-1801096383
  --   if client.name == "gopls" then
  --     local golang_organize_imports = function(isPreflight)
  --       local params = vim.lsp.util.make_range_params(nil, vim.lsp.util._get_offset_encoding(bufnr))
  --       params.context = { only = { "source.organizeImports" } }
  --
  --       if isPreflight then
  --         vim.lsp.buf_request(bufnr, "textDocument/codeAction", params, function() end)
  --         return
  --       end
  --
  --       local result = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 3000)
  --       for _, res in pairs(result or {}) do
  --         for _, r in pairs(res.result or {}) do
  --           if r.edit then
  --             vim.lsp.util.apply_workspace_edit(r.edit, vim.lsp.util._get_offset_encoding(bufnr))
  --           else
  --             vim.lsp.buf.execute_command(r.command)
  --           end
  --         end
  --       end
  --     end
  --
  --     golang_organize_imports(true)
  --
  --     vim.api.nvim_create_autocmd("BufWritePre", {
  --       pattern = "*.go",
  --       group = vim.api.nvim_create_augroup("LspGolangOrganizeImports" .. bufnr, {}),
  --       callback = function()
  --         golang_organize_imports()
  --       end,
  --     })
  --     end
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

M.capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}

local lspconfig = require("lspconfig")
local home = os.getenv("HOME")

-- override lsp floating window border
-- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization
local function border(hl_name)
  return {
    { "┌", hl_name },
    { "─", hl_name },
    { "┐", hl_name },
    { "│", hl_name },
    { "┘", hl_name },
    { "─", hl_name },
    { "└", hl_name },
    { "│", hl_name },
  }
end
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts)
  opts = opts or {}
  opts.border = opts.border or border("FloatBorder")
  return orig_util_open_floating_preview(contents, syntax, opts)
end

-- add border to LspInfo
-- https://vi.stackexchange.com/a/39001
require("lspconfig.ui.windows").default_options.border = "single"

-- lua
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
          [vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy"] = true,
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
    },
  },
})

-- c, c++
lspconfig.clangd.setup({
  on_attach = M.on_attach,
  capabilities = M.capabilities,
  cmd = { home .. "/.local/share/nvim/mason/bin/clangd" },
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
  handlers = {
    ["textDocument/definition"] = require("omnisharp_extended").handler,
  },
  settings = {
    FormattingOptions = {
      EnableEditorConfigSupport = false,
      OrganizeImports = false,
    },
    RoslynExtensionsOptions = {
      EnableAnalyzersSupport = false,
      EnableImportCompletion = false,
      AnalyzeOpenDocumentsOnly = nil,
    },
    Sdk = {
      IncludePrereleases = true,
    },
  },
  cmd = { home .. "/.local/share/nvim/mason/bin/omnisharp", "--languageserver", "--hostPID", tostring(pid) },
})

-- python
lspconfig.pyright.setup({
  on_attach = M.on_attach,
  capabilities = M.capabilities,
  cmd = { home .. "/.local/share/nvim/mason/bin/pyright-langserver", "--stdio" },
})

-- javascript / typescript
lspconfig.tsserver.setup({
  on_attach = M.on_attach,
  capabilities = M.capabilities,
  cmd = { home .. "/.local/share/nvim/mason/bin/typescript-language-server", "--stdio" },
})

-- rust
lspconfig.rust_analyzer.setup({
  on_attach = M.on_attach,
  capabilities = M.capabilities,
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
  cmd = { home .. "/.local/share/nvim/mason/bin/rust-analyzer" },
})

-- emmet
lspconfig.emmet_ls.setup({
  on_attach = M.on_attach,
  capabilities = M.capabilities,
  cmd = { home .. "/.local/share/nvim/mason/bin/emmet-ls", "--stdio" },
})

-- sql
lspconfig.sqls.setup({
  on_attach = M.on_attach,
  capabilities = M.capabilities,
  cmd = { home .. "/.local/share/nvim/mason/bin/sqls" },
})

return M
