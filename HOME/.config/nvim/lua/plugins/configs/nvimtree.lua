local utils = require("core.utils")

local options = {
	filters = {
		dotfiles = false,
		exclude = { vim.fn.stdpath("config") .. "/lua/custom" },
	},
	disable_netrw = true,
	hijack_netrw = true,
	hijack_cursor = true,
	hijack_unnamed_buffer_when_opening = false,
	sync_root_with_cwd = true,
	update_focused_file = {
		enable = true,
		update_root = false,
	},
  respect_buf_cwd = false,
	view = {
		adaptive_size = true,
		side = "left",
		width = 30,
		preserve_window_proportions = true,
	},
	git = {
		enable = true,
		ignore = true,
	},
	filesystem_watchers = {
		enable = true,
	},
	actions = {
		open_file = {
			resize_window = true,
		},
    change_dir = {
      enable = true,
      global = false,
      restrict_above_cwd = false,
    },
	},
	renderer = {
		root_folder_label = false,
		highlight_git = true,
		highlight_opened_files = "none",

		indent_markers = {
			enable = true,
		},

		icons = {
			show = {
				file = true,
				folder = true,
				folder_arrow = true,
				git = true,
			},

			glyphs = {
				-- default = "",
				-- symlink = "🔗",
				-- folder = {
				--   default = "",
				--   empty = "",
				--   empty_open = "",
				--   open = "",
				--   symlink = "🔗",
				--   symlink_open = "🔗",
				-- arrow_open = "▼",
				-- arrow_closed = "▶ ️",
				-- },
				-- -- git = {
				--   unstaged = "✖",
				--   staged = "✔️",
				--   unmerged = "",
				--   renamed = "➜",
				--   untracked = "★",
				--   deleted = "🚫",
				--   ignored = "",
				-- },
			},
		},
	},
	on_attach = function(bufnr)
		local api = require("nvim-tree.api")
		local function opts(desc)
			return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
		end
		vim.keymap.set("n", "<A-\\>", api.node.open.vertical, opts("open in vertical split"))
		vim.keymap.set("n", "<A-_>", api.node.open.horizontal, opts("open in horizontal split"))
		vim.keymap.set("n", "<A-t>", api.node.open.tab, opts("open in new tab"))
		vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("navigate up"))
		vim.keymap.set("n", "l", api.node.open.edit, opts("open"))
		vim.keymap.set("n", "p", api.fs.paste, opts("paste"))
		vim.keymap.set("n", "r", api.fs.rename, opts("rename"))
		vim.keymap.set("n", "-", api.tree.change_root_to_parent, opts("change root to parent"))
		vim.keymap.set("n", "=", api.tree.change_root_to_node, opts("change root to node"))
		vim.keymap.set("n", "y", api.fs.copy.node, opts("copy"))
		vim.keymap.set("n", "c", api.fs.create, opts("create"))
		vim.keymap.set("n", "m", api.marks.bulk.move, opts("bulk move bookmarks"))
		vim.keymap.set("n", "<Tab>", api.marks.toggle, opts("toggle bookmark"))
		vim.keymap.set("n", "R", api.tree.reload, opts("reload tree"))
		vim.keymap.set("n", "q", api.tree.close, opts("close tree"))
		vim.keymap.set("n", "?", api.tree.toggle_help, opts("toggle help"))
		vim.keymap.set("n", "Y", api.fs.copy.absolute_path, opts("copy absolute path"))
		vim.keymap.set("n", "x", api.fs.cut, opts("cut"))
		vim.keymap.set("n", "d", api.fs.remove, opts("remove"))
		vim.keymap.set("n", "I", api.tree.toggle_gitignore_filter, opts("toggle filter gitignore file"))
		vim.keymap.set("n", ".", api.tree.toggle_hidden_filter, opts("toggle filter hidden file"))
		vim.keymap.set("n", "L", api.tree.expand_all, opts("expand all"))
		vim.keymap.set("n", "H", api.tree.collapse_all, opts("collapse all"))
		vim.keymap.set("n", "f", api.live_filter.start, opts("start filter"))
		vim.keymap.set("n", "F", api.live_filter.clear, opts("clear filter"))
		vim.keymap.set("n", "s", api.tree.search_node, opts("search node"))
	end,
}

return options
