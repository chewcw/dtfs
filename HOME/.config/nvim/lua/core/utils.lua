local M = {}
local merge_tb = vim.tbl_deep_extend

-- load custom highlight group
M.load_highlight_group = function()
  -- -- vim lsp related highlight group
  -- vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true })
  -- vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { undercurl = true })
  -- vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { undercurl = true })
  -- vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { undercurl = true })
  -- vim.api.nvim_set_hl(0, "DiagnosticUnnecessary", {
  --   undercurl = true,
  --   foreground = vim.api.nvim_get_hl_by_name("Conceal", {}).foreground,
  -- })
  -- local diagnosticError = vim.api.nvim_get_hl_by_name("DiagnosticError", {})
  -- vim.api.nvim_set_hl(
  --   0,
  --   "DiagnosticVirtualTextError",
  --   { foreground = diagnosticError.foreground }
  -- )
  -- local diagnosticWarn = vim.api.nvim_get_hl_by_name("DiagnosticWarn", {})
  -- vim.api.nvim_set_hl(
  --   0,
  --   "DiagnosticVirtualTextWarn",
  --   { foreground = diagnosticWarn.foreground }
  -- )
  -- local diagnosticInfo = vim.api.nvim_get_hl_by_name("DiagnosticInfo", {})
  -- vim.api.nvim_set_hl(
  --   0,
  --   "DiagnosticVirtualTextInfo",
  --   { foreground = diagnosticInfo.foreground }
  -- )
  -- local diagnosticHint = vim.api.nvim_get_hl_by_name("DiagnosticHint", {})
  -- vim.api.nvim_set_hl(
  --   0,
  --   "DiagnosticVirtualTextHint",
  --   { foreground = diagnosticHint.foreground }
  -- )
  --
  -- -- normal
  -- vim.api.nvim_set_hl(0, "Normal", { fg = "#bcbcbc", bg = "#050b0c" })
  -- vim.api.nvim_set_hl(0, "NormalNC", { fg = "#bcbcbc", bg = "#141819" })
  -- vim.api.nvim_set_hl(0, "NormalSB", { fg = "#bcbcbc", bg = "#141819" })
  --
  -- -- search highlight
  -- vim.api.nvim_set_hl(0, "Search", { link = "Cursor" })
  -- vim.api.nvim_set_hl(0, "IncSearch", { link = "Cursor" })
  --
  -- -- visual
  -- vim.api.nvim_set_hl(0, "Visual", {
  --   fg = "None",
  --   bg = vim.api.nvim_get_hl_by_name("NonText", {}).foreground
  -- })
  -- vim.api.nvim_set_hl(0, "VisualNC", {
  --   fg = "None",
  --   bg = vim.api.nvim_get_hl_by_name("NonText", {}).foreground
  -- })
  --
  -- -- float
  -- vim.api.nvim_set_hl(0, "FloatBorder", {
  --   bg = vim.api.nvim_get_hl_by_name("Normal", {}).background,
  --   fg = vim.api.nvim_get_hl_by_name("Normal", {}).foreground,
  -- })
  --
  -- -- split
  -- vim.api.nvim_set_hl(0, "VertSplit", {
  --     fg = vim.api.nvim_get_hl_by_name("VertSplit", {}).foreground,
  --     bg = "None",
  --   })
  --
  -- -- winbar
  -- vim.api.nvim_set_hl(0, "WinBar", { link = "Normal" })
  -- vim.api.nvim_set_hl(0, "WinBarNC", { link = "NormalNC" })
  --
  -- -- Pmenu
  -- vim.api.nvim_set_hl(0, "Pmenu", { link = "FloatBorder" })
  -- vim.api.nvim_set_hl(0, "PmenuSBar", { default })
  --
  -- -- whichkey
  -- vim.api.nvim_set_hl(0, "WhichKeyFloat", { link = "FloatBorder" })
  --
  -- -- statusline
  -- vim.api.nvim_set_hl(0, "StatusLine", { link = "Normal" })
  -- vim.api.nvim_set_hl(0, "StatusLineNC", { link = "NormalNC" })
  --
  -- -- sign column
  -- vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
  --
  -- -- nvimtree
  -- vim.api.nvim_set_hl(0, "NvimTreeNormal", { link = "Normal" })
  -- vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { link = "NormalNC" })
  -- vim.api.nvim_set_hl(0, "NvimTreeLineNr", { link = "Normal" })
  --
  -- -- normal float
  -- local float = vim.api.nvim_get_hl_by_name("FloatBorder", {})
  -- local normal = vim.api.nvim_get_hl_by_name("Normal", {})
  -- vim.api.nvim_set_hl(0, "NormalFloat", {
  --   foreground = float.foreground,
  --   background = normal.background,
  -- })
  --
  -- -- diff
  -- vim.api.nvim_set_hl(0, "DiffAdd", { ctermbg = 0, bg = "#132f33" })
  -- vim.api.nvim_set_hl(0, "DiffAdded", { ctermbg = 0, bg = "#132f33" })
  -- vim.api.nvim_set_hl(0, "DiffChange", { ctermbg = 0, fg = "#c5c5c6", bg = "#05294a" })
  -- vim.api.nvim_set_hl(0, "DiffChanged", { ctermbg = 0, bg = "#05294a" })
  -- vim.api.nvim_set_hl(0, "DiffDelete", { ctermbg = 0, bg = "#4c0f0f" })
  -- vim.api.nvim_set_hl(0, "DiffRemoved", { ctermbg = 0, bg = "#4c0f0f" })
  -- vim.api.nvim_set_hl(0, "DiffText", { link = "DiffChange" })
  -- vim.api.nvim_set_hl(0, "DiffModified", { ctermbg = 0, bg = "#3c4e77" })
  -- vim.api.nvim_set_hl(0, "DiffChangeDelete", { ctermbg = 0, bg = "#674ea7" })
  -- vim.api.nvim_set_hl(0, "DiffNewFile", { ctermbg = 0, bg = "#3c4e77" })
  --
  -- -- neogit
  -- vim.api.nvim_set_hl(0, "NeogitDiffAdd", { link = "DiffAdd" })
  -- vim.api.nvim_set_hl(0, "NeogitDiffAdded", { link = "DiffAdded" })
  -- vim.api.nvim_set_hl(0, "NeogitDiffChange", { link = "DiffChange" })
  -- vim.api.nvim_set_hl(0, "NeogitDiffChanged", { link = "DiffChanged" })
  -- vim.api.nvim_set_hl(0, "NeogitDiffDelete", { link = "DiffDelete" })
  -- vim.api.nvim_set_hl(0, "NeogitDiffRemoved", { link = "DiffRemoved" })
  -- vim.api.nvim_set_hl(0, "NeogitDiffText", { link = "DiffText" })
  -- vim.api.nvim_set_hl(0, "NeogitDiffModified", { link = "DiffModified" })
  -- vim.api.nvim_set_hl(0, "NeogitDiffChangeDelete", { link = "DiffChangeDelete" })
  -- vim.api.nvim_set_hl(0, "NeogitDiffNewFile", { link = "DiffNewFile" })
  -- vim.api.nvim_set_hl(0, "NeogitDiffAddHighlight", {})
  -- vim.api.nvim_set_hl(0, "NeogitDiffcontext", { link = "NormalNC" })
  -- vim.api.nvim_set_hl(0, "NeogitDiffContextHighlight", { link = "Normal" })
  -- vim.api.nvim_set_hl(0, "NeogitDiffDeleteHighlight", {})
  -- vim.api.nvim_set_hl(0, "NeogitDiffHeaderHighlight", {})
  --
  -- -- treesitter context
  -- vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { link = "NonText"})
  -- vim.api.nvim_set_hl(0, "TreesitterContext", { link = "Normal" })
  -- vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", {
  --   fg = vim.api.nvim_get_hl_by_name("LineNr", {}).foreground,
  --   bg = vim.api.nvim_get_hl_by_name("Normal", {}).background,
  -- })
  --
  -- -- color column
  -- vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#141819" })
  --
  -- -- space tab listchars
  -- -- vim.api.nvim_set_hl(0, "Label", { fg = "#555757" })
  -- vim.api.nvim_set_hl(0, "Whitespace", { fg = "#1d2324" })
  --
  -- -- indent-blankline
  -- vim.api.nvim_set_hl(0, "IndentBlanklineChar", { fg = "#1d2324" })
  -- vim.api.nvim_set_hl(0, "IndentBlanklineSpaceChar", { link = "IndentBlanklineChar" })
  -- vim.api.nvim_set_hl(0, "IndentBlanklineSpaceCharBlankline", { link = "IndentBlanklineChar" })
  -- vim.api.nvim_set_hl(0, "IndentBlanklineContextChar", { default, bg = vim.api.nvim_get_hl_by_name("Whitespace", {}).foreground })
  -- vim.api.nvim_set_hl(0, "IndentBlanklineContextSpaceChar", { default })
  --
  -- -- text
  -- vim.cmd([[ highlight! String cterm=NONE gui=NONE ]])
  -- -- vim.api.nvim_set_hl(0, "Character", { link = "String" })
  -- vim.api.nvim_set_hl(0, "Comment", { fg = vim.api.nvim_get_hl_by_name("Folded", {}).foreground })
  -- vim.api.nvim_set_hl(0, "Special", { link = "Identifier" })
  -- vim.api.nvim_set_hl(0, "Function", { fg = "#8d91d4" })
  -- vim.api.nvim_set_hl(0, "Keyword", { fg = "#d4d08d" })
  -- vim.api.nvim_set_hl(0, "Structure", { link = "Type" })
  -- vim.api.nvim_set_hl(0, "Operator", { link = "Delimiter" })
  --
  -- -- cursor line
  -- vim.api.nvim_set_hl(0, "LineNr", { link = "Whitespace" })
  -- vim.api.nvim_set_hl(0, "CursorLine", { default })
  -- vim.api.nvim_set_hl(0, "CursorLineNr", { default })
  --
  -- -- telescope
  -- vim.api.nvim_set_hl(0, "TelescopeBorder", { link = "FloatBorder" })
  -- vim.api.nvim_set_hl(0, "TelescopePromptBorder", { link = "FloatBorder" })
  -- vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { link = "FloatBorder" })
  -- vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { link = "FloatBorder" })
  -- vim.api.nvim_set_hl(0, "TelescopePromptNormal", { link = "Normal" })
  -- vim.api.nvim_set_hl(0, "TelescopeNormal", { link = "Normal" })
