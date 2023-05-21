local present, null_ls = pcall(require, "null-ls")

if not present then
	return
end

local b = null_ls.builtins

local sources = {
	-- webdev
  b.formatting.prettierd,

	-- Lua
	b.formatting.stylua,

  -- csharp
  b.formatting.csharpier,

  -- golang
  b.formatting.goimports,

  -- rust
  b.formatting.rustfmt,
}

null_ls.setup({
	debug = true,
	sources = sources,
})
