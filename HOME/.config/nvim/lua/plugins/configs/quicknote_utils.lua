local utils_window = require("core.utils_window")

local M = {}

local quicknote_open_in_float_window_wrapper = function(quicknote_function)
  if pcall(require, "quicknote") then
    local quicknote = require("quicknote")
    -- Set up an autocommand to capture the newly opened buffer
    local new_buf = nil
    vim.api.nvim_create_autocmd("BufEnter", {
      callback = function()
        -- Capture the current buffer as the new buffer opened by the plugin
        new_buf = vim.api.nvim_get_current_buf()
      end,
      once = true, -- Trigger only once for this call
    })
    -- Run the original quicknote function
    quicknote_function(quicknote)
    -- Delay briefly to ensure the buffer is opened and the BufEnter above has been run
    vim.defer_fn(function()
      -- If the buffer opened (maens that there is any quicknote)
      if new_buf ~= nil then
        -- Retrieve the lines of the current buffer
        local lines = vim.api.nvim_buf_get_lines(new_buf, 0, -1, false)
        -- Close the original buffer created by quicknote
        vim.api.nvim_buf_delete(new_buf, { force = true })
        -- Open the content in float window
        utils_window.open_float_with_file_content(lines)
      end
    end, 10)
  end
end

M.jump_to_next_note = function()
  quicknote_open_in_float_window_wrapper(function(quicknote)
    quicknote.JumpToNextNote()
    quicknote.OpenNoteAtCurrentLine()
  end)
end

M.jump_to_previous_note = function()
  quicknote_open_in_float_window_wrapper(function(quicknote)
    quicknote.JumpToPreviousNote()
    quicknote.OpenNoteAtCurrentLine()
  end)
end

M.preview_note_at_current_line = function()
  -- If a float win already opened, focus to the float win instead
  if vim.g.quicknote_float_win ~= nil then
    vim.api.nvim_set_current_win(vim.g.quicknote_float_win)
  else
    quicknote_open_in_float_window_wrapper(function(quicknote)
      quicknote.OpenNoteAtCurrentLine()
    end)
  end
end

M.open_note_at_current_line = function()
  if pcall(require, "quicknote") then
    require("quicknote").OpenNoteAtCurrentLine()
  end
end

M.open_note_at_cwd = function()
  if pcall(require, "quicknote") then
    require("quicknote").OpenNoteAtCWD()
  end
end

M.delete_note_at_cwd = function()
  local choice = vim.fn.confirm("Are you sure you want to delete the note at cwd?")
  if choice == 1 then
    if pcall(require, "quicknote") then
      require("quicknote").DeleteNoteAtCWD()
    end
  end
end

M.delete_note_at_current_line = function()
  local choice = vim.fn.confirm("Are you sure you want to delete the note at current line?")
  if choice == 1 then
    if pcall(require, "quicknote") then
      require("quicknote").DeleteNoteAtCurrentLine()
    end
  end
end

return M
