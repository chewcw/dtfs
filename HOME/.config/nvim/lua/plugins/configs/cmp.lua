local M = {}

local cmp = require("cmp")

local kind_icons = {
  Text = "",
  Method = "󰆧",
  Function = "󰊕",
  Constructor = "",
  Field = "󰇽",
  Variable = "󰂡",
  Class = "󰠱",
  Interface = "",
  Module = "",
  Property = "󰜢",
  Unit = "",
  Value = "󰎠",
  Enum = "",
  Keyword = "󰌋",
  Snippet = "",
  Color = "󰏘",
  File = "󰈙",
  Reference = "",
  Folder = "󰉋",
  EnumMember = "",
  Constant = "󰏿",
  Struct = "",
  Event = "",
  Operator = "󰆕",
  TypeParameter = "󰅲",
}

local function border(hl_name)
  return {
    { "┌", hl_name },
    { "─", hl_name },
    { "┐", hl_name },
    { "│", hl_name },
    { "┘", hl_name },
    { "─", hl_name },
    { "└", hl_name },
    { "│", hl_name },
  }
end

M.options = {
  core = {
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },

    experimental = {
      ghost_text = true,
    },

    -- completion = {
    --   completeopt = "menu,menuone,nooinsert",
    -- },

    window = {
      documentation = cmp.config.window.bordered({
        winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:FloatBorder",
        border = border("FloatBorder"),
      }),
      completion = cmp.config.window.bordered({
        completeopt = "menu,menuone",
        winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:FloatBorder",
        border = border("FloatBorder"),
      }),
    },

    formatting = {
      fields = { "abbr", "kind", "menu" },

      format = function(entry, vim_item)
        vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind)
        vim_item.menu = ({
          buffer = "[Buffer]",
          nvim_lsp = "[LSP]",
          luasnip = "[LuaSnip]",
          nvim_lua = "[Lua]",
          latex_symbols = "[LaTeX]",
        })[entry.source.name]
        return vim_item
      end,
    },
    matching = {
      disallow_fuzzy_matching = false,
      disallow_fullfuzzy_matching = false,
      disallow_partial_fuzzy_matching = false,
      disallow_partial_matching = false,
      disallow_prefix_unmatching = false,
    },
    mapping = {
      ["<C-k>"] = cmp.mapping.select_prev_item(),
      ["<C-j>"] = cmp.mapping.select_next_item(),
      ["<C-d>"] = cmp.mapping.scroll_docs(4),
      ["<C-u>"] = cmp.mapping.scroll_docs(-4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.close(),
      ["<C-q>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Insert,
        select = true,
      }),
      ["<Tab>"] = cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Insert,
        select = true,
      }),
      ["<C-l>"] = cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Insert,
        select = true,
      }),
    },

    sources = {
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "buffer" },
      { name = "nvim_lua" },
      { name = "async_path" },
      { name = "gitmoji" },
      { name = "emoji" },
    },
  },
  cmdline = {
    mapping = {
      ["<C-j>"] = {
        c = function()
          if cmp.visible() then
            cmp.select_next_item()
          else
            cmp.complete()
          end
        end,
      },
      ["<C-k>"] = {
        c = function()
          if cmp.visible() then
            cmp.select_prev_item()
          else
            cmp.complete()
          end
        end,
      },
      ["<S-CR>"] = {
        c = cmp.mapping.confirm({ select = false }),
      },
      ["<C-q>"] = {
        c = cmp.mapping.abort(),
      },
      ["<C-e>"] = {
        c = cmp.mapping.close(),
      },
    },
    sources = cmp.config.sources({
      { name = "async_path" },
    }, {
      {
        name = "cmdline",
        option = {
          ignore_cmds = { "Man", "!" },
        },
      },
    }),
    formatting = { fields = { "abbr" } },
  },
  search = {
    mapping = {
      ["<C-j>"] = {
        c = function()
          if cmp.visible() then
            cmp.select_next_item()
          else
            cmp.complete()
          end
        end,
      },
      ["<C-k>"] = {
        c = function()
          if cmp.visible() then
            cmp.select_prev_item()
          else
            cmp.complete()
          end
        end,
      },
      ["<S-CR>"] = {
        c = cmp.mapping.confirm({ select = false }),
      },
      ["<C-q>"] = {
        c = cmp.mapping.abort(),
      },
      ["<C-e>"] = {
        c = cmp.mapping.close(),
      },
    },
    sources = {
      { name = "buffer" },
    },
    formatting = { fields = { "abbr" } },
  },
}

return M
