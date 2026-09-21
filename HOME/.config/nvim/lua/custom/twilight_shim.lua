local M = {}

function M.setup()
  local ok, view = pcall(require, "twilight.view")
  if not ok or not view then
    return
  end

  local original_get_node = view.get_node

  view.get_node = function(buf, line)
    local parser_ok, parser = pcall(vim.treesitter.get_parser, buf)
    if not parser_ok or not parser then
      return nil
    end
    return original_get_node(buf, line)
  end
end

return M
