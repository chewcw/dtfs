local M = {}

local max_length = 85

M.insert_comment_with_trails = function()
  vim.ui.input({ prompt = "Insert comment: " }, function(input)
    if input ~= nil then
      -- get row and col of the cursor
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      -- insert text
      vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { input })
      -- run TComment
      vim.cmd.TComment()
      -- get comment length
      local comment_len = string.len(unpack(vim.api.nvim_buf_get_lines(0, row - 1, row, {})))
      local count = 0
      -- insert trailing "-" to the comment
      while comment_len < max_length do
        if count == 0 then
          vim.api.nvim_buf_set_text(0, row - 1, comment_len, row - 1, comment_len, { " - " })
          count = count + 1
        else
          vim.api.nvim_buf_set_text(0, row - 1, comment_len - 1, row - 1, comment_len, { "- " })
        end
        comment_len = string.len(unpack(vim.api.nvim_buf_get_lines(0, row - 1, row, {})))
      end
    end
  end)
end

M.insert_comment_with_solid_line = function()
  -- get row and col of the cursor
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
  -- run TComment
  vim.cmd.TComment()
  -- get comment length
  local comment_len = string.len(unpack(vim.api.nvim_buf_get_lines(0, row - 1, row, {})))
  local count = 0
  while comment_len < max_length do
    if count == 0 then
      vim.api.nvim_buf_set_text(0, row - 1, comment_len, row - 1, comment_len, { " - " })
      count = count + 1
    else
      vim.api.nvim_buf_set_text(0, row - 1, comment_len - 1, row - 1, comment_len, { "- " })
    end
    comment_len = string.len(unpack(vim.api.nvim_buf_get_lines(0, row - 1, row, {})))
  end
end

M.insert_comment_with_header = function()
  vim.ui.input({ prompt = "Insert comment: " }, function(input)
    if input ~= nil then
      vim.cmd("normal O")
      vim.cmd("normal j")
      vim.cmd("normal o")
      vim.cmd("normal k")

      vim.cmd("normal k")
      M.insert_comment_with_solid_line()

      vim.cmd("normal j")
      vim.cmd("normal j")
      M.insert_comment_with_solid_line()

      vim.cmd("normal k")
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { input })
      vim.cmd.TComment()
    end
  end)
end

return M
