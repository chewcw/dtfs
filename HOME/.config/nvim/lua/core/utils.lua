local M = {}
local merge_tb = vim.tbl_deep_extend

-- load custom highlight group
-- don't know where to put these code
M.load_highlight_group = function()
  -- vim lsp related highlight group
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true })
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { undercurl = true })
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { undercurl = true })
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { undercurl = true })
  local diagnosticError = vim.api.nvim_get_hl_by_name("DiagnosticError", {})
  vim.api.nvim_set_hl(
    0,
    "DiagnosticVirtualTextError",
    { foreground = diagnosticError.foreground, italic = true, underdotted = true }
  )
  local diagnosticWarn = vim.api.nvim_get_hl_by_name("DiagnosticWarn", {})
  vim.api.nvim_set_hl(
    0,
    "DiagnosticVirtualTextWarn",
    { foreground = diagnosticWarn.foreground, italic = true, underdotted = true }
  )
  local diagnosticInfo = vim.api.nvim_get_hl_by_name("DiagnosticInfo", {})
  vim.api.nvim_set_hl(
    0,
    "DiagnosticVirtualTextInfo",
    { foreground = diagnosticInfo.foreground, italic = true, underdotted = true }
  )
  local diagnosticHint = vim.api.nvim_get_hl_by_name("DiagnosticHint", {})
  vim.api.nvim_set_hl(
    0,
    "DiagnosticVirtualTextHint",
    { foreground = diagnosticHint.foreground, italic = true, underdotted = true }
  )

  -- normal float
  local float = vim.api.nvim_get_hl_by_name("FloatBorder", {})
  local normal = vim.api.nvim_get_hl_by_name("Normal", {})
  vim.api.nvim_set_hl(0, "NormalFloat", {
    foreground = float.foreground,
    background = normal.background,
  })

  -- LspInfo border
  -- LspInfo was linked to Label highlight group
  vim.cmd([[highlight! link LspInfoBorder Label]])
  vim.api.nvim_set_hl(0, "LspInfoBorder", { link = "FloatBorder" })

  -- nvimdiff
  vim.api.nvim_set_hl(0, "DiffAdd", { ctermbg = 0, bg = "#132f33" })
  vim.api.nvim_set_hl(0, "DiffAdded", { ctermbg = 0, bg = "#132f33" })
  vim.api.nvim_set_hl(0, "DiffChange", { ctermbg = 0, fg = "#c5c5c6", bg = "#05294a" })
  vim.api.nvim_set_hl(0, "DiffChanged", { ctermbg = 0, bg = "#05294a" })
  vim.api.nvim_set_hl(0, "DiffDelete", { ctermbg = 0, bg = "#4c0f0f" })
  vim.api.nvim_set_hl(0, "DiffRemoved", { ctermbg = 0, bg = "#4c0f0f" })
  vim.api.nvim_set_hl(0, "DiffText", { link = "DiffChange" })
  vim.api.nvim_set_hl(0, "DiffModified", { ctermbg = 0, bg = "#3c4e77" })
  vim.api.nvim_set_hl(0, "DiffChangeDelete", { ctermbg = 0, bg = "#674ea7" })
  vim.api.nvim_set_hl(0, "DiffNewFile", { ctermbg = 0, bg = "#3c4e77" })

  -- visual
  vim.api.nvim_set_hl(0, "Visual", { fg = "Black", bg = "#f1c232" })
end

M.load_config = function()
  local config = require("core.default_config")
  local chadrc_path = vim.api.nvim_get_runtime_file("lua/custom/chadrc.lua", false)[1]

  if chadrc_path then
    local chadrc = dofile(chadrc_path)

    -- config.mappings = M.remove_disabled_keys(chadrc.mappings, require("core.mappings"))
    config.mappings = require("core.mappings")
    config = merge_tb("force", config, chadrc)
  end

  config.mappings.disabled = nil

  -- TODO: chewcw - put somewhere else wouldn't work, why?
  -- vim diagnostic default configuration
  vim.diagnostic.config({
    virtual_text = true,
    underline = true,
  })

  M.load_highlight_group()

  return config
end

M.remove_disabled_keys = function(chadrc_mappings, default_mappings)
  if not chadrc_mappings then
    return default_mappings
  end

  -- store keys in a array with true value to compare
  local keys_to_disable = {}
  for _, mappings in pairs(chadrc_mappings) do
    for mode, section_keys in pairs(mappings) do
      if not keys_to_disable[mode] then
        keys_to_disable[mode] = {}
      end
      section_keys = (type(section_keys) == "table" and section_keys) or {}
      for k, _ in pairs(section_keys) do
        keys_to_disable[mode][k] = true
      end
    end
  end

  -- make a copy as we need to modify default_mappings
  for section_name, section_mappings in pairs(default_mappings) do
    for mode, mode_mappings in pairs(section_mappings) do
      mode_mappings = (type(mode_mappings) == "table" and mode_mappings) or {}
      for k, _ in pairs(mode_mappings) do
        -- if key if found then remove from default_mappings
        if keys_to_disable[mode] and keys_to_disable[mode][k] then
          default_mappings[section_name][mode][k] = nil
        end
      end
    end
  end

  return default_mappings
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

return M
