-- All plugins have lazy=true by default,to load a plugin on startup just lazy=false
-- List of all default plugins & their definitions
local default_plugins = {

  {
    "nvim-lua/plenary.nvim",
    branch = "master",
    commit = "0dbe561",
  },

  {
    "nvim-tree/nvim-web-devicons",
    opts = function()
      return require("plugins.configs.others").webdevicons
    end,
    config = function(_, opts)
      require("nvim-web-devicons").setup(opts)
    end,
    branch = "master",
    commit = "bc11ee2",
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
      require("indent_blankline").setup(opts)
    end,
    branch = "master",
    commit = "9637670",
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
      -- dofile(vim.g.base46_cache .. "syntax")
      require("nvim-treesitter.configs").setup(opts)
    end,
    branch = "master",
    commit = "30604fd",
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
      -- dofile(vim.g.base46_cache .. "git")
      require("gitsigns").setup(opts)
    end,
    branch = "main",
    commit = "d927caa",
  },

  -- lsp stuff
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonInstallAll", "MasonUninstall", "MasonUninstallAll", "MasonLog" },
    opts = function()
      return require("plugins.configs.mason")
    end,
    config = function(_, opts)
      require("mason").setup(opts)

      -- custom cmd to install all mason binaries listed
      vim.api.nvim_create_user_command("MasonInstallAll", function()
        vim.cmd("MasonInstall " .. table.concat(opts.ensure_installed, " "))
      end, {})

      vim.g.mason_binaries_list = opts.ensure_installed
    end,
    branch = "main",
    commit = "ee6a7f1",
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
        branch = "main",
        commit = "0010ea9",
      },
      {
        "Hoffs/omnisharp-extended-lsp.nvim",
        branch = "main",
        commit = "78cda39",
      },
    },
    init = function()
      require("core.utils").lazy_load("nvim-lspconfig")
    end,
    config = function()
      require("plugins.configs.lspconfig")
    end,
    branch = "master",
    commit = "37f362e",
  },

  -- cmp related
  {
    "hrsh7th/nvim-cmp",
    event = "BufEnter",
    dependencies = {
      -- cmp sources plugins
      {
        -- {
        --   "L3MON4D3/LuaSnip",
        --   dependencies = "rafamadriz/friendly-snippets",
        --   opts = { history = true, updateevents = "TextChanged,TextChangedI" },
        --   config = function(_, opts)
        --     require("plugins.configs.others").luasnip(opts)
        --   end,
        --   branch = "master",
        --   commit = "ea7d7ea",
        -- },
        -- {
        --   "saadparwaiz1/cmp_luasnip",
        --   branch = "master",
        --   commit = "1809552",
        -- },
        -- {
        --   "hrsh7th/cmp-nvim-lua",
        --   branch = "main",
        --   commit = "f12408b",
        -- },
        {
          "hrsh7th/cmp-nvim-lsp",
          branch = "main",
          commit = "44b16d1",
        },
        {
          "hrsh7th/cmp-buffer",
          branch = "main",
          commit = "3022dbc",
        },
        -- {
        --   "hrsh7th/cmp-path",
        --   branch = "main",
        --   commit = "91ff86c",
        -- },
        {
          "https://codeberg.org/FelipeLema/cmp-async-path",
          branch = "main",
          commit = "7df7f3",
        },
        {
          "hrsh7th/cmp-cmdline",
          branch = "main",
          commit = "d250c63",
        },
        {
          "hrsh7th/cmp-emoji",
          branch = "main",
          commit = "e8398e2",
        },
        {
          "Dynge/gitmoji.nvim",
          branch = "main",
          commit = "326ddf0",
          ft = "gitcommit",
        },
      },
    },
    opts = function()
      return require("plugins.configs.cmp").options
    end,
    config = function(_, opts)
      require("cmp").setup(opts.core)
      require("cmp").setup.cmdline(":", opts.cmdline)
      require("cmp").setup.cmdline("/", opts.search)
    end,
    branch = "main",
    commit = "a110e12",
  },

  -- file managing , picker etc
  {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    init = function()
      require("core.utils").load_mappings("nvimtree")
    end,
    opts = function()
      return require("plugins.configs.nvimtree")
    end,
    config = function(_, opts)
      require("nvim-tree").setup(opts)
      vim.g.nvimtree_side = opts.view.side
    end,
    branch = "master",
    commit = "5897b36",
  },

  {
    "nvim-telescope/telescope.nvim",
    cmd = { "Telescope" },
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        branch = "main",
        commit = "9ef21b2",
      },
      {
        "nvim-telescope/telescope-file-browser.nvim",
        branch = "master",
        commit = "ad7b637",
      },
      {
        "nvim-telescope/telescope-ui-select.nvim",
        branch = "master",
        commit = "6e51d7d",
      },
      {
        "LukasPietzschmann/telescope-tabs",
        branch = "master",
        commit = "a38c8fe",
      },
    },
    init = function()
      -- put this before loading mappings because
      -- when nvim loads the first time, if I press the mapping (<leader>fr) to open
      -- Telescope.resume(), error occurs saying that "telescope" plugin is not found
      -- or sort.
      require("telescope")
      require("core.utils").load_mappings("telescope")
    end,
    opts = function()
      return require("plugins.configs.telescope").options
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      -- load extensions
      for _, ext in ipairs(opts.extensions_list) do
        telescope.load_extension(ext)
      end
    end,
    branch = "master",
    commit = "6b79d7a",
  },

  {
    "tpope/vim-surround",
    keys = { "v", "cs", "S", "ds", "ysiw" },
    branch = "master",
    commit = "3d188ed",
  },

  {
    "tomtom/tcomment_vim",
    event = { "BufEnter " },
    branch = "master",
    commit = "b4930f9",
  },

  -- {
  --   "easymotion/vim-easymotion",
  --   keys = { "<leader>S" },
  --   init = function()
  --     require("core.utils").load_mappings("easymotion")
  --   end,
  -- },

  -- {
  --   "gelguy/wilder.nvim",
  --   event = "BufEnter",
  --   opts = function()
  --     return require("plugins.configs.others").wilder
  --   end,
  --   init = function()
  --     local wilder = require("wilder")
  --     wilder.set_option(
  --       "renderer",
  --       wilder.popupmenu_renderer(wilder.popupmenu_border_theme({
  --         highlights = {
  --           border = "FloatBorder",
  --         },
  --         pumblend = 20,
  --       }))
  --     )
  --   end,
  --   config = function(_, opts)
  --     require("wilder").setup(opts)
  --   end,
  --   branch = "master",
  --   commit = "679f348",
  -- },

  {
    "jeetsukumaran/vim-markology",
    event = "VeryLazy",
    init = function()
      vim.g.markology_include = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    end,
    branch = "master",
    commit = "9681b3f",
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
    branch = "main",
    commit = "12cba0a",
  },

  {
    "Exafunction/codeium.vim",
    cmd = { "CodeiumEnable" },
    init = function()
      require("core.utils").load_mappings("codeium")
    end,
    branch = "main",
    commit = "9406f13",
  },

  {
    "natecraddock/workspaces.nvim",
    cmd = { "Telescope workspaces" },
    config = true,
    opts = function()
      return require("plugins.configs.others").workspaces
    end,
    branch = "master",
    commit = "a6fb499",
  },

  -- {
  --   "windwp/nvim-autopairs",
  --   event = "InsertEnter",
  --   config = true,
  --   opts = function()
  --     return require("plugins.configs.others").nvim_autopairs
  --   end,
  --   branch = "master",
  --   commit = "a52fc6e",
  -- },

  {
    "mg979/vim-visual-multi",
    event = "BufEnter",
    init = function()
      require("core.mappings").vm.init()
      -- highlight groups
      -- https://github.com/mg979/vim-visual-multi/wiki/Highlight-colors
      vim.cmd("let g:VM_Mono_hl = 'CurSearch'")
      vim.cmd("let g:VM_Extend_hl = 'Visual'")
      vim.cmd("let g:VM_Cursor_hl = 'Visual'")
      vim.cmd("let g:VM_Insert_hl = 'Cursor'")
      vim.cmd("let g:VM_highlight_matches = ''")
    end,
    branch = "master",
    commit = "724bd53",
  },

  {
    "michaeljsmith/vim-indent-object",
    keys = { "v" },
    branch = "master",
    commit = "5c5b24c",
  },

  -- debugging
  -- {
  --   "mfussenegger/nvim-dap",
  --   keys = { "<leader>d" },
  --   dependencies = {
  --     require("plugins.configs.nvim-dap").dapui,
  --     require("plugins.configs.nvim-dap").virtual_text,
  --     require("plugins.configs.nvim-dap").python,
  --     require("plugins.configs.nvim-dap").go,
  --   },
  --   init = function()
  --     require("core.utils").load_mappings("nvim_dap")
  --   end,
  --   config = function()
  --     require("plugins.configs.nvim-dap").csharp.setup()
  --     require("plugins.configs.nvim-dap").rust.setup()
  --   end,
  --   branch = "master",
  --   commit = "31e1ece",
  -- },

  {
    "nvim-treesitter/nvim-treesitter-context",
    lazy = false,
    branch = "master",
    commit = "31692b2",
    opts = function()
      return require("plugins.configs.others").treesitter_context
    end,
    config = function(_, opts)
      require("treesitter-context").setup(opts)
    end,
  },

  {
    "tpope/vim-fugitive",
    lazy = false,
    branch = "master",
    init = function()
      -- my own command, may need to remove this user command if later vim-fugitive
      -- was uninstalled
      vim.api.nvim_create_user_command("Gll", function(args)
        local cmd = [[ 0Git log --graph --pretty=format:"%h %Cred%an %Cblue%aI %Cred%d%Cgreen%s" ]]
        if args["args"] then
          cmd = cmd .. " " .. args["args"]
        end
        vim.cmd(cmd)
      end, { desc = "Git log with format", nargs = "*" })

      vim.api.nvim_create_user_command("Gllh", function(args)
        local cmd = [[ Git log --graph --pretty=format:"%h %Cred%an %Cblue%aI %Cred%d%Cgreen%s" ]]
        if args["args"] then
          cmd = cmd .. " " .. args["args"]
        end
        vim.cmd(cmd)
      end, { desc = "Git log with format (horizontal)", nargs = "*" })

      vim.api.nvim_create_user_command("Gllv", function(args)
        local cmd = [[ vertical Git log --graph --pretty=format:"%h %Cred%an %Cblue%aI %Cred%d%Cgreen%s" ]]
        if args["args"] then
          cmd = cmd .. " " .. args["args"]
        end
        vim.cmd(cmd)
      end, { desc = "Git log with format (vertical)", nargs = "*" })

      vim.api.nvim_create_user_command("Gllt", function(args)
        local cmd = [[ Git log --graph --pretty=format:"%h %Cred%an %Cblue%aI %Cred%d%Cgreen%s" ]]
        if args["args"] then
          cmd = cmd .. " " .. args["args"]
        end
        vim.cmd("tabnew") -- create new tab
        vim.cmd(cmd)    -- show the log
        vim.cmd("wincmd k") -- move cursor to above buffer
        vim.cmd("wincmd q") -- close the empty buffer
      end, { desc = "Git log with format (new tab)", nargs = "*" })
    end,
  },

  {
    "junegunn/gv.vim",
    lazy = false,
    branch = "master",
    commit = "b6bb666",
  },

  -- {
  --   "NeogitOrg/neogit",
  --   command = { "Neogit" },
  --   config = function(_, opts)
  --     require("neogit").setup(opts)
  --   end,
  --   branch = "master",
  --   commit = "7b4a2c7",
  -- },

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    lazy = true,
    branch = "master",
    commit = "a923f5f",
  },

  {
    "mbbill/undotree",
    cmd = { "UndotreeToggle" },
    lazy = true,
    branch = "master",
    commit = "36ff7ab",
  },

  -- {
  -- "kevinhwang91/nvim-ufo",
  -- dependencies = {
  --   "kevinhwang91/promise-async",
  --   {
  --     "luukvbaal/statuscol.nvim",
  --     config = function()
  --       local builtin = require("statuscol.builtin")
  --       require("statuscol").setup({
  --         relculright = true,
  --         segments = {
  --           { text = { builtin.foldfunc },      click = "v:lua.ScFa" },
  --           { text = { "%s" },                  click = "v:lua.ScSa" },
  --           { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
  --         },
  --       })
  --     end,
  --     branch = "main",
  --     commit = "3b62975",
  --   },
  -- },
  -- event = "BufReadPost",
  -- lazy = false,
  -- opts = function()
  --   return require("plugins.configs.others").ufo
  -- end,
  -- init = function()
  --   vim.keymap.set("n", "zR", function()
  --     require("ufo").openAllFolds()
  --   end)
  --   vim.keymap.set("n", "zM", function()
  --     require("ufo").closeAllFolds()
  --   end)
  -- end,
  -- config = function(_, opts)
  --   require("ufo").setup(opts)
  -- end,
  -- branch = "main",
  -- commit = "b0741a6",
  -- },

  {
    "folke/trouble.nvim",
    lazy = false,
    init = function()
      require("core.utils").load_mappings("trouble")
    end,
    config = true,
    branch = "main",
    commit = "f1168fe",
  },

  {
    "Issafalcon/lsp-overloads.nvim",
    lazy = true,
    cmd = { "LspOverloadsSignatureAutoToggle" },
    config = true,
    branch = "main",
    commit = "6b02341",
  },

  {
    "sindrets/diffview.nvim",
    lazy = false,
    opts = function()
      local actions = require("diffview.actions")
      return require("plugins.configs.others").diffview(actions)
    end,
    config = function(_, opts)
      require("diffview").setup(opts)
    end,
    branch = "main",
    commit = "72c6983",
  },

  {
    "rmagatti/auto-session",
    lazy = false,
    opts = function()
      return {
        log_level = "error",
        auto_session_suppress_dirs = {
          "~",
          "~/*",
          "~/Documents/*",
          "~/Documents/dtfs/*",
          "/tmp",
          "/tmp/*",
        },
      }
    end,
  },

  -- Only load whichkey after all the gui
  {
    "folke/which-key.nvim",
    keys = { "<leader>", '"', "'", "`", "c", "v", "g" },
    init = function()
      require("core.utils").load_mappings("whichkey")
    end,
    opts = function()
      return require("plugins.configs.others").whichkey
    end,
    config = function(_, opts)
      require("which-key").setup(opts)
    end,
    branch = "main",
    commit = "7ccf476",
  },
}

local config = require("core.utils").load_config()

if #config.plugins > 0 then
  table.insert(default_plugins, { import = config.plugins })
end

require("lazy").setup(default_plugins, config.lazy_nvim)
