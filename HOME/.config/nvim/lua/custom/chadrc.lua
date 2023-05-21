---@type ChadrcConfig
local M = {}

M.ui = {
  theme = "github_dark",
  theme_toggle = { "github_dark", "one_light" },

  hl_override = {
    Comment = {
      italic = true,
    },
    CursorLine = {
      bg = "black2",
    },
    Folded = {
      bg = "black2",
      fg = "light_grey",
    },
    St_InsertMode = {
      bg = "purple",
      fg = "black",
    },
    St_InsertmodeText = {
      fg = "purple",
    },
    St_InsertModeSep = {
      fg = "purple",
    },
    St_VisualMode = {
      bg = "teal",
      fg = "black",
    },
    St_VisualModeSep = {
      fg = "teal",
    },
    St_NormalMode = {
      bg = "one_bg",
      fg = "white",
    },
    St_NormalmodeText = {
      fg = "white",
    },
    St_NormalModeSep = {
      fg = "one_bg",
    },
    St_ReplaceMode = {
      bg = "orange",
      fg = "black",
    },
    St_TerminalMode = {
      bg = "purple",
      fg = "black",
    },
    St_TerminalModeSep = {
      bg = "one_bg",
      fg = "purple",
    },
    St_TerminalmodeText = {
      fg = "purple",
    },
    St_NTerminalMode = {
      bg = "one_bg",
      fg = "white",
    },
    St_NTerminalModeSep = {
      fg = "one_bg",
    },
    St_NTerminalmodeText = {
      bg = "one_bg",
      fg = "white",
    },
    St_file_info = {
      fg = "yellow",
      italic = true,
    },
  },

  hl_add = {
    -- NvimTreeOpenedFolderName = { fg = "green", bold = true },
  },
}

M.plugins = "custom.plugins"

-- check core.mappings for table structure
M.mappings = require("custom.mappings")

return M
