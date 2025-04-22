local utils_colors = require("core.utils_colors")

local colors = function()
  return {
    -- Basic
    bg = "#030a0e",
    bg_nc = "#232628",
    fg = "#a9a9a9",
    -- Normal
    main1 = "#75a0bc",
    main2 = "#929356",
    main3 = "#F4F7C5",
    main4 = "#AACDBE",
    main5 = "#C19D68",
    black = "#010507",
    red = "#aa4e4e",
    green = "#618b79",
    yellow = "#e5c114",
    magenta = "#8a50a2",
    cyan = "#94c9b2",
    white = "#dfdfdf",
    brown = "#FFBF9B",
    blue = "#1d2831",
    pink = "#c082a1",
    khaki = "#c0c082",
    -- Bright
    bright_black = "#4c4c4b",
    bright_red = "#ffafa5",
    bright_green = "#7aae98",
    bright_yellow = "#e7c72b",
    bright_blue = "#a6cded",
    bright_magenta = "#ac82bd",
    bright_cyan = "#deeee7",
    bright_white = "#eaeaea",
    bright_brown = "#b29c8f",
    -- Dark
    dark_yellow = "#5b4d08",
    dark_yellow02 = "#3f3505",
    dark_green = "#12412c",
    dark_green02 = "#0c291c",
    dark_red = "#3f0f13",
    dark_blue = "#081923",
    dark_magenta = "#3d2e43",
    dark_brown = "#462b24",
    dark_cyan = "#4a6459",
    dark_main4 = "#111413",
    dark_pink = "#552b40",
    dark_purple = "#3e0e52",
    -- Grays
    gray00 = "#1b1b1a",
    gray01 = "#222221",
    gray02 = "#2a2a29",
    gray03 = "#323231",
    gray04 = "#3a3a39",
    gray05 = "#6a6a69",
    gray06 = "#767675",
    gray07 = "#b6b6b5",
    -- Reds
    red00 = "#994646",
    red01 = "#883e3e",
    red02 = "#763636",
    red03 = "#3e1c1c",
    red04 = "#2c1414",
    -- Yellows
    yellow00 = "#cead12",
    yellow01 = "#b79a10",
    yellow02 = "#a0870e",
    -- Blues
    blue00 = "#1a242c",
    blue01 = "#172027",
    blue02 = "#141c22",
    -- Special
    none = "NONE",
    -- Diagnostic virtual text
    diagnostic_virtual_text_error = "#361818",
    diagnostic_virtual_text_warn = "#493d06",
    diagnostic_virtual_text_info = "#222222",
    diagnostic_virtual_text_hint = "#1d1d1c",
    -- visual
    visual = "#12363b",
  }
end

vim.api.nvim_command("hi clear")
if vim.fn.exists("syntax_on") then
  vim.api.nvim_command("syntax reset")
end

vim.o.termguicolors = true
-- vim.g.colors_name = "rasmus2"
-- vim.o.background = "dark"

utils_colors.setup(colors())