end

M.load_config = function()
  local config = require("core.default_config")

  config.mappings = require("core.mappings")
  config.mappings.disabled = nil

  -- TODO: chewcw - put somewhere else wouldn't work, why?
  -- vim diagnostic default configuration
  vim.diagnostic.config({
    virtual_text = true,
    underline = true,
  })

  return config
end

M.remove_disabled_keys = function(chadrc_mappings, default_mappings)
  -- if not chadrc_mappings then
  --   return default_mappings
  -- end
  --
  -- -- store keys in a array with true value to compare
  -- local keys_to_disable = {}
  -- for _, mappings in pairs(chadrc_mappings) do
  --   for mode, section_keys in pairs(mappings) do
  --     if not keys_to_disable[mode] then
  --       keys_to_disable[mode] = {}
  --     end
  --     section_keys = (type(section_keys) == "table" and section_keys) or {}
  --     for k, _ in pairs(section_keys) do
  --       keys_to_disable[mode][k] = true
  --     end
  --   end
  -- end
  --
  -- -- make a copy as we need to modify default_mappings
  -- for section_name, section_mappings in pairs(default_mappings) do
  --   for mode, mode_mappings in pairs(section_mappings) do
  --     mode_mappings = (type(mode_mappings) == "table" and mode_mappings) or {}
  --     for k, _ in pairs(mode_mappings) do
  --       -- if key if found then remove from default_mappings
  --       if keys_to_disable[mode] and keys_to_disable[mode][k] then
  --         default_mappings[section_name][mode][k] = nil
  --       end
  --     end
  --   end
  -- end
  --
  -- return default_mappings
