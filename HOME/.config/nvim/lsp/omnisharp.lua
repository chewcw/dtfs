local home = os.getenv("HOME")
local pid = vim.fn.getpid()

local get_omnisharp_extended_handler = function()
  if pcall(require, "omnisharp_extended") then
    return require("omnisharp_extended").handler
  else
    return {}
  end
end

return {
  handlers = {
    ["textDocument/definition"] = get_omnisharp_extended_handler(),
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
}
