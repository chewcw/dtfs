local opt = vim.opt
local g = vim.g
local config = require("core.utils").load_config()

-------------------------------------- options ------------------------------------------
opt.laststatus = 2 -- global statusline
opt.showmode = true

opt.clipboard = "unnamedplus"
opt.cursorline = true
opt.cursorlineopt = "number"

-- Indenting
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true

opt.fillchars = {
  eob = "~",
  -- vert = "│",
  -- horiz = "―",
  -- vertright = " ",
  -- vertleft = "
  -- horizup = " ",
  -- horizdown = " ",
  -- verthoriz = " ",
  stl = " ",
  fold = " ",
  -- foldopen = "🢒",
  -- foldsep = " ",
  -- foldclose = " ",
}
opt.ignorecase = true
opt.smartcase = true
opt.mouse = "a"

-- Numbers
opt.number = true
opt.relativenumber = true
opt.numberwidth = 1
opt.ruler = false

-- disable nvim intro
opt.shortmess:append("sI")

opt.signcolumn = "yes"
opt.splitbelow = true
opt.splitright = true
opt.termguicolors = true
opt.timeoutlen = 400
opt.undofile = true

-- interval for writing swap file to disk, also used by gitsigns
opt.updatetime = 250

-- go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
-- opt.whichwrap:append("<>[]hl")

-- https://stackoverflow.com/questions/2288756/how-to-set-working-current-directory-in-vim
opt.autochdir = false

-- misc
opt.scrolloff = 5
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
opt.foldcolumn = "0"
opt.wildignorecase = true
-- this is the annoying opening parenthesis highlighting when typing closing parenthesis
-- https://stackoverflow.com/a/34716232
opt.showmatch = false
-- this has no effect if the showmatch is disabled
opt.matchtime = 1
opt.breakindent = true
opt.completeopt = "menuone,noselect"

-- vertical line
opt.colorcolumn = "85"

-- wrap
vim.wo.wrap = false
opt.linebreak = true
opt.textwidth = 85

-- fold method
opt.foldmethod = "indent"

-- leader
g.mapleader = " "

-- cursor
opt.guicursor = "n-v-sm:block,i-c-ci-ve:block-blinkwait0-blinkoff400-blinkon250-Cursor/lCursor,r-cr-o:hor30"

-- list mode (show return and space)
-- take note on the function toggle_newline_symbol in plugins.configs.buffer_utils.lua
opt.list = true
opt.listchars:append("lead:·,multispace:·,trail:·,tab:⟩-")

-- tabline
opt.showtabline = 2

-- virtualedit
opt.virtualedit = "insert"

-- disable some default providers
for _, provider in ipairs({ "node", "perl", "python3", "ruby" }) do
  vim.g["loaded_" .. provider .. "_provider"] = 0
end

-- add binaries installed by mason.nvim to path
local is_windows = vim.loop.os_uname().sysname == "Windows_NT"
vim.env.PATH = vim.env.PATH .. (is_windows and ";" or ":") .. vim.fn.stdpath("data") .. "/mason/bin"

-- abbrevation
require("core.abbrev")

-- statusline
require("core.statusline")

-- tabline
require("core.tabline")

-- ----------------------------------------------------------------------------
-- autocmds
-- ----------------------------------------------------------------------------
local autocmd = vim.api.nvim_create_autocmd

-- dont list quickfix buffers
autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.opt_local.buflisted = false
  end,
})

-- save fold on save and laod fold on open
-- https://stackoverflow.com/a/77180744
vim.api.nvim_create_autocmd({ "BufWinLeave" }, {
  pattern = { "*.*" },
  desc = "save view (folds), when closing file",
  command = "mkview",
})
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  pattern = { "*.*" },
  desc = "load view (folds), when opening file",
  command = "silent! loadview",
})

-- update command line color in insert mode
vim.api.nvim_create_autocmd({ "InsertEnter" }, {
  callback = function()
    vim.api.nvim_set_hl(0, "MsgArea", {
      bg = require("core.colorscheme").colors().dark_yellow02,
    })
  end,
})
vim.api.nvim_create_autocmd({ "InsertLeave" }, {
  callback = function()
    vim.api.nvim_set_hl(0, "MsgArea", { bg = "None" })
  end,
})

-- update command line color in command mode
vim.api.nvim_create_autocmd({ "CmdLineEnter" }, {
  callback = function()
    vim.api.nvim_set_hl(0, "MsgArea", {
      bg = require("core.colorscheme").colors().dark_blue,
    })
    -- so that when I press ctrl+f in the command line it wouldn't have error
    pcall(function()
      vim.cmd(":TSContextDisable")
    end)
  end,
})
vim.api.nvim_create_autocmd({ "CmdLineLeave" }, {
  callback = function()
    vim.api.nvim_set_hl(0, "MsgArea", { bg = "None" })
    pcall(function()
      vim.cmd(":TSContextEnable")
    end)
  end,
})

-- search for any unsaved buffer and show it on the MsgArea
function Search_modified_unsaved_buffers()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_option(buf, "modified") then
      vim.api.nvim_set_hl(0, "MsgArea", {
        bg = require("core.colorscheme").colors().dark_main4,
      })
      return
    end
    vim.api.nvim_set_hl(0, "MsgArea", { bg = "None" })
  end
end

vim.api.nvim_create_autocmd({ "BufModifiedSet" }, {
  callback = Search_modified_unsaved_buffers,
})
vim.api.nvim_create_autocmd({ "InsertLeave" }, {
  callback = Search_modified_unsaved_buffers,
})
-- opening and closing telescope picker will also be triggered
-- so this event is to run the function after the telescope picker is closed
vim.api.nvim_create_autocmd({ "WinEnter" }, {
  callback = Search_modified_unsaved_buffers,
})

