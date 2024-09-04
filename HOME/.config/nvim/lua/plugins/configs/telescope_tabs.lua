-- Reference: https://github.com/LukasPietzschmann/telescope-tabs

local is_empty_table = function(t)
  if t == nil then
    return true
  end
  return next(t) == nil
end

local normalize = function(config, existing)
  local conf = existing
  if is_empty_table(config) then
    return conf
  end

  for k, v in pairs(config) do
    conf[k] = v
  end

  return conf
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local close_tab = function(bufnr)
  local current_picker = action_state.get_current_picker(bufnr)
  local current_entry = action_state:get_selected_entry()
  if vim.api.nvim_get_current_tabpage() == current_entry.value[5] then
    vim.notify("You cannot close the currently visible tab :(", vim.log.levels.ERROR)
    return
  end
  current_picker:delete_selection(function(selection)
    for _, wid in ipairs(selection.value[4]) do
      vim.api.nvim_win_close(wid, false)
    end
  end)
end

local M = {
  config = {},
}

local default_conf = {
  entry_formatter = function(
      tab_id,
      buffer_ids,
      file_names,
      file_paths,
      is_current,
      cwd_name,
      buffers_in_cwd,
      tab_char,
      is_modified
  )
    local modified = ""
    if is_modified then
      modified = "[+]"
    end
    if vim.g.toggle_tab_auto_cwd then
      local buffers_in_cwd_string = table.concat(buffers_in_cwd, ", ")
      return string.format(
        "%s %s: %s %s 🖿  %s 🗎 %s",
        tostring(tab_id),
        tab_char,
        modified,
        is_current and " >" or "",
        cwd_name,
        buffers_in_cwd_string
      )
    else
      local file_names_string = table.concat(file_names, ", ")
      return string.format(
        "%s %s: %s %s 🖿  %s 🗎 %s",
        tostring(tab_id),
        tab_char,
        modified,
        is_current and " >" or "",
        cwd_name,
        file_names_string
      )
    end
  end,
  -- this is where we can search
  entry_ordinal = function(tab_id, buffer_ids, file_names, file_paths, is_current, cwd_name, buffers_in_cwd)
    if vim.g.toggle_tab_auto_cwd then
      return table.concat(buffers_in_cwd, " ") .. " " .. cwd_name .. " " .. tab_id
    else
      return table.concat(file_names, " ") .. tab_id
    end
  end,
  show_preview = false,
  close_tab_shortcut_i = "<C-d>",
  close_tab_shortcut_n = "D",
}

M.conf = default_conf

M.setup = function(opts)
  normalize(opts, M.conf)
end

M.go_to_previous = function()
  local last_tab_id = vim.g.last_tab_id
  if last_tab_id then
    vim.api.nvim_set_current_tabpage(last_tab_id)
  else
    print("No previous tab found.")
  end
end

M.list_tabs = function(opts)
  opts = vim.tbl_deep_extend("force", M.conf, opts or {})
  local res = {}
  local current_tab = { number = vim.api.nvim_tabpage_get_number(0), index = nil }
  for index, tid in ipairs(vim.api.nvim_list_tabpages()) do
    local file_names = {}
    local file_paths = {}
    local file_ids = {}
    local window_ids = {}
    local is_modifieds = {}
    local is_current = current_tab.number == vim.api.nvim_tabpage_get_number(tid)

    local tabnr_ordinal = vim.api.nvim_tabpage_get_number(tid)
    local win_num = vim.fn.tabpagewinnr(tabnr_ordinal)
    local working_directory = vim.fn.getcwd(win_num, tabnr_ordinal)
    local cwd_parent = vim.fn.fnamemodify(working_directory, ":h:t")
    local cwd_name = vim.fn.fnamemodify(working_directory, ":t")
    local full_cwd_name = vim.fn.fnamemodify(working_directory, ":p:h")

    local buffers_in_cwd = {}
    local buf_list = vim.api.nvim_list_bufs() -- Get a list of all buffer IDs
    for _, buf_id in ipairs(buf_list) do
      -- Check if the buffer is valid and has a file path
      if vim.api.nvim_buf_is_valid(buf_id) and vim.api.nvim_buf_get_name(buf_id) ~= "" then
        local file_path = vim.api.nvim_buf_get_name(buf_id)
        local parent_folder = vim.fn.fnamemodify(file_path, ":p:h")
        local buffer_name = vim.fn.fnamemodify(file_path, ":t")
        if parent_folder == full_cwd_name then
          table.insert(buffers_in_cwd, buffer_name)
        end
      end
    end

    for _, wid in ipairs(vim.api.nvim_tabpage_list_wins(tid)) do
      -- Only consider the normal windows and ignore the floating windows
      if vim.api.nvim_win_get_config(wid).relative == "" then
        local bid = vim.api.nvim_win_get_buf(wid)
        local path = vim.api.nvim_buf_get_name(bid)
        local file_name = vim.fn.fnamemodify(path, ":t")
        local modified = vim.fn.getbufvar(bid, "&modified")
        table.insert(is_modifieds, modified)
        table.insert(file_names, file_name)
        table.insert(file_paths, path)
        table.insert(file_ids, bid)
        table.insert(window_ids, wid)
      end
    end
    if is_current then
      current_tab.index = index
    end
    local tab_char = string.char(96 + index) -- 96 is char `a`
    local is_modified = false
    for _, changed in ipairs(is_modifieds) do
      if changed == 1 then
        is_modified = true
        break
      end
    end
    print(is_modified)
    table.insert(res, {
      file_names,
      file_paths,
      file_ids,
      window_ids,
      tid,
      is_current,
      cwd_parent .. "/" .. cwd_name,
      buffers_in_cwd,
      tab_char,
      is_modified,
    })
  end
  pickers
      .new(opts, {
        prompt_title = opts.title == nil and "Tabs" or opts.title,
        finder = finders.new_table({
          results = res,
          entry_maker = function(entry)
            local entry_string = opts.entry_formatter(
              entry[5],
              entry[3],
              entry[1],
              entry[2],
              entry[6],
              entry[7],
              entry[8],
              entry[9],
              entry[10]
            )
            local ordinal_string =
                opts.entry_ordinal(entry[5], entry[3], entry[1], entry[2], entry[6], entry[7], entry[8])
            return {
              value = entry,
              path = entry[2][1],
              display = entry_string,
              ordinal = ordinal_string,
            }
          end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if opts.on_open == nil then
              vim.api.nvim_set_current_tabpage(selection.value[5])
            else
              opts.on_open(selection.value[5])
            end
          end)
          map("i", opts.close_tab_shortcut_i, close_tab)
          map("n", opts.close_tab_shortcut_n, close_tab)
          map("n", "<Backspace>", require("plugins.configs.telescope_utils").resume_with_cache)
          return true
        end,
        previewer = opts.show_preview and conf.file_previewer({}) or nil,
        on_complete = {
          function(picker)
            picker:set_selection(current_tab.index - 1)
          end,
        },
      })
      :find()
end

return M
