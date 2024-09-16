local bufferline = require("bufferline")

local M = {}

M.setup = {
  options = {
    mode = "tabs",
    themable = true,
    style_preset = bufferline.style_preset.minimal,
    show_buffer_icons = false,
    show_buffer_close_icons = false,
    show_close_icon = false,
    show_tab_indicators = false,
    show_duplicate_prefix = false,
    duplicates_across_groups = false,
    modified_icon = "[+]",
    separator_style = "none",
    truncate_names = false,
    move_wraps_at_ends = false,
    -- enforce_regular_tabs = true,
    -- tab_size = 10,
    indicator = {
      style = "none",
    },
    name_formatter = function(buf)
      local tabnr_ordinal = vim.api.nvim_tabpage_get_number(buf.tabnr)
      local win_num = vim.fn.tabpagewinnr(tabnr_ordinal)
      local working_directory = vim.fn.getcwd(win_num, tabnr_ordinal)

      local cwd_parent = vim.fn.fnamemodify(working_directory, ":h:t")
      local cwd_name = vim.fn.fnamemodify(working_directory, ":t:r")

      if buf.name:match("toggleterm") then
        return "ToggleTerm"
      end

      if buf.name:match("zsh") then
        return "Term"
      end

      if vim.g.toggle_tab_cwd == "1" then -- show tab's cwd (see user command "ToggleTabCwd")
        return buf.tabnr .. "🖿 " .. cwd_parent .. "/" .. cwd_name
      elseif vim.g.toggle_tab_cwd == "2" then
        return tostring(buf.tabnr)
      elseif vim.g.toggle_tab_cwd == "3" then
        return "🖿 " .. cwd_parent .. "/" .. cwd_name
      elseif vim.g.toggle_tab_cwd == "4" then
        if tabnr_ordinal == vim.fn.tabpagenr() then
          return "🗎 " .. buf.name
        else
          return "🖿 " .. cwd_parent .. "/" .. cwd_name
        end
      elseif vim.g.toggle_tab_cwd == "5" then
        if tabnr_ordinal == vim.fn.tabpagenr() then
          return "🗎 " .. buf.name
        else
          return "🖿 " .. cwd_parent .. "/" .. cwd_name .. " 🗎 " .. buf.name
        end
      elseif vim.g.toggle_tab_cwd == "6" then
        return "🖿 " .. cwd_parent .. "/" .. cwd_name .. " 🗎 " .. buf.name
      else
        return "🗎 " .. buf.name
      end
    end,
    offsets = {
      {
        filetype = "NvimTree",
        text = "File Explorer",
        highlight = "Directory",
        separator = true, -- use a "true" to enable the default, or set your own character
      },
    },
  },
  highlights = {
    buffer_selected = {
      bg = { attribute = "bg", highlight = "TablineSel", italic = false },
      italic = false,
      bold = false,
    },
    modified_selected = {
      bg = { attribute = "bg", highlight = "TablineSel", italic = false },
      italic = false,
      bold = false,
    },
  },
}

return M
