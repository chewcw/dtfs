local M = {}

-- If the definition is in the same file, just go to the row and column
-- directly instead of opening a Telescope picker.
-- The original Telescope's jump_type option doesn't seem to work like what I want.
-- Issue: https://github.com/nvim-telescope/telescope.nvim/issues/2690
-- document_type should be one of: definition, references, typeDefinition,
-- implementation.
M.go_to = function(document_type, callback)
  local params = vim.lsp.util.make_position_params()
  if document_type == "references" then
    params.context = { includeDeclaration = true }
  end
  vim.lsp.buf_request(0, "textDocument/" .. document_type, params, function(err, result, ctx, _)
    if err then
      vim.notify("Error while fetching " .. document_type .. ": " .. err.message, vim.log.levels.ERROR)
      return
    end

    if not result or vim.tbl_isempty(result) then
      vim.notify("No " .. document_type .. " found", vim.log.levels.INFO)
      return
    end

    -- Handle single or multiple document type
    local target = result[1] or result
    if #result > 1 then
      if #result == 2 then -- This is often the case for references
        target = result[2]
      else
        if callback and type(callback) == "function" then
          callback()
          return
        end
      end
    end

    -- Check if the document type is in the same buffer
    -- references document_type is using target.uri, the rest are using
    -- target.targetUri
    local uri = target.targetUri or target.uri or nil
    if uri then
      local target_bufnr = vim.uri_to_bufnr(uri)
      local client = vim.lsp.get_client_by_id(ctx.client_id)

      local current_bufnr = vim.api.nvim_get_current_buf()
      if target_bufnr == current_bufnr then
        -- result in the same buffer, go to its position
        local offset_encoding = "utf-8"
        if client ~= nil then
          offset_encoding = client.offset_encoding
        end
        vim.lsp.util.jump_to_location(target, offset_encoding)
      else
        -- result in another buffer, call custom function
        if callback and type(callback) == "function" then
          callback()
        end
      end
    else
      vim.notify("Unable to determine target buffer", vim.log.levels.WARN)
    end
  end)
end

return M
