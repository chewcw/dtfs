local M = {}
local buf, win

M.close = function()
	if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
	end
end

local function removeAscii(text)
	for k, v in pairs(text) do
		-- Remove all the ansi escape characters
		text[k] = string.gsub(v, "[\27\155][][()#;?%d]*[A-PRZcf-ntqry=><~]", "")
	end
	return text
end

M.zoom_toggle = function()
	local width = vim.api.nvim_get_option("columns")
	local max_width = math.ceil(width * 0.9)
	local min_width = math.ceil(width * 0.5)
	if vim.api.nvim_win_get_width(win) ~= max_width then
		vim.api.nvim_win_set_width(win, max_width)
	else
		vim.api.nvim_win_set_width(win, min_width)
	end
end

local function starts_with(str, start)
	return str:sub(1, #start) == start
end

local function redraw(cmd)
	local result = {}

	if cmd == nil or cmd == "" then
		table.insert(result, "Attempt to execute empty command!")
	elseif starts_with(cmd, "!") then
		-- System command
		result = removeAscii(vim.fn.systemlist(string.sub(cmd, 2)))
	else
		-- Vim EX command
		result = vim.fn.split(vim.fn.execute(cmd), "\n")
	end

	vim.api.nvim_buf_set_option(buf, "modifiable", true)

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, result)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

local function set_mappings()
	local mappings = {
		q = "close()",
		-- ["<cr>"] = "zoom_toggle()",
	}

	for k, v in pairs(mappings) do
		vim.api.nvim_buf_set_keymap(buf, "n", k, ':lua require"core.utils_redir".' .. v .. "<cr>", {
			nowait = true,
			noremap = true,
			silent = true,
		})
	end
end

local function create_win(filetype, window_type)
	filetype = (filetype == nil and "result") or filetype
  if window_type == "horizontal" then
    vim.api.nvim_command("botright new")
  end

  if window_type == "vertical" then
    vim.api.nvim_command("botright vnew")
  end

  if window_type == "tab" then
    vim.api.nvim_command("tabnew")
  end

	win = vim.api.nvim_get_current_win()
	buf = vim.api.nvim_get_current_buf()

	vim.api.nvim_buf_set_name(0, "result #" .. buf)

	vim.api.nvim_buf_set_option(0, "buftype", "nofile")
	vim.api.nvim_buf_set_option(0, "swapfile", false)
	vim.api.nvim_buf_set_option(0, "filetype", filetype)
	vim.api.nvim_buf_set_option(0, "bufhidden", "wipe")

	vim.api.nvim_command("setlocal wrap")
	vim.api.nvim_command("setlocal cursorline")

	set_mappings()
end

M.nredir = function(cmd, window_type, filetype)
	-- if win and vim.api.nvim_win_is_valid(win) then
		-- vim.api.nvim_set_current_win(win)
	-- else
  create_win(filetype, window_type)
	-- end

	redraw(cmd)
end

return M
