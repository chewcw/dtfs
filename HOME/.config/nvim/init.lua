require("core")

require("core.utils").load_mappings()

vim.api.nvim_create_user_command("LazyStart", function()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

  -- bootstrap lazy.nvim on demand
  if not vim.loop.fs_stat(lazypath) then
    require("core.bootstrap").lazy(lazypath)
  end

  vim.opt.rtp:prepend(lazypath)
end, {})

require("core.colorscheme").setup()