end

M.load_mappings = function(section, mapping_opt)
  vim.schedule(function()
    local function set_section_map(section_values)
      if section_values.plugin then
        return
      end

      section_values.plugin = nil

      for mode, mode_values in pairs(section_values) do
        local default_opts = merge_tb("force", { mode = mode }, mapping_opt or {})
        for keybind, mapping_info in pairs(mode_values) do
          -- merge default + user opts
          local opts = merge_tb("force", default_opts, mapping_info.opts or {})

          mapping_info.opts, opts.mode = nil, nil
          opts.desc = mapping_info[2]

          vim.keymap.set(mode, keybind, mapping_info[1], opts)
        end
      end
    end

    local mappings = require("core.utils").load_config().mappings

    if type(section) == "string" then
      mappings[section]["plugin"] = nil
      mappings = { mappings[section] }
    end

    for _, sect in pairs(mappings) do
      set_section_map(sect)
    end
  end)
end

M.lazy_load = function(plugin)
  vim.api.nvim_create_autocmd({ "BufRead", "BufWinEnter", "BufNewFile" }, {
    group = vim.api.nvim_create_augroup("BeLazyOnFileOpen" .. plugin, {}),
    callback = function()
      local file = vim.fn.expand("%")
      local condition = file ~= "NvimTree_1" and file ~= "[lazy]" and file ~= ""

      if condition then
        vim.api.nvim_del_augroup_by_name("BeLazyOnFileOpen" .. plugin)

        -- dont defer for treesitter as it will show slow highlighting
        -- This deferring only happens only when we do "nvim filename"
        if plugin ~= "nvim-treesitter" then
          vim.schedule(function()
            require("lazy").load({ plugins = plugin })

            if plugin == "nvim-lspconfig" then
              vim.cmd("silent! do FileType")
            end
          end, 0)
        else
          require("lazy").load({ plugins = plugin })
        end
      end
    end,
  })
end

M.dump = function(o)
  if type(o) == "table" then
    local s = "{ "
    for k, v in pairs(o) do
      if type(k) ~= "number" then
        k = '"' .. k .. '"'
      end
      s = s .. "[" .. k .. "] = " .. M.dump(v) .. ","
    end
    return s .. "} "
  else
    return tostring(o)
  end
end

-- Function to close current tab and focus on previous tab
M.close_and_focus_previous_tab = function()
  -- Get the index of the current tabpage
  local current_tabpage = vim.fn.tabpagenr()

  -- Close the current tabpage
  pcall(function()
    vim.api.nvim_command("tabclose")
  end)

  -- Calculate the index of the previous tabpage
  local previous_tabpage = current_tabpage - 1
  if previous_tabpage < 1 then
    previous_tabpage = 1
  end

  -- Go to the previous tabpage
  vim.api.nvim_command("tabnext " .. previous_tabpage)
end

return M