-- for trouble.nvim plugin there is no NormalNC highlight group
-- this is a hack
-- vim.api.nvim_create_autocmd({ "BufWinLeave" }, {
--   callback = function()
--     local buf_name = vim.api.nvim_buf_get_name(0)
--     local colors = require("core.colorscheme")
--     if string.find(buf_name, "/Trouble") then
--       vim.api.nvim_set_hl(0, "TroubleNormal", { bg = colors.bg_nc })
--     else
--       vim.api.nvim_set_hl(0, "TroubleNormal", { bg = colors.bg })
--     end
--   end,
-- })

-- update command line color in terminal mode
vim.api.nvim_create_autocmd({ "TermEnter" }, {
  callback = function()
    vim.api.nvim_set_hl(0, "MsgArea", {
      bg = require("core.colorscheme").colors().dark_green,
    })
  end,
})
vim.api.nvim_create_autocmd({ "TermLeave" }, {
  callback = function()
    vim.api.nvim_set_hl(0, "MsgArea", { bg = "None" })
  end,
})

-- Stop lsp, detach gitsigns, and disable treesitter_context in diff mode
function DoSomethingInDiffMode()
  if vim.api.nvim_win_get_option(0, "diff") then
    vim.lsp.stop_client(vim.lsp.get_active_clients())
    pcall(function()
      vim.cmd(":Gitsigns detach_all")
    end)
    pcall(function()
      vim.cmd(":TSContextDisable")
    end)
  end
end

vim.api.nvim_create_autocmd({ "OptionSet" }, {
  callback = DoSomethingInDiffMode,
})

-- Highlight all same words in the buffer under cursor
vim.api.nvim_create_augroup("CursorMovedHighlight", { clear = true })
vim.api.nvim_create_autocmd({ "CursorMoved" }, {
  group = "CursorMovedHighlight",
  callback = function()
    pcall(function()
      -- ignore this if no lsp_server found
      local buf_clients = vim.lsp.get_active_clients({ bufnr = vim.api.nvim_get_current_buf() })
      if #buf_clients == 0 then
        return
      end

      -- Clear existing highlights in the group
      vim.cmd("silent! syntax clear UnderlinedHighlight")

      -- Get the word under the cursor
      local word = vim.fn.expand("<cword>")
      if word == "" then
        return
      end

      -- Escape the word for use in a Vim pattern
      local escaped_word = vim.fn.escape(word, "\\/.*$^~[]")

      -- Highlight all instances of the word in the current buffer
      vim.cmd(string.format("syntax match UnderlinedHighlight /\\V\\<%s\\>/", escaped_word))
      vim.cmd("highlight link UnderlinedHighlight Highlight")
    end)
  end,
})

-- because of core.utils.toggle_search_highlight function, normal search using following
-- mappings may not have highlights shown, because it has been toggled off, so
-- these mappings made sure hlsearch will always be on.
vim.api.nvim_create_augroup("EnableHlsearch", { clear = true })
vim.api.nvim_create_autocmd("CmdlineLeave", {
  group = "EnableHlsearch",
  callback = function()
    -- Get the content of the command line
    local cmd_line_type = vim.fn.getcmdtype()
    local cmd_line = vim.fn.getcmdline()

    -- Check if the command starts with '/' or '?' and is followed by some characters
    if cmd_line_type == "/" or cmd_line_type == "?" then
      if string.find(cmd_line, "^.+") then
        vim.o.hlsearch = true
      end
    end
  end,
})

-- ----------------------------------------------------------------------------
-- user commands
-- ----------------------------------------------------------------------------
-- A user command to update quickfix list after cdo / cfdo
-- https://vi.stackexchange.com/a/13663https://vi.stackexchange.com/a/13663
vim.api.nvim_create_user_command("UpdateQF", function()
  vim.cmd(
    [[ call setqflist(map(getqflist(), 'extend(v:val, {"text":get(getbufline(v:val.bufnr, v:val.lnum),0)})')) ]]
  )
end, {})

-- Redirect the output of a Vim or external command into a scratch buffer
-- reference: https://github.com/sbulav/nredir.nvim
vim.api.nvim_create_user_command('Redir', function(opts)
  require('core.utils_redir').nredir(opts.args, "replace")
end, { nargs = 1, complete = 'command' })

vim.api.nvim_create_user_command('Redirt', function(opts)
  require('core.utils_redir').nredir(opts.args, "tab")
end, { nargs = 1, complete = 'command' })

vim.api.nvim_create_user_command('Redirv', function(opts)
  require('core.utils_redir').nredir(opts.args, "vertical")
end, { nargs = 1, complete = 'command' })

-- ----------------------------------------------------------------------------
-- set tab size for certain file type
-- ----------------------------------------------------------------------------
-- csharp
local filetype_cs_group = vim.api.nvim_create_augroup("FileTypeCS", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = filetype_cs_group,
  pattern = "cs",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
  end,
})

-- ----------------------------------------------------------------------------
-- Focus left tab when tab closed
-- ----------------------------------------------------------------------------
-- https://stackoverflow.com/a/77006146
vim.api.nvim_create_augroup("TabClosed", { clear = true })
vim.api.nvim_create_autocmd("TabClosed", {
  group = "TabClosed",
  callback = function()
    vim.cmd("tabprevious")
  end,
})

-- ----------------------------------------------------------------------------
-- Don't add endofline automatically
-- ----------------------------------------------------------------------------
-- https://stackoverflow.com/a/4152785
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   callback = function()
--     vim.cmd("set binary")
--     vim.cmd("set noeol")
--   end,
-- })
--
-- vim.api.nvim_create_autocmd("BufWritePost", {
--   callback = function()
--     vim.cmd("set nobinary")
--     vim.cmd("set eol")
--   end,
-- })
