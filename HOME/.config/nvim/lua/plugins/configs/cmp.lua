local M = {}

local cmp = require("cmp")
local compare = require("cmp").config.compare

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

-- Helper method to return the entry_filter from nvim_lsp
local function entry_filter(entry_name)
  if entry_name == nil then
    return nil
  end
  return {
    config = {
      sources = {
        {
          name = "nvim_lsp",
          entry_filter = function(entry)
            return require("cmp.types").lsp.CompletionItemKind[entry:get_kind()] == entry_name
          end,
        },
      },
    }
  }
end

M.options = {
  core = {
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },

    -- experimental = {
    --   ghost_text = {
    --     hl_group = "CmpGhostText",
    --   },
    -- },

    sorting = {
      priority_weight = 1.0,
      comparators = {
        compare.score, -- based on :  score = score + ((#sources - (source_index - 1)) * sorting.priority_weight)
        compare.recently_used,
        compare.locality,
        compare.offset,
        compare.order,
        -- compare.scopes,
        -- compare.score_offset,
        -- compare.sort_text,
        -- compare.exact,
        -- compare.kind,
        -- compare.length,
      },
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
        -- winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:FloatBorder",
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
          async_path = "[Async_Path]",
          gitmoji = "[Gitmoji]",
          emoji = "[Emoji]",
          cmdline = "[CmdLine]",
          fuzzy_buffer = "[FuzzyBuffer]",
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
      ["<C-p>"] = cmp.mapping.select_prev_item(),
      ["<C-n>"] = cmp.mapping.select_next_item(),
      ["<C-d>"] = cmp.mapping.scroll_docs(4),
      ["<C-u>"] = cmp.mapping.scroll_docs(-4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-x>c"] = cmp.mapping.complete(entry_filter("Class")),
      ["<C-x>m"] = cmp.mapping.complete(entry_filter("Method")),
      ["<C-x>f"] = cmp.mapping.complete(entry_filter("Function")),
      ["<C-x>e"] = cmp.mapping.complete(entry_filter("Enum")),
      ["<C-x>E"] = cmp.mapping.complete(entry_filter("EnumMember")),
      ["<C-x>i"] = cmp.mapping.complete(entry_filter("Interface")),
      ["<C-x>v"] = cmp.mapping.complete(entry_filter("Variable")),
      ["<C-x>s"] = cmp.mapping.complete(entry_filter("Struct")),
      ["<C-x>k"] = cmp.mapping.complete(entry_filter("Keyword")),
      ["<C-x>t"] = cmp.mapping.complete(entry_filter("TypeParameter")),
      ["<C-x>T"] = cmp.mapping.complete(entry_filter("Text")),
      ["<C-x>F"] = cmp.mapping.complete(entry_filter("Field")),
      ["<C-x>S"] = cmp.mapping.complete(entry_filter("Snippet")),
      ["<C-y>"] = cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Insert,
        select = true,
      }),
      ["<C-e>"] = cmp.mapping.abort(),
      -- ["<C-q>"] = cmp.mapping.abort(),
      ["<CR>"] = (function()
        vim.api.nvim_replace_termcodes("<CR>", false, false, true)
        cmp.mapping.abort()
      end)(),
      ["<C-l>"] = cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Insert,
        select = false,
      }),
    },

    sources = {
      { name = "nvim_lsp" },
      -- { name = "luasnip" },
      { name = "buffer" },
      { name = "nvim_lua" },
      { name = "async_path" },
      { name = "gitmoji" },
      { name = "emoji",     option = { insert = true } },
    },
  },
  cmd = {
    mapping = {
      ["<C-n>"] = {
        c = function()
          if cmp.visible() then
            cmp.select_next_item()
          else
            cmp.complete()
          end
        end,
      },
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
      ["<C-p>"] = {
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
      -- ["<C-q>"] = {
      -- c = cmp.mapping.abort(),
      -- },
      ["<C-e>"] = {
        c = cmp.mapping.abort(),
      },
      ["<C-Space>"] = {
        c = cmp.mapping.complete(),
      },
      ["<C-l>"] = {
        c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = false }),
      },
      ["<C-y>"] = {
        c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),
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
    formatting = { fields = { "abbr", "kind", "menu" } },
  },
  search = {
    mapping = {
      ["<C-j>"] = {
        c = function()
          if cmp.visible() then
            cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
          else
            cmp.complete()
          end
        end,
      },
      ["<C-n>"] = {
        c = function()
          if cmp.visible() then
            cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
          else
            cmp.complete()
          end
        end,
      },
      ["<C-k>"] = {
        c = function()
          if cmp.visible() then
            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
          else
            cmp.complete()
          end
        end,
      },
      ["<C-p>"] = {
        c = function()
          if cmp.visible() then
            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
          else
            cmp.complete()
          end
        end,
      },
      ["<S-CR>"] = {
        c = cmp.mapping.confirm({ select = false }),
      },
      -- ["<C-q>"] = {
      -- c = cmp.mapping.abort(),
      -- },
      ["<C-e>"] = {
        c = cmp.mapping.abort(),
      },
      ["<C-Space>"] = {
        c = cmp.mapping.complete(),
      },
      ["<C-y>"] = {
        c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),
      },
    },
    sources = {
      { name = "buffer" },
      { name = "fuzzy_buffer" },
    },
    formatting = { fields = { "abbr", "kind", "menu" } },
  },
}

return M
