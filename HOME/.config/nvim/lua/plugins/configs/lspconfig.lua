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
  on_attach = function(client, bufnr)
    utils.load_mappings("lspconfig", { buffer = bufnr })

    -- Helper to run the "source.organizeImports" code action synchronously
    local function organize_imports(timeout_ms)
      local params = vim.lsp.util.make_range_params()
      params.context = { only = { "source.organizeImports" }, diagnostics = {} }

      -- Use the buffer number for the request so it targets the correct document
      local results = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, timeout_ms)
      if not results then return end

      for _, res in pairs(results or {}) do
        for _, r in pairs(res.result or {}) do
          if r.edit then
            vim.lsp.util.apply_workspace_edit(r.edit, "utf-8")
          elseif r.command then
            vim.lsp.buf.execute_command(r.command)
          end
        end
      end
    end

    -- Enable organizing imports and formatting on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        -- First, organize imports (synchronously) with a 1s timeout
        organize_imports(1000)

        -- Then format (if supported)
        if client.server_capabilities.documentFormattingProvider then
          vim.lsp.buf.format({ async = true })
        end
      end,
    })
  end,
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

lspconfig.ruff.setup({
  on_attach = M.on_attach,
  capabilities = M.capabilities,
})

-- javascript / typescript
lspconfig.ts_ls.setup({
  on_attach = M.on_attach,
  capabilities = M.capabilities,
  cmd = { home .. "/.local/share/nvim/mason/bin/typescript-language-server", "--stdio" },
  single_file_support = false,
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

-- emmet
lspconfig.emmet_ls.setup({
  on_attach = M.on_attach,
  capabilities = M.capabilities,
  cmd = { home .. "/.local/share/nvim/mason/bin/emmet-ls", "--stdio" },
})

-- css-lsp
lspconfig.cssls.setup({
  on_attach = M.on_attach,
  capabilities = M.capabilities,
  cmd = { home .. "/.local/share/nvim/mason/bin/vscode-css-language-server", "--stdio" },
})

return M
