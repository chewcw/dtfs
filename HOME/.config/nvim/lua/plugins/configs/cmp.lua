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

local options = {
  view = {
    entries = { name = "native", selection_order = "near_cursor" },
  },

  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },

  window = {
    completion = {
      completeopt = "menu,menuone",
      winhighlight = "Normal:FloatBorder,FloatBorder:FloatBorder,Search:None",
      scrollbar = false,
      side_padding = 5,
    },
    documentation = {
      winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,Search:None",
    },
  },

  formatting = {
    fields = { "abbr", "kind" },

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

  mapping = {
    ["<C-k>"] = cmp.mapping.select_prev_item(),
    ["<C-j>"] = cmp.mapping.select_next_item(),
    ["<C-d>"] = cmp.mapping.scroll_docs(4),
    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.close(),
    ["<C-q>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    }),
    ["<Tab>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    }),
    -- ["<Tab>"] = cmp.mapping(function(fallback)
    -- 	if cmp.visible() then
    -- 		cmp.select_next_item()
    -- 	elseif require("luasnip").expand_or_jumpable() then
    -- 		vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
    -- 	else
    -- 		fallback()
    -- 	end
    -- end, {
    -- 	"i",
    -- 	"s",
    -- }),
    -- ["<S-Tab>"] = cmp.mapping(function(fallback)
    -- 	if cmp.visible() then
    -- 		cmp.select_prev_item()
    -- 	elseif require("luasnip").jumpable(-1) then
    -- 		vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
    -- 	else
    -- 		fallback()
    -- 	end
    -- end, {
    -- 	"i",
    -- 	"s",
    -- }),
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "nvim_lua" },
    { name = "path" },
    { name = "rg" },
  },
}

return options
