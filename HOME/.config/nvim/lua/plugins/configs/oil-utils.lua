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

return M
