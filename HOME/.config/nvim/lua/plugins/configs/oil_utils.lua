local M = {}

M.open_toggleterm_and_send_selection_parent_path_to_toggleterm = function(direction)
  return {
    desc = "Open toggleterm in specific direction",
    callback = function()
      local oil = require("oil")
      local cwd = oil.get_current_dir()
      -- Close the oil
      oil.close()
      -- Open toggleterm
      pcall(function()
        require("plugins.configs.toggleterm_utils").toggle_term(direction, true, cwd)
      end)
    end,
  }
end

M.exec_shell_command = function()
  return {
    desc = "Exec shell command",
    callback = function()
      local oil = require("oil")
      -- Also refer to telescope_utils.lua's exec_shell_command
      local input_buffer = ""
      local cursor_position = 0
      -- Function to handle key inputs
      local function handle_key(key, replaced_string)
        if key == 9 then
          -- Handle <Tab>: `.` (not escaped) with the desired string
          input_buffer = input_buffer:gsub("([^\\])%.", "%1" .. replaced_string)
          cursor_position = input_buffer:len()
          vim.api.nvim_echo({ { "> ", "None" }, { input_buffer, "String" } }, false, {})
        elseif key == 8 or key == 127 then
          -- Handle <C-h> and DEL: remove last character
          if #input_buffer > 0 and cursor_position > 0 then
            input_buffer = input_buffer:sub(1, cursor_position - 1) .. input_buffer:sub(cursor_position + 1)
            cursor_position = cursor_position - 1
          end
          vim.api.nvim_echo({ { "> ", "None" }, { input_buffer, "String" } }, false, {})
        elseif key == 13 or key == 10 then
          -- Enter pressed: finish input
          -- Append the result to the shell command
          local command = string.format("sh -c ' %s'", input_buffer)
          os.execute(command)
          return false    -- Exit input loop
        elseif key == 68 then -- Left arrow (key code for left arrow key)
          -- Move cursor left
          if cursor_position > 0 then
            cursor_position = cursor_position - 1
          end
        elseif key == 67 then -- Right arrow (key code for right arrow key)
          -- Move cursor right
          if cursor_position < #input_buffer then
            cursor_position = cursor_position + 1
          end
        else
          pcall(function()
            -- Append normal character
            local char = string.char(key)
            input_buffer = input_buffer:sub(1, cursor_position)
                .. char
                .. input_buffer:sub(cursor_position + 1)
            cursor_position = cursor_position + 1
            vim.api.nvim_echo({ { "> ", "None" }, { input_buffer, "String" } }, false, {})
          end)
        end
        return true -- Continue input loop
      end

      local dir = oil.get_current_dir()
      local entry = oil.get_cursor_entry()
      if not entry or not dir then
        return
      end
      local filename = dir .. entry.name

      vim.api.nvim_echo({ { "> ", "None" }, { input_buffer, "String" } }, false, {})

      pcall(function()
        while true do
          local key = vim.fn.getchar() -- Get key as a integer keycode
          -- If `.` followed by <Tab>, expand the `.` to the current selected file name.
          if not handle_key(key, filename) then
            break
          end
        end
      end)
    end,
  }
end

M.go_to_directory = function()
  return {
    desc = "Go to directory",
    callback = function()
      local oil = require("oil")
      -- Prompt for the path input
      local ok, input = pcall(vim.fn.input, {
        prompt = "Enter absolute path: ",
        completion = "file",
      })
      if not ok then
        return
      end
      if input then
        local expanded_input = vim.fn.expand(input) -- to handle something like "~"
        local floatOrNot = vim.g.oil_float_mode
        if vim.fn.isdirectory(expanded_input) == 1 then
          if floatOrNot == "1" then
            oil.close()
            oil.open_float(input)
          else
            oil.close()
            oil.open(input)
          end
        else
          print("Not directory entered")
        end
      end
    end,
  }
end

M.copy_absolute_path = function()
  return {
    desc = "Copy absolute path",
    callback = function()
      local oil = require("oil")
      local entry = oil.get_cursor_entry()
      local dir = oil.get_current_dir()
      if not entry or not dir then
        return
      end
      local filename = dir .. entry.name
      local cb_opts = vim.opt.clipboard:get()
      if vim.tbl_contains(cb_opts, "unnamed") then
        if filename then
          vim.fn.setreg("*", filename)
        end
      end
      if vim.tbl_contains(cb_opts, "unnamedplus") then
        if filename then
          vim.fn.setreg("+", filename)
        end
      end
      vim.notify("Absolute path copied to clipboard")
    end,
  }
end

M.select_window_to_open = function()
  return {
    desc = "Select window to open",
    callback = function()
      local utils_window = require("core.utils_window")
      local oil = require("oil")
      local entry = oil.get_cursor_entry()
      local dir = oil.get_current_dir()
      if not entry or not dir then
        return
      end
      local filename = dir .. entry.name
      utils_window.open(filename, 1, 0)
    end,
  }
end

M.select_directory_as_cwd = function(scope)
  return {
    desc = "Select directory as cwd",
    callback = function()
      local oil = require("oil")
      local entry = oil.get_cursor_entry()
      local current_dir = oil.get_current_dir()
      if not entry or not current_dir then
        return
      end
      local dir = current_dir .. entry.name
      if vim.fn.isdirectory(dir) ~= 1 then
        -- If this cwd is a file, get its parent and set to cwd
        dir = vim.fn.fnamemodify(dir, ":h")
      end
      if scope == "window" then
        vim.cmd(":q!")
        vim.cmd({ cmd = "lcd", args = { dir } })
      else
        -- If other windows were using "lcd", they will not be reset to the new cwd
        -- Therefore, iterate over all windows in the current tab
        -- and reset their local working directory
        vim.cmd(":q!")
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          vim.api.nvim_win_call(win, function()
            vim.cmd({ cmd = "tcd", args = { dir } })
          end)
        end
      end
    end,
  }
end

M.open_file_in_tab = function(dont_care_just_open_in_new_tab)
  return {
    desc = "Open file in tab",
    callback = function()
      local oil = require("oil")
      local entry = oil.get_cursor_entry()
      local current_dir = oil.get_current_dir()
      if not entry or not current_dir then
        return
      end
      local selected_entry = { path = "" }
      selected_entry.path = current_dir .. entry.name
      require("plugins.configs.buffer_utils").open_file_or_buffer_in_tab(
        nil,
        nil,
        dont_care_just_open_in_new_tab,
        selected_entry,
        nil
      )
    end,
  }
end

return M
