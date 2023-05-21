-- All plugins have lazy=true by default,to load a plugin on startup just lazy=false
-- List of all default plugins & their definitions
local default_plugins = {

  "nvim-lua/plenary.nvim",

  -- nvchad plugins
  {
    "NvChad/extensions",
    branch = "v2.0",
  },

  {
    "NvChad/base46",
    branch = "v2.0",
    build = function()
      require("base46").load_all_highlights()
    end,
  },

  {
    "NvChad/ui",
    branch = "v2.0",
    lazy = false,
    config = function()
      require("nvchad_ui")
    end,
  },

  -- {
  -- 	"NvChad/nvim-colorizer.lua",
  -- 	init = function()
  -- 		require("core.utils").lazy_load("nvim-colorizer.lua")
  -- 	end,
  -- 	config = function(_, opts)
  -- 		require("colorizer").setup(opts)

  -- 		-- execute colorizer as soon as possible
  -- 		vim.defer_fn(function()
  -- 			require("colorizer").attach_to_buffer(0)
  -- 		end, 0)
  -- 	end,
  -- },

  {
    "nvim-tree/nvim-web-devicons",
    opts = function()
      return require("plugins.configs.others").webdevicons
    end,
    config = function(_, opts)
      require("nvim-web-devicons").setup(opts)
    end,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    init = function()
      require("core.utils").lazy_load("indent-blankline.nvim")
    end,
    opts = function()
      return require("plugins.configs.others").blankline
    end,
    config = function(_, opts)
      require("core.utils").load_mappings("blankline")
      dofile(vim.g.base46_cache .. "blankline")
      require("indent_blankline").setup(opts)
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    init = function()
      require("core.utils").lazy_load("nvim-treesitter")
    end,
    cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
    build = ":TSUpdate",
    opts = function()
      return require("plugins.configs.treesitter")
    end,
    config = function(_, opts)
      dofile(vim.g.base46_cache .. "syntax")
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  -- git stuff
  {
    "lewis6991/gitsigns.nvim",
    ft = { "gitcommit", "diff" },
    init = function()
      -- load gitsigns only when a git file is opened
      vim.api.nvim_create_autocmd({ "BufRead" }, {
        group = vim.api.nvim_create_augroup("GitSignsLazyLoad", { clear = true }),
        callback = function()
          vim.fn.system("git -C " .. '"' .. vim.fn.expand("%:p:h") .. '"' .. " rev-parse")
          if vim.v.shell_error == 0 then
            vim.api.nvim_del_augroup_by_name("GitSignsLazyLoad")
            vim.schedule(function()
              require("lazy").load({ plugins = { "gitsigns.nvim" } })
            end)
          end
        end,
      })
    end,
    opts = function()
      return require("plugins.configs.others").gitsigns
    end,
    config = function(_, opts)
      dofile(vim.g.base46_cache .. "git")
      require("gitsigns").setup(opts)
    end,
  },

  -- lsp stuff
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonInstallAll", "MasonUninstall", "MasonUninstallAll", "MasonLog" },
    opts = function()
      return require("plugins.configs.mason")
    end,
    config = function(_, opts)
      dofile(vim.g.base46_cache .. "mason")
      require("mason").setup(opts)

      -- custom nvchad cmd to install all mason binaries listed
      vim.api.nvim_create_user_command("MasonInstallAll", function()
        vim.cmd("MasonInstall " .. table.concat(opts.ensure_installed, " "))
      end, {})

      vim.g.mason_binaries_list = opts.ensure_installed
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      --format and linting
      {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
          require("plugins.configs.null-ls")
        end,
      },
    },
    init = function()
      require("core.utils").lazy_load("nvim-lspconfig")
    end,
    config = function()
      require("plugins.configs.lspconfig")
    end,
  },

  -- load luasnips + cmp related in insert mode only
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      {
        -- snippet plugin
        "L3MON4D3/LuaSnip",
        dependencies = "rafamadriz/friendly-snippets",
        opts = { history = true, updateevents = "TextChanged,TextChangedI" },
        config = function(_, opts)
          require("plugins.configs.others").luasnip(opts)
        end,
      },

      -- cmp sources plugins
      {
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
      },
    },
    opts = function()
      return require("plugins.configs.cmp")
    end,
    config = function(_, opts)
      require("cmp").setup(opts)
    end,
  },

  -- file managing , picker etc
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    init = function()
      require("core.utils").load_mappings("nvimtree")
    end,
    opts = function()
      return require("plugins.configs.nvimtree")
    end,
    config = function(_, opts)
      dofile(vim.g.base46_cache .. "nvimtree")
      require("nvim-tree").setup(opts)
      vim.g.nvimtree_side = opts.view.side
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    cmd = { "Telescope" },
    init = function()
      require("core.utils").load_mappings("telescope")
    end,
    opts = function()
      return require("plugins.configs.telescope")
    end,
    config = function(_, opts)
      dofile(vim.g.base46_cache .. "telescope")
      local telescope = require("telescope")
      telescope.setup(opts)
      -- load extensions
      for _, ext in ipairs(opts.extensions_list) do
        telescope.load_extension(ext)
      end
    end,
  },

  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  },

  {
    "nvim-telescope/telescope-ui-select.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  },

  {
    "tpope/vim-surround",
    keys = { "v" }
  },

  {
    "tomtom/tcomment_vim",
    event = { "BufEnter "},
  },

  {
    "easymotion/vim-easymotion",
    keys = { "<leader>" },
    init = function()
      require("core.utils").load_mappings("easymotion")
    end,
  },

  {
    "gelguy/wilder.nvim",
    event = "BufEnter",
    opts = function()
      return require("plugins.configs.others").wilder
    end,
    init = function()
      local wilder = require("wilder")
      wilder.set_option(
        "renderer",
        wilder.popupmenu_renderer(wilder.popupmenu_border_theme({
          highlights = {
            border = "Normal",
          },
          border = "single",
        }))
      )
    end,
    config = function(_, opts)
      require("wilder").setup(opts)
    end,
  },

  {
    "jeetsukumaran/vim-markology",
    event = "VeryLazy",
    init = function()
      vim.g.markology_include = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    end,
  },

  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm" },
    config = true,
    init = function()
      require("core.utils").load_mappings("toggleterm")
    end,
    opts = function()
      return require("plugins.configs.toggleterm")
    end,
  },

  {
    "Exafunction/codeium.vim",
    cmd = { "CodeiumEnable" },
    init = function()
      require("core.utils").load_mappings("codeium")
    end,
  },

  {
    "natecraddock/workspaces.nvim",
    cmd = { "Telescope workspaces" },
    config = true,
    opts = function()
      return require("plugins.configs.others").workspaces
    end,
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },

  {
    "mg979/vim-visual-multi",
    keys = { "<C-A-j>", "<C-A-k>", "<C-A-l>", "<C-A-h>", "gb", "gB" },
    init = function()
      require("core.mappings").vm.init()
    end,
  },

  {
    "michaeljsmith/vim-indent-object",
    keys = { "v" },
  },

  -- Only load whichkey after all the gui
  {
    "folke/which-key.nvim",
    keys = { "<leader>", '"', "'", "`", "c", "v", "g" },
    init = function()
      require("core.utils").load_mappings("whichkey")
    end,
    config = function(_, opts)
      dofile(vim.g.base46_cache .. "whichkey")
      require("which-key").setup(opts)
    end,
  },
}

local config = require("core.utils").load_config()

if #config.plugins > 0 then
  table.insert(default_plugins, { import = config.plugins })
end

require("lazy").setup(default_plugins, config.lazy_nvim)
