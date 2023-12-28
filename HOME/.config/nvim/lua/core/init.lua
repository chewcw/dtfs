local opt = vim.opt
local g = vim.g
local config = require("core.utils").load_config()

-------------------------------------- options ------------------------------------------
opt.laststatus = 3 -- global statusline
opt.showmode = true

opt.clipboard = "unnamedplus"
opt.cursorline = true

-- Indenting
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true

opt.fillchars = {
  eob = "~",
  vert = " ",
  horiz = " ",
  vertright = " ",
  vertleft = " ",
  horizup = " ",
  horizdown = " ",
  verthoriz = " ",
}
opt.ignorecase = false
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
opt.splitbelow = false
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
opt.wildignorecase = true
opt.showmatch = true
opt.breakindent = true
opt.completeopt = "menuone,noselect"
opt.showtabline = 0

-- vertical line
opt.colorcolumn = "80"

-- wrap
vim.wo.wrap = false
opt.linebreak = true
opt.textwidth = 85

-- leader
g.mapleader = " "

-- cursor
opt.guicursor = "n-v-sm:block,i-c-ci-ve:block-blinkwait0-blinkoff400-blinkon250-Cursor/lCursor,r-cr-o:hor30"

-- list mode (show return and space)
opt.list = true
opt.listchars:append("lead:·,multispace:·,trail:·")

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

-------------------------------------- autocmds ------------------------------------------
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
vim.api.nvim_create_autocmd({"BufWinLeave"}, {
  pattern = {"*.*"},
  desc = "save view (folds), when closing file",
  command = "mkview",
})
vim.api.nvim_create_autocmd({"BufWinEnter"}, {
  pattern = {"*.*"},
  desc = "load view (folds), when opening file",
  command = "silent! loadview"
})
