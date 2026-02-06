local M = {}

local highlight = function(group, color)
  vim.api.nvim_set_hl(0, group, color)
end

local opt = function(key, default)
  key = "rasmus_" .. key
  if vim.g[key] == nil then
    return default
  end
  if vim.g[key] == 0 then
    return false
  end

  return vim.g[key]
end

local style = function(italic, bold)
  return { bold = bold, italic = italic }
end

local cfg = {
  transparent = opt("transparent", false),
  comment_style = style(opt("italic_comments", false), opt("bold_comments", false)),
  keyword_style = style(opt("italic_keywords", false), opt("bold_keywords", false)),
  boolean_style = style(opt("italic_booleans", false), opt("bold_booleans", false)),
  function_style = style(opt("italic_functions", false), opt("bold_functions", false)),
  variable_style = style(opt("italic_variables", false), opt("bold_variables", false)),
}

local get_highlight = function(group, type)
  return vim.api.nvim_get_hl(0, { name = group, link = false })[type]
end

local get_groups = function(color)
  vim.g.terminal_color_0 = color.black
  vim.g.terminal_color_1 = color.red
  vim.g.terminal_color_2 = color.main2
  vim.g.terminal_color_3 = color.yellow
  vim.g.terminal_color_4 = color.main1
  vim.g.terminal_color_5 = color.magenta
  vim.g.terminal_color_6 = color.main4
  vim.g.terminal_color_7 = color.white
  vim.g.terminal_color_8 = color.bright_black
  vim.g.terminal_color_9 = color.bright_red
  vim.g.terminal_color_10 = color.bright_green
  vim.g.terminal_color_11 = color.bright_yellow
  vim.g.terminal_color_12 = color.bright_blue
  vim.g.terminal_color_13 = color.bright_magenta
  vim.g.terminal_color_14 = color.bright_cyan
  vim.g.terminal_color_15 = color.bright_white
  vim.g.terminal_color_background = color.bg
  vim.g.terminal_color_foreground = color.fg

  -- additional
  highlight("@variable", { fg = color.main5 })
  highlight("@method", { fg = color.main3 })
  highlight("keyword", { fg = color.brown })

  -- GitSigns (used in tabline)
  highlight("TablineGitSignsAdd", { bg = color.blue, fg = get_highlight("DiffAdd", "bg"), bold = true })
  highlight("TablineGitSignsChange", { bg = color.blue, fg = get_highlight("DiffChange", "bg"), bold = true })
  highlight("TablineGitSignsDelete", { bg = color.blue, fg = get_highlight("DiffDelete", "bg"), bold = true })

  highlight("GitSignsAdd", { fg = get_highlight("DiffAdd", "bg"), bold = true })
  highlight("GitSignsChange", { fg = get_highlight("DiffChange", "bg"), bold = true })
  highlight("GitSignsDelete", { fg = get_highlight("DiffDelete", "bg"), bold = true })

  -- Markology
  vim.cmd([[ highlight! MarkologyHLl cterm=bold ctermfg=10 ctermbg=NONE guifg=Green guibg=NONE ]])
  vim.cmd([[ highlight! MarkologyHLm cterm=bold ctermfg=10 ctermbg=NONE guifg=Green guibg=NONE ]])
  vim.cmd([[ highlight! MarkologyHLo cterm=bold ctermfg=10 ctermbg=NONE guifg=Green guibg=NONE ]])
  vim.cmd([[ highlight! MarkologyHLu cterm=bold ctermfg=10 ctermbg=NONE guifg=Green guibg=NONE ]])

  return {
    -- Base
    -- Editor highlight groups
    Normal                               = { fg = color.fg, bg = cfg.transparent and color.none or color.bg },
    NormalNC                             = { fg = color.fg, bg = cfg.transparent and color.none or color.bg_nc },
    SignColumn                           = { fg = color.fg, bg = color.none },
    EndOfBuffer                          = { fg = color.gray03 },
    NormalFloat                          = { fg = get_highlight("FloatBorder", "fg"), bg = color.bg },
    FloatBorder                          = { fg = color.dark_cyan, bg = color.bg },
    ColorColumn                          = { fg = color.none, bg = color.bg_nc },
    Conceal                              = { fg = color.gray05 },
    Cursor                               = { bg = color.none, fg = color.none, reverse = false }, -- set both guifg and guibg to none to let the terminal emulator to render the color of cursor and text underneath
    CursorIM                             = { bg = color.bright_yellow, fg = color.black, reverse = false },
    CurSearch                            = { bg = color.magenta, fg = color.white, reverse = false },
    Directory                            = { fg = color.main1, bg = color.none },

    DiffAdd                              = { fg = color.none, bg = color.dark_green, bold = false, italic = false },
    DiffAdded                            = { fg = color.none, bg = color.dark_green, bold = false, italic = false },
    DiffChange                           = { fg = color.none, bg = color.dark_magenta, bold = false, italic = false },
    DiffChanged                          = { fg = color.none, bg = color.dark_magenta, bold = false, italic = false },
    DiffChangeDelete                     = { fg = color.none, bg = color.khaki, bold = false, italic = false },
    DiffDelete                           = { fg = color.none, bg = color.dark_red, bold = false, italic = false },
    DiffRemoved                          = { fg = color.none, bg = color.dark_red, bold = false, italic = false },
    DiffText                             = { fg = color.none, bg = color.dark_purple, bold = false, italic = false },
    DiffModified                         = { fg = color.none, bg = color.dark_magenta, bold = false, italic = false },
    DiffNewFile                          = { fg = color.none, bg = color.dark_green, bold = false, italic = false },

    -- diffview
    DiffviewStatusAdded                  = { fg = color.green },   -- DiffAdded
    DiffviewStatusModified               = { fg = color.magenta }, -- DiffChanged
    DiffviewFilePanelInsertions          = { fg = color.green },   -- DiffAdded
    DiffviewFilePanelDeletions           = { fg = color.red },     -- DiffRemoved

    ErrorMsg                             = { fg = color.red },
    Folded                               = { fg = color.gray04, bg = color.none, italic = true },
    FoldColumn                           = { fg = color.gray04 },
    IncSearch                            = { bg = color.bright_green, fg = color.black },
    LineNr                               = { fg = color.gray05 },
    CursorLineNr                         = { fg = color.yellow00 },
    MatchParen                           = {},
    ModeMsg                              = { fg = color.main4 },
    MoreMsg                              = { fg = color.main4 },
    NonText                              = { fg = color.gray01, bg = color.none },
    Pmenu                                = { bg = color.bg },
    PmenuSel                             = { fg = color.fg, bg = color.gray04 },
    PmenuSbar                            = { fg = color.fg, bg = color.gray02 },
    PmenuThumb                           = { fg = color.fg, bg = color.gray05 },
    Question                             = { fg = color.main2 },
    QuickFixLine                         = { fg = color.main2, bg = color.gray01 },
    qfLineNr                             = {},
    Search                               = { fg = color.white, bg = color.dark_brown },
    SpecialKey                           = { fg = color.gray01 },
    SpellBad                             = { fg = color.red, bg = color.none, italic = true, undercurl = true },
    SpellCap                             = { fg = color.main1, bg = color.none, italic = true, undercurl = true },
    SpellLocal                           = { fg = color.main4, bg = color.none, italic = true, undercurl = true },
    SpellRare                            = { fg = color.main4, bg = color.none, italic = true, undercurl = true },
    StatusLine                           = { fg = color.fg, bg = color.bg },
    StatusLineNC                         = { fg = color.fg, bg = color.gray03 },
    StatusLineTerm                       = { link = "StatusLine" },
    StatusLineTermNC                     = { link = "StatusLineNC" },
    TabLineFill                          = { fg = color.gray05, bg = color.none },
    TablineSel                           = { fg = color.fg, bg = color.dark_yellow02 },
    Tabline                              = { fg = color.fg, bg = color.dark_blue },
    Title                                = { fg = color.main4, bg = color.none },
    Visual                               = { fg = color.none, bg = color.visual },
    VisualNOS                            = { fg = color.none, bg = color.visual },
    WarningMsg                           = { fg = color.yellow },
    WildMenu                             = { fg = color.bg, bg = color.main1 },
    CursorColumn                         = { fg = color.none, bg = color.dark_blue },
    CursorLine                           = { fg = color.none, bg = color.dark_blue },
    ToolbarLine                          = { fg = color.fg, bg = color.gray01 },
    ToolbarButton                        = { fg = color.fg, bg = color.none },
    NormalMode                           = { fg = color.main4, bg = color.none, reverse = true },
    InsertMode                           = { fg = color.main2, bg = color.none, reverse = true },
    VisualMode                           = { fg = color.visual, bg = color.none, reverse = true },
    VertSplit                            = { fg = color.gray04 },
    WinSeparator                         = { fg = color.gray04 },
    CommandMode                          = { fg = color.gray05, bg = color.none, reverse = true },
    Warnings                             = { fg = color.yellow },
    healthError                          = { fg = color.red },
    healthSuccess                        = { fg = color.main2 },
    healthWarning                        = { fg = color.yellow },
    --common
    Type                                 = { fg = color.main4 }, -- int, long, char, etc.
    StorageClass                         = { fg = color.main4 }, -- static, register, volatile, etc.
    Structure                            = { fg = color.fg },    -- struct, union, enum, etc.
    Constant                             = { fg = color.main4 }, -- any constant
    Comment                              = {
      fg = color.gray05,
      bg = color.none,
      bold = cfg.comment_style.bold,
      italic = cfg.comment_style.italic,
    }, -- italic comments
    Conditional                          = {
      fg = color.main1,
      bg = color.none,
      bold = cfg.keyword_style.bold,
      italic = cfg.keyword_style.italic,
    }, -- italic if, then, else, endif, switch, etc.
    Keyword                              = {
      fg = color.main2,
      bg = color.none,
      bold = cfg.keyword_style.bold,
      italic = cfg.keyword_style.italic,
    },
    Repeat                               = { fg = color.main2, bg = color.none, bold = cfg.keyword_style.bold, italic = cfg.keyword_style.italic }, -- italic any other keyword
    Boolean                              = {
      fg = color.main4,
      bg = color.none,
      bold = cfg.boolean_style.bold,
      italic = cfg.boolean_style.italic,
    }, -- true , false
    Function                             = {
      fg = color.main3,
      bg = color.none,
      bold = cfg.function_style.bold,
      italic = cfg.function_style.italic,
    },
    Identifier                           = { fg = color.main1, bg = color.none },                   -- any variable name
    String                               = { fg = color.main4, bg = color.none },                   -- Any string
    Character                            = { fg = color.main4 },                                    -- any character constant: 'c', '\n'
    Number                               = { fg = color.main4 },                                    -- a number constant: 5
    Float                                = { fg = color.main4 },                                    -- a floating point constant: 2.3e10
    Statement                            = { fg = color.main2 },                                    -- any statement
    Label                                = { fg = color.main4 },                                    -- case, default, etc.
    Operator                             = { fg = color.gray07 },                                   -- sizeof", "+", "*", etc.
    Exception                            = { fg = color.main2 },                                    -- try, catch, throw
    PreProc                              = { fg = color.main1 },                                    -- generic Preprocessor
    Include                              = { fg = color.main1 },                                    -- preprocessor #include
    Define                               = { fg = color.main4 },                                    -- preprocessor #define
    Macro                                = { fg = color.main1 },                                    -- same as Define
    Typedef                              = { fg = color.main4 },                                    -- A typedef
    PreCondit                            = { fg = color.main4 },                                    -- preprocessor #if, #else, #endif, etc.
    Special                              = { fg = color.main3, bg = color.none },                   -- any special symbol
    SpecialChar                          = { fg = color.main3 },                                    -- special character in a constant
    Tag                                  = { fg = color.main3 },                                    -- you can use CTRL-] on this
    Delimiter                            = { fg = color.gray07 },                                   -- character that needs attention like , or .
    SpecialComment                       = { fg = color.main1 },                                    -- special things inside a comment
    Debug                                = { fg = color.main4 },                                    -- debugging statements
    Underlined                           = { fg = color.main4, bg = color.none, underline = true }, -- text that stands out, HTML links
    Ignore                               = { fg = color.gray07 },                                   -- left blank, hidden
    Error                                = { fg = color.red, bg = color.none, underline = true },   -- any erroneous construct
    Todo                                 = { fg = color.main4, bg = color.none, italic = true },    -- anything that needs extra attention; mostly the keywords TODO FIXME and XXX
    Highlight                            = { fg = color.none, bg = color.gray00 },
    -- HTML
    htmlArg                              = { fg = color.fg },
    htmlBold                             = { fg = color.fg, bg = color.none, bold = true },
    htmlEndTag                           = { fg = color.fg },
    htmlStyle                            = { fg = color.main4, bg = color.none },
    htmlLink                             = { fg = color.main4 },
    htmlSpecialChar                      = { fg = color.main2 },
    htmlSpecialTagName                   = { fg = color.main2 },
    htmlTag                              = { link = "Tag" },
    htmlTagN                             = { link = "Tag" },
    htmlTagName                          = { link = "Tag" },
    htmlTitle                            = { fg = color.fg },
    htmlH1                               = { fg = color.main1 },
    htmlH2                               = { fg = color.main1 },
    htmlH3                               = { fg = color.main1 },
    htmlH4                               = { fg = color.main1 },
    htmlH5                               = { fg = color.main1 },
    -- Markdown
    markdownH1                           = { fg = color.bright_white },
    markdownH2                           = { fg = color.bright_white },
    markdownH3                           = { fg = color.bright_white },
    markdownH4                           = { fg = color.bright_white },
    markdownH5                           = { fg = color.bright_white },
    markdownH6                           = { fg = color.bright_white },
    markdownHeadingDelimiter             = { fg = color.gray06 },
    markdownHeadingRule                  = { fg = color.gray06 },
    markdownId                           = { fg = color.main4 },
    markdownIdDeclaration                = { fg = color.main1 },
    markdownIdDelimiter                  = { fg = color.main4 },
    markdownLinkDelimiter                = { fg = color.gray06 },
    markdownLinkText                     = { fg = color.bright_white },
    markdownListMarker                   = { fg = color.yellow },
    markdownOrderedListMarker            = { fg = color.yellow },
    markdownRule                         = { fg = color.gray06 },
    markdownUrl                          = { fg = color.gray06, bg = color.none },
    markdownBlockquote                   = { fg = color.gray07 },
    markdownBold                         = { fg = color.fg, bg = color.none, bold = true },
    markdownItalic                       = { fg = color.fg, bg = color.none, italic = true },
    markdownCode                         = { fg = color.fg, bg = color.gray03 },
    markdownCodeBlock                    = { fg = color.fg, bg = color.gray03 },
    markdownCodeDelimiter                = { fg = color.fg, bg = color.gray03 },
    -- Dashboard
    DashboardShortCut                    = { fg = color.main4 },
    DashboardHeader                      = { fg = color.main4 },
    DashboardCenter                      = { fg = color.main1 },
    DashboardFooter                      = { fg = color.main2, italic = true },
    -- TreeSitter highlight groups
    TSAnnotation                         = { fg = color.main2 }, -- For C++/Dart attributes, annotations that can be attached to the code to denote some kind of meta information.
    TSAttribute                          = { fg = color.fg },    -- (unstable) TODO: docs
    TSBoolean                            = {
      fg = color.main4,
      bg = color.none,
      bold = cfg.boolean_style.bold,
      italic = cfg.boolean_style.italic,
    },                                                           -- true or false
    TSCharacter                          = { fg = color.main4 }, -- For characters.
    TSComment                            = {
      fg = color.gray05,
      bg = color.none,
      bold = cfg.comment_style.bold,
      italic = cfg.comment_style.italic,
    },                                                                                                                                     -- For comment blocks.
    TSConditional                        = { fg = color.main1, bold = cfg.keyword_style.bold, italic = cfg.keyword_style.italic },         -- For keywords related to conditionnals.
    TSConstant                           = { fg = color.fg },                                                                              -- For constants
    TSConstBuiltin                       = { fg = color.main4, italic = true },                                                            -- For constants that are built in the language: `nil` in Lua.
    TSConstMacro                         = { fg = color.main4 },                                                                           -- For constants that are defined by macros: `NULL` in C.
    TSConstructor                        = { fg = color.gray07 },                                                                          -- For constructor calls and definitions: `= { }` in Lua, and Java constructors.
    TSError                              = { fg = color.red },                                                                             -- For syntax/parser errors.
    TSException                          = { fg = color.yellow },                                                                          -- For exception related keywords.
    TSField                              = { fg = color.main4 },                                                                           -- For fields.
    TSFloat                              = { fg = color.main4 },                                                                           -- For floats.
    TSFunction                           = { fg = color.fg, bold = cfg.function_style.bold, italic = cfg.function_style.italic },          -- For fuction (calls and definitions).
    TSFuncBuiltin                        = { fg = color.fg, bold = cfg.function_style.bold, italic = cfg.function_style.italic },          -- For builtin functions: `table.insert` in Lua.
    TSFuncMacro                          = { fg = color.main1 },                                                                           -- For macro defined fuctions (calls and definitions): each `macro_rules` in Rust.
    TSInclude                            = { fg = color.main1, italic = true },                                                            -- For includes: `#include` in C, `use` or `extern crate` in Rust, or `require` in Lua.
    TSKeyword                            = { fg = color.main1, bold = cfg.keyword_style.bold, italic = cfg.keyword_style.italic },         -- For keywords that don't fall in previous categories.
    TSKeywordFunction                    = { fg = color.main1, bold = cfg.function_style.bold, italic = cfg.function_style.italic },       -- For keywords used to define a fuction.
    TSKeywordOperator                    = { fg = color.yellow },                                                                          -- For operators that are English words, e.g. `and`, `as`, `or`.
    TSKeywordReturn                      = { fg = color.main1, bold = cfg.keyword_style.bold, italic = cfg.keyword_style.italic },         -- For the `return` and `yield` keywords.
    TSLabel                              = { fg = color.main4 },                                                                           -- For labels: `label:` in C and `:label:` in Lua.
    TSMethod                             = { fg = color.bright_blue, bold = cfg.function_style.bold, italic = cfg.function_style.italic }, -- For method calls and definitions.
    TSNamespace                          = { fg = color.main1 },                                                                           -- For identifiers referring to modules and namespaces.
    -- TSNone = {}, -- No highlighting. Don't change the values of this highlight group.
    TSNumber                             = { fg = color.main4 },                                                                           -- For all numbers
    TSOperator                           = { fg = color.yellow },                                                                          -- For any operator: `+`, but also `->` and `*` in C.
    TSParameter                          = { fg = color.fg },                                                                              -- For parameters of a function.
    TSParameterReference                 = { fg = color.fg },                                                                              -- For references to parameters of a function.
    TSProperty                           = { fg = color.main1 },                                                                           -- Same as `TSField`.
    TSPunctDelimiter                     = { fg = color.gray05 },                                                                          -- For delimiters ie: `.`
    TSPunctBracket                       = { fg = color.gray05 },                                                                          -- For brackets and parens.
    TSPunctSpecial                       = { fg = color.main2 },                                                                           -- For special punctutation that does not fall in the catagories before.
    TSRepeat                             = { fg = color.main1, bold = cfg.keyword_style.bold, italic = cfg.keyword_style.italic },         -- For keywords related to loops.
    TSString                             = { fg = color.main4 },                                                                           -- For strings.
    TSStringRegex                        = { fg = color.main2 },                                                                           -- For regexes.
    TSStringEscape                       = { fg = color.main4 },                                                                           -- For escape characters within a string.
    TSStringSpecial                      = { fg = color.main2 },                                                                           -- For strings with special meaning that don't fit into the above categories.
    TSSymbol                             = { fg = color.main2 },                                                                           -- For identifiers referring to symbols or atoms.
    TSTag                                = { fg = color.main2 },                                                                           -- Tags like html tag names.
    TSTagAttribute                       = { fg = color.fg },                                                                              -- For html tag attributes.
    TSTagDelimiter                       = { fg = color.gray05 },                                                                          -- Tag delimiter like `<` `>` `/`
    TSText                               = { fg = color.fg },                                                                              -- For strings considered text in a markup language.
    TSStrong                             = { fg = color.bright_white, bold = true },                                                       -- For text to be represented in bold.
    TSEmphasis                           = { fg = color.bright_white, bold = true },                                                       -- For text to be represented with emphasis.
    TSUnderline                          = { fg = color.bright_white, bg = color.none, underline = true },                                 -- For text to be represented with an underline.
    TSStrike                             = {},                                                                                             -- For strikethrough text.
    TSTitle                              = { fg = color.fg, bg = color.none },                                                             -- Text that is part of a title.
    TSLiteral                            = { fg = color.fg },                                                                              -- Literal text.
    TSURI                                = { fg = color.main4 },                                                                           -- Any URL like a link or email.
    TSMath                               = { fg = color.main1 },                                                                           -- For LaTeX-like math environments.
    TSTextReference                      = { fg = color.yellow },                                                                          -- For footnotes, text references, citations.
    TSEnvironment                        = { fg = color.main1 },                                                                           -- For text environments of markup languages.
    TSEnvironmentName                    = { fg = color.bright_blue },                                                                     -- For the name/the string indicating the type of text environment.
    TSNote                               = { fg = color.main1 },                                                                           -- Text representation of an informational note.
    TSWarning                            = { fg = color.yellow },                                                                          -- Text representation of a warning note.
    TSDanger                             = { fg = color.red },                                                                             -- Text representation of a danger note.
    TSType                               = { fg = color.fg },                                                                              -- For types.
    TSTypeBuiltin                        = { fg = color.main1 },                                                                           -- For builtin types.
    TSVariable                           = { fg = color.fg, bold = cfg.variable_style.bold, italic = cfg.variable_style.italic },          -- Any variable name that does not have another highlight.
    TSVariableBuiltin                    = { fg = color.yellow, bold = cfg.variable_style.bold, italic = cfg.variable_style.italic },      -- Variable names that are defined by the languages, like `this` or `self`.
    -- highlight groups for the native LSP client
    LspReferenceText                     = { fg = color.bright_white, bg = color.dark_pink },                                              -- used for highlighting "text" references
    LspReferenceRead                     = { fg = color.bright_white, bg = color.dark_pink },                                              -- used for highlighting "read" references
    LspReferenceWrite                    = { fg = color.bright_white, bg = color.dark_pink },                                              -- used for highlighting "write" references
    -- Diagnostics
    DiagnosticError                      = { bg = color.none, fg = color.red01 },                                                          -- base highlight group for "Error"
    DiagnosticWarn                       = { bg = color.none, fg = color.yellow01 },                                                       -- base highlight group for "Warning"
    DiagnosticInfo                       = { bg = color.none, fg = color.gray06 },                                                         -- base highlight group from "Information"
    DiagnosticHint                       = { bg = color.none, fg = color.gray06 },                                                         -- base highlight group for "Hint"
    DiagnosticVirtualTextError           = {
      bg = color.none,
      fg = color.diagnostic_virtual_text_error,
      bold = true,
      underline = false,
    },
    DiagnosticVirtualTextWarn            = {
      bg = color.none,
      fg = color.diagnostic_virtual_text_warn,
      bold = true,
      underline = false,
    },
    DiagnosticVirtualTextInfo            = {
      bg = color.none,
      fg = color.diagnostic_virtual_text_info,
      bold = true,
      underline = false,
    },
    DiagnosticVirtualTextHint            = {
      bg = color.none,
      fg = color.diagnostic_virtual_text_hint,
      bold = true,
      underline = false,
    },
    DiagnosticUnderlineError             = { bg = color.none, fg = color.red01, undercurl = true, sp = color.red01 },       -- used to underline "Error" diagnostics.
    DiagnosticUnderlineWarn              = { bg = color.none, fg = color.yellow01, undercurl = true, sp = color.yellow01 }, -- used to underline "Warning" diagnostics.
    DiagnosticUnderlineInfo              = { bg = color.none, fg = color.gray06, undercurl = true, sp = color.gray06 },     -- used to underline "Information" diagnostics.
    DiagnosticUnderlineHint              = { bg = color.none, fg = color.gray06, undercurl = true, sp = color.gray06 },     -- used to underline "Hint" diagnostics.
    -- Diagnostics (old)
    LspDiagnosticsDefaultError           = { fg = color.red },                                                              -- used for "Error" diagnostic virtual text
    LspDiagnosticsSignError              = { bg = color.dark_blue, fg = color.red, bold = true },                           -- used for "Error" diagnostic signs in sign column
    LspDiagnosticsFloatingError          = { fg = color.red, bold = true },                                                 -- used for "Error" diagnostic messages in the diagnostics float
    LspDiagnosticsVirtualTextError       = { fg = color.red, bold = true },                                                 -- Virtual text "Error"
    LspDiagnosticsUnderlineError         = { fg = color.red, undercurl = true, sp = color.red },                            -- used to underline "Error" diagnostics.
    LspDiagnosticsDefaultWarning         = { fg = color.yellow },                                                           -- used for "Warning" diagnostic signs in sign column
    LspDiagnosticsSignWarning            = { bg = color.dark_blue, fg = color.yellow, bold = true },                        -- used for "Warning" diagnostic signs in sign column
    LspDiagnosticsFloatingWarning        = { fg = color.yellow, bold = true },                                              -- used for "Warning" diagnostic messages in the diagnostics float
    LspDiagnosticsVirtualTextWarning     = { fg = color.yellow, bold = true },                                              -- Virtual text "Warning"
    LspDiagnosticsUnderlineWarning       = { fg = color.yellow, undercurl = true, sp = color.yellow },                      -- used to underline "Warning" diagnostics.
    LspDiagnosticsDefaultInformation     = { fg = color.main1 },                                                            -- used for "Information" diagnostic virtual text
    LspDiagnosticsSignInformation        = { bg = color.dark_blue, fg = color.main1, bold = true },                         -- used for "Information" diagnostic signs in sign column
    LspDiagnosticsFloatingInformation    = { fg = color.main1, bold = true },                                               -- used for "Information" diagnostic messages in the diagnostics float
    LspDiagnosticsVirtualTextInformation = { fg = color.main1, bold = true },                                               -- Virtual text "Information"
    LspDiagnosticsUnderlineInformation   = { fg = color.main1, undercurl = true, sp = color.main1 },                        -- used to underline "Information" diagnostics.
    LspDiagnosticsDefaultHint            = { fg = color.gray05 },                                                           -- used for "Hint" diagnostic virtual text
    LspDiagnosticsSignHint               = { bg = color.dark_blue, fg = color.gray05, bold = true },                        -- used for "Hint" diagnostic signs in sign column
    LspDiagnosticsFloatingHint           = { fg = color.gray05, bold = true },                                              -- used for "Hint" diagnostic messages in the diagnostics float
    LspDiagnosticsVirtualTextHint        = { fg = color.gray05, bold = true },                                              -- Virtual text "Hint"
    LspDiagnosticsUnderlineHint          = { fg = color.gray05, undercurl = true, sp = color.main4 },                       -- used to underline "Hint" diagnostics.
    -- Plugins highlight groups
    -- LspTrouble
    LspTroubleText                       = { fg = color.gray04 },
    LspTroubleCount                      = { fg = color.magenta, bg = color.gray03 },
    LspTroubleNormal                     = { fg = color.fg, bg = color.bg },
    -- Telescope
    TelescopeSelectionCaret              = { fg = color.main1, bg = color.gray01 },
    TelescopeBorder                      = { link = "FloatBorder" },
    TelescopePromptBorder                = { link = "FloatBorder" },
    TelescopeResultsBorder               = { link = "FloatBorder" },
    TelescopePreviewBorder               = { link = "FloatBorder" },
    TelescopePromptPrefix                = { fg = color.main1 },
    TelescopeMatching                    = { fg = color.yellow },
    -- NvimTree
    NvimTreeRootFolder                   = { fg = color.main4 },
    NvimTreeNormal                       = { fg = color.fg, bg = cfg.transparent and color.none or color.bg },
    NvimTreeNormalNC                     = { fg = color.fg, bg = cfg.transparent and color.none or color.bg_nc },
    NvimTreeLineNr                       = { fg = color.fg, bg = color.none },
    NvimTreeSignColumn                   = { fg = color.fg, bg = color.none },
    NvimTreeImageFile                    = { fg = color.magenta },
    NvimTreeExecFile                     = { fg = color.main2 },
    NvimTreeSpecialFile                  = {},
    NvimTreeFolderName                   = { fg = color.main1 },
    NvimTreeOpenedFolderName             = { fg = color.bright_blue },
    NvimTreeOpenedFile                   = { fg = color.bright_blue },
    NvimTreeEmptyFolderName              = { fg = color.gray05 },
    NvimTreeFolderIcon                   = { fg = color.gray07 },
    NvimTreeIndentMarker                 = { fg = color.gray03 },
    NvimTreeGitDirty                     = { fg = color.gray07 },
    NvimTreeGitStaged                    = { fg = color.main4 },
    NvimTreeGitRenamed                   = { fg = color.yellow },
    NvimTreeGitNew                       = { fg = color.main2 },
    NvimTreeGitDeleted                   = { fg = color.red },
    -- WhichKey
    WhichKey                             = { fg = color.bright_cyan },
    WhichKeyGroup                        = { fg = color.yellow },
    WhichKeyDesc                         = { fg = color.main1 },
    WhichKeySeperator                    = { fg = color.gray05 },
    WhichKeyFloating                     = { bg = color.gray01 },
    WhichKeyFloat                        = { link = "FloatBorder" },
    WhichKeyBorder                       = { link = "FloatBorder" },
    WhichKeyNormal                       = { link = "Normal" },
    -- Indent Blankline
    -- IndentBlanklineChar = { fg = c.bg_nc },
    IndentBlanklineContextChar           = { fg = color.dark_yellow },
    -- IndentBlanklineContextSpaceChar = { fg = c.main2 },
    -- IndentBlanklineSpaceChar = { link = "IndentBlanklineChar" },
    -- IndentBlanklineSpaceCharBlankline = { link = "IndentBlanklineChar" },
    -- nvim-cmp
    CmpItemAbbr                          = { fg = color.fg, bg = color.none },
    CmpItemAbbrDeprecated                = { fg = color.fg, strikethrough = true },
    CmpItemAbbrMatch                     = { fg = color.yellow, bg = color.none },
    CmpItemAbbrMatchFuzzy                = { fg = color.yellow, bg = color.none },
    CmpItemKindVariable                  = { fg = color.main1, bg = color.none },
    CmpItemKindInterface                 = { fg = color.main1, bg = color.none },
    CmpItemKindText                      = { fg = color.main1, bg = color.none },
    CmpItemKindFunction                  = { fg = color.magenta, bg = color.none },
    CmpItemKindMethod                    = { fg = color.magenta, bg = color.none },
    CmpItemKindKeyword                   = { fg = color.fg, bg = color.none },
    CmpItemKindProperty                  = { fg = color.fg, bg = color.none },
    CmpItemMenu                          = { fg = color.fg, bg = color.none },
    CmpGhostText                         = { fg = color.gray01, italic = false },

    -- Custom highlight groups for use in statusline plugins
    StatusLineNormalMode                 = { fg = color.black, bg = color.gray02 },
    StatusLineInsertMode                 = { fg = color.black, bg = color.gray03 },
    StatusLineVisualMode                 = { fg = color.black, bg = color.gray04 },
    StatusLineReplaceMode                = { fg = color.black, bg = color.gray05 },
    StatusLineTerminalMode               = { fg = color.black, bg = color.gray05 },
    StatusLineHint                       = { fg = color.main4, bg = color.none },
    StatusLineInfo                       = { fg = color.main1, bg = color.none },
    StatusLineWarn                       = { fg = color.yellow, bg = color.none },
    StatusLineError                      = { fg = color.red, bg = color.none },
    StatusLineText                       = { fg = get_highlight("Normal", "fg"), bg = color.none },
    -- JSON
    jsonNumber                           = { fg = color.yellow },
    jsonNull                             = { fg = color.bright_black },
    jsonString                           = { fg = color.main2 },
    jsonKeyword                          = { fg = color.main1 },
    -- Treesitter context
    TreesitterContextSeparator           = { fg = color.gray03 },
    TreesitterContext                    = { fg = color.fg, bg = color.blue02 },
    TreesitterContextLineNumber          = { fg = color.fg, bg = color.blue02 },
    -- Indent blankline
    IndentBlanklineScope                 = { fg = color.dark_yellow, bg = color.none },
    -- visual-multi
    VisualMultiHighlightMatches          = { fg = color.red, underline = true, bold = true },
    -- Trouble.nvim
    TroubleNormal                        = { fg = color.fg, bg = color.blue02 },
    TroubleNormalNC                      = { fg = color.fg, bg = color.blue02 },
    -- Codeium
    CodeiumSuggestion                    = { fg = color.gray07, bg = color.dark_brown, italic = false },
    -- toml
    tomlDotInKey                         = { fg = color.fg, bg = color.none },
    -- render-markdown.nvim
    RenderMarkdownCode                   = { bg = color.blue00 },
    RenderMarkdownCodeInline             = { bg = color.blue00 },
    RenderMarkdownH1Bg                   = { bg = color.red02 },
    RenderMarkdownH2Bg                   = { bg = color.red03 },
    RenderMarkdownH3Bg                   = { bg = color.red04 },
    RenderMarkdownH4Bg                   = { bg = color.red04 },
    RenderMarkdownH5Bg                   = { bg = color.red04 },
    RenderMarkdownH6Bg                   = { bg = color.red04 },
    -- Copilot
    CopilotSuggestion                    = { fg = color.dark_brown },
    -- Deadcolumn
    WarningColorColumn                   = { bg = color.red },
    -- Tabline
    TabLineGit                           = { fg = color.gray06, bg = color.blue },
    TabLine0                             = { fg = color.gray06, bg = color.blue },
    TabLine1                             = { fg = color.gray06, bg = color.dark_blue },
    TabLine2                             = { fg = color.gray06, bg = color.dark_green02 },
    -- BufferLine
    BufferLine0                          = { fg = color.gray06, bg = color.dark_green02 },
    BufferLine1                          = { fg = color.gray06, bg = color.dark_blue },
    BufferLine2                          = { fg = color.gray06, bg = color.none },
    -- Avante
    AvanteButtonPrimary                  = { fg = "#1e222a", bg = "#abb2bf" },
    AvanteToBeDeletedWOStrikethrough     = { bg = "#562c30", },
    AvanteButtonDefaultHover             = { fg = "#1e222a", bg = "#e06c75" },
    AvanteSidebarWinSeparator            = { fg = color.blue02, bg = color.blue02 },
    AvanteSidebarWinHorizontalSeparator  = { fg = color.bg, bg = "#030a0e" },
    AvanteReversedTitle                  = { fg = "#98c379", },
    AvanteTitle                          = { fg = "#1e222a", bg = "#e06c75" },
    AvanteConfirmTitle                   = { fg = "#1e222a", bg = "#e06c75" },
    AvanteReversedThirdTitle             = { fg = "#353b45", },
    AvanteToBeDeleted                    = { bg = "#ffcccc", strikethrough = true },
    AvanteReversedNormal                 = { fg = "#030a0e", bg = "#a9a9a9" },
    AvanteCommentFg                      = { fg = "#6a6a69" },
    AvanteReversedSubtitle               = { fg = "#56b6c2" },
    AvanteSubtitle                       = { fg = "#1e222a", bg = "#56b6c2" },
    AvanteButtonDangerHover              = { fg = "#1e222a", bg = "#e06c75" },
    AvanteThirdTitle                     = { fg = "#abb2bf", bg = "#353b45" },
    AvanteButtonDefault                  = { fg = "#1e222a", bg = "#abb2bf" },
    AvanteButtonDanger                   = { fg = "#1e222a", bg = "#abb2bf" },
    AvanteButtonPrimaryHover             = { fg = "#1e222a", bg = "#56b6c2" },
    AvanteConflictCurrent                = { bg = "#562c30", bold = true },
    AvanteConflictIncoming               = { bg = "#314753", bold = true },
    AvanteConflictIncomingLabel          = { bg = "#3f5c6b" },
    AvanteConflictCurrentLabel           = { bg = "#6f393e" },
    AvantePromptInputBorder              = { fg = color.blue02, bg = color.blue02 },
    AvantePopupHint                      = { fg = color.blue02, bg = color.blue02 },
    AvanteAnnotation                     = { link = "Comment" },
    AvanteSidebarNormal                  = { bg = color.none },
    AvanteSuggestion                     = { link = "Comment" },
    AvanteInlineHint                     = { link = "Keyword" },
    AvantePromptInput                    = { bg = color.blue02 },
  }
end

M.msg_area_colors = {
  insert_mode_msg_area = "#3f0f13",
  modified_msg_area = "#462b24",
  cmdline_msg_area = "#081923",
  term_msg_area = "#263730",
}

M.setup = function(colors)
  local groups = get_groups(colors)
  for group, parameters in pairs(groups) do
    highlight(group, parameters)
  end
end

return M
