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
      is_modified,
      absolute_path
  )
    local modified = ""
    if is_modified then
      modified = "[+]"
    end
    local icon = (file_names[1]:match("Fugitive") and " ") or "🖿"
    -- This line is just creating spaces based on the longest cwd name in the list,
    -- so that the every absolute_path in the list would aligned with each other
    if vim.g.TabAutoCwd == "1" then
      local spaces = string.rep(" ", vim.g.telescope_tabs_longest_cwd_name_count - #cwd_name + 5)
      return string.format(
        "%s %s: %s %s %s  %s%s➨ %s | %s", -- TODO: Add another %s for the file's absolute path
        string.format("%02d", tab_id),
        tab_char,
        modified,
        is_current and "🚩" or "  ",
        icon,
        (file_names[1]:match("fugitive://") or
          file_names[1]:match("/tmp/nvim.ccw/")) and file_names[1] or cwd_name,
        spaces,
        absolute_path,
        file_paths[1]
      )
    else
      local spaces = string.rep(" ", vim.g.telescope_tabs_longest_file_name_count - #file_names[1] + 5)
      return string.format(
        "%s %s: %s %s %s  %s%s➨ %s | %s",
        string.format("%02d", tab_id),
        tab_char,
        modified,
        is_current and "🚩" or "  ",
        icon,
        file_names[1],
        spaces,
        absolute_path,
        file_paths[1]
      )
    end
  end,
  -- this is where we can search
  entry_ordinal = function(tab_id, buffer_ids, file_names, file_paths, is_current, cwd_name, buffers_in_cwd,
                           absolute_path)
    if vim.g.TabAutoCwd == "1" then
      return table.concat(buffers_in_cwd, " ") .. " " .. cwd_name .. " " .. tab_id .. " " .. absolute_path
    else
      return table.concat(file_names, " ") .. tab_id .. " " .. absolute_path
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

  -- if this is toggleterm then close it first
  local buf_nr = vim.api.nvim_get_current_buf()
  local buf_name = vim.api.nvim_buf_get_name(buf_nr)
  if buf_name:lower():find("toggleterm") then
    vim.cmd("wincmd q")
    vim.g.toggle_term_opened = false
  end

  if last_tab_id then
    pcall(vim.api.nvim_set_current_tabpage, last_tab_id)
  else
    print("No previous tab found.")
  end
end

M.list_tabs = function(opts)
  opts = vim.tbl_deep_extend("force", M.conf, opts or {})
  local res = {}
  -- This is to store the cwd name in the list
  local cwd_names = {}
  local file_names = {}
  local current_tab = { number = vim.api.nvim_tabpage_get_number(0), index = nil }
  for index, tid in ipairs(vim.api.nvim_list_tabpages()) do
    local file_names_in_tab = {}
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
    local absolute_path_exclude_cwd_name = ""
    if vim.g.TabAutoCwd == "1" then
      absolute_path_exclude_cwd_name = vim.fn.fnamemodify(working_directory, ":p:h:h:h")
    else
      absolute_path_exclude_cwd_name = vim.fn.fnamemodify(working_directory, ":p:h")
    end

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
        -- This is fugitive related buffer
        if path:match("fugitive://") or path:match("/tmp/nvim.ccw/") then
          file_name = "Fugitive"
        end
        local modified = vim.fn.getbufvar(bid, "&modified")
        table.insert(is_modifieds, modified)
        table.insert(file_names_in_tab, file_name)
        table.insert(file_paths, path)
        table.insert(file_ids, bid)
        table.insert(window_ids, wid)
      end
    end
    if is_current then
      current_tab.index = index
    end
    local tab_char = string.char(96 + index) -- 96 is char `a`
    if index >= 14 then                      -- skip `n`, somehow buffer_line doesn't use `n` as its tab jump id?
      tab_char = string.char(96 + index + 1)
    end
    local is_modified = false
    for _, changed in ipairs(is_modifieds) do
      if changed == 1 then
        is_modified = true
        break
      end
    end
    table.insert(res, {
      file_names_in_tab,
      file_paths,
      file_ids,
      window_ids,
      tid,
      is_current,
      cwd_parent .. "/" .. cwd_name,
      buffers_in_cwd,
      tab_char,
      is_modified,
      absolute_path_exclude_cwd_name,
    })
    table.insert(cwd_names, cwd_parent .. "/" .. cwd_name)
    table.insert(file_names, file_names_in_tab[1])
  end

  if vim.g.TabAutoCwd == "1" then
    -- Find the longest count of the cwd names in the list
    local longest = ""
    vim.g.telescope_tabs_longest_cwd_name_count = 0
    if cwd_names ~= nil then
      for _, str in ipairs(cwd_names) do
        if #str > #longest then
          longest = str
        end
      end
    end
    vim.g.telescope_tabs_longest_cwd_name_count = #longest
  else
    -- Find the longest count of the file names in the list
    local longest = ""
    vim.g.telescope_tabs_longest_file_name_count = 0
    if file_names ~= nil then
      for _, str in ipairs(file_names) do
        if #str > #longest then
          longest = str
        end
      end
    end
    vim.g.telescope_tabs_longest_file_name_count = #longest
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
              entry[10],
              entry[11]
            )
            local ordinal_string =
                opts.entry_ordinal(entry[5], entry[3], entry[1], entry[2], entry[6], entry[7], entry[8], entry[11])
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
          map("n", "<A-e>", function()
            vim.api.nvim_command("BufferLinePick")
          end)
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
