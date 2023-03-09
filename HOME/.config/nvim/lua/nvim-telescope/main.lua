local status, telescope = pcall(require, "telescope")
local builtin = require('telescope.builtin')
local fb_actions = require "telescope".extensions.file_browser.actions

telescope.setup {
  extensions = {
    file_browser = {
      theme = "dropdown",
      -- disables netrw and use telescope-file-browser in its place
      hijack_netrw = true,
      hidden = true,
      initial_mode = "normal",
      preview = true,
      mappings = {
        -- your custom insert mode mappings
        ["i"] = {
          ["<C-w>"] = function() vim.cmd('normal vbd') end,
        },
        ["n"] = {
          -- your custom normal mode mappings
          ["N"] = fb_actions.create,
          ["h"] = fb_actions.goto_parent_dir,
          ["/"] = function()
            vim.cmd('startinsert')
          end
        },
      },
    },
  },
  pickers = {
    colorscheme = {
      enable_preview = true,
    },
    find_files = {
      hidden = true,
    },
  },
}

telescope.load_extension("file_browser")
telescope.load_extension("live_grep_args")

vim.keymap.set('n', '<leader>ff', function()
  local opts = opts or {}
  opts.cwd = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    opts.cwd = vim.fn.expand('%:p:h')
  end
  builtin.find_files(opts)
end)
vim.keymap.set('n', '<leader>fg', telescope.extensions.live_grep_args.live_grep_args)
vim.keymap.set('n', '<leader>fb', function()
  builtin.buffers({
    initial_mode = 'normal',
  })
end)
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>fs', function()
  telescope.extensions.file_browser.file_browser({
    path = '%:p:h',
    cwd = vim.fn.expand('%:p:h'),
    respect_gitignore = false,
    hidden = true,
    grouped = true,
    initial_mode = 'normal',
    layout_config = { height = 40 }
  })
end)

