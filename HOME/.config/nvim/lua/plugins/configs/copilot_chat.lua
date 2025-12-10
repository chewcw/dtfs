local M = {}

local file_cache = {}

M.opts = {
  model = "gpt-4.1",
  mappings = {
    reset = {
      normal = "<C-A-r>",
      insert = "<C-A-r>",
    },
    submit_prompt = {
      normal = "<A-CR>",
      insert = "<A-CR>",
    },
    show_help = {
      normal = "g?",
    },
    accept_diff = {
      normal = "<C-A-y>",
      insert = "<C-A-y>",
    },
    yank_diff = {
      normal = "gY",
      register = "+",
    },
    jump_to_diff = {
      normal = "gJ",
    },
    close = {
      normal = "gq",
      insert = "<A-q>",
    },
    quickfix_answers = {
      normal = "gQa",
    },
    quickfix_diffs = {
      normal = "gQd",
    },
    show_info = {
      normal = "gI",
    },
    show_context = {
      normal = "gC",
    },
    show_diff = {
      normal = "gD",
    },
    toggle_sticky = {
      detail = "Makes line under cursor sticky or deletes sticky line.",
      normal = "gR",
    },
  },
  show_folds = true,
  window = {
    width = 0.4,
    height = 1,
  },
  highlight_headers = false,
  prompts = {
    model = "gpt-4.1",
    CustomCommitter = {
      prompt =
      "> #gitlog\n\n> #gitdiff:staged\n\n> Use gitlog as reference of the commit title format, and then write the commit message for the current changes. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.",
    },
  },
  -- contexts = {
  --   file = {
  --     input = function(callback)
  --       local telescope = require("telescope.builtin")
  --       local actions = require("telescope.actions")
  --       local action_state = require("telescope.actions.state")
  --       telescope.find_files({
  --         attach_mappings = function(prompt_bufnr)
  --           actions.select_default:replace(function()
  --             actions.close(prompt_bufnr)
  --             local selection = action_state.get_selected_entry()
  --             callback(selection[1])
  --           end)
  --           return true
  --         end,
  --       })
  --     end,
  --   },
  --   somefiles = {
  --     input = function(callback)
  --       local telescope = require("telescope.builtin")
  --       local actions = require("telescope.actions")
  --       local action_state = require("telescope.actions.state")
  --       telescope.find_files({
  --         attach_mappings = function(prompt_bufnr)
  --           actions.select_default:replace(function()
  --             local picker = action_state.get_current_picker(prompt_bufnr)
  --             local num_selections = #picker:get_multi_selection()
  --             if not num_selections or num_selections <= 1 then
  --               actions.add_selection(prompt_bufnr)
  --             end
  --             actions.send_selected_to_qflist(prompt_bufnr)
  --             local qf_items = vim.fn.getqflist()
  --             -- Extract filenames from quickfix items
  --             local filenames = {}
  --             for _, item in ipairs(qf_items) do
  --               table.insert(filenames, item.text)
  --             end
  --             local filename = table.concat(filenames, ";")
  --             callback(filename)
  --           end)
  --           return true
  --         end,
  --       })
  --     end,
  --     resolve = function(input, source)
  --       local context = require("CopilotChat.context")
  --       local notify = require("CopilotChat.notify")
  --       local utils = require("CopilotChat.utils")
  --       local async = require("plenary.async")
  --
  --       notify.publish(notify.STATUS, "Scanning files")
  --
  --       -- ----------------------------------------------------------------------------
  --       -- These are all from CopilotChat.context
  --       -- ----------------------------------------------------------------------------
  --       local NAME_TYPES = {
  --         "name",
  --         "identifier",
  --         "heading_content",
  --       }
  --
  --       local OUTLINE_TYPES = {
  --         "local_function",
  --         "function_item",
  --         "arrow_function",
  --         "function_definition",
  --         "function_declaration",
  --         "method_definition",
  --         "method_declaration",
  --         "proc_declaration",
  --         "template_declaration",
  --         "macro_declaration",
  --         "constructor_declaration",
  --         "field_declaration",
  --         "class_definition",
  --         "class_declaration",
  --         "interface_definition",
  --         "interface_declaration",
  --         "record_declaration",
  --         "type_alias_declaration",
  --         "import_statement",
  --         "import_from_statement",
  --         "atx_heading",
  --         "list_item",
  --       }
  --
  --       local OFF_SIDE_RULE_LANGUAGES = {
  --         "python",
  --         "coffeescript",
  --         "nim",
  --         "elm",
  --         "curry",
  --         "fsharp",
  --       }
  --
  --       local function get_node_name(node, content)
  --         for _, name_type in ipairs(NAME_TYPES) do
  --           local name_field = node:field(name_type)
  --           if name_field and #name_field > 0 then
  --             return vim.treesitter.get_node_text(name_field[1], content)
  --           end
  --         end
  --
  --         return nil
  --       end
  --
  --       local function get_full_signature(start_row, start_col, lines)
  --         local start_line = lines[start_row + 1]
  --         local signature = vim.trim(start_line:sub(start_col + 1))
  --
  --         -- Look ahead for opening brace on next line
  --         if not signature:match("{") and (start_row + 2) <= #lines then
  --           local next_line = vim.trim(lines[start_row + 2])
  --           if next_line:match("^{") then
  --             signature = signature .. " {"
  --           end
  --         end
  --
  --         return signature
  --       end
  --
  --       -- This function is from CopilotChat.context
  --       local function build_outline(content, filename, ft)
  --         local output = {
  --           filename = filename,
  --           filetype = ft,
  --           content = content,
  --         }
  --
  --         local lang = vim.treesitter.language.get_lang(ft)
  --         local ok, parser = false, nil
  --         if lang then
  --           ok, parser = pcall(vim.treesitter.get_string_parser, content, lang)
  --         end
  --         if not ok or not parser then
  --           ft = string.gsub(ft, "react", "")
  --           ok, parser = pcall(vim.treesitter.get_string_parser, content, ft)
  --           if not ok or not parser then
  --             return output
  --           end
  --         end
  --
  --         local root = parser:parse()[1]:root()
  --         local lines = vim.split(content, "\n")
  --         local symbols = {}
  --         local outline_lines = {}
  --         local depth = 0
  --
  --         local function parse_node(node)
  --           local type = node:type()
  --           local is_outline = vim.tbl_contains(OUTLINE_TYPES, type)
  --           local start_row, start_col, end_row, end_col = node:range()
  --
  --           if is_outline then
  --             depth = depth + 1
  --             local name = get_node_name(node, content)
  --             local signature_start = get_full_signature(start_row, start_col, lines)
  --             table.insert(outline_lines, string.rep("  ", depth) .. signature_start)
  --
  --             -- Store symbol information
  --             table.insert(symbols, {
  --               name = name,
  --               signature = signature_start,
  --               type = type,
  --               start_row = start_row + 1,
  --               start_col = start_col + 1,
  --               end_row = end_row,
  --               end_col = end_col,
  --             })
  --           end
  --
  --           for child in node:iter_children() do
  --             parse_node(child)
  --           end
  --
  --           if is_outline then
  --             if not vim.tbl_contains(OFF_SIDE_RULE_LANGUAGES, ft) then
  --               local end_line = lines[end_row + 1]
  --               local signature_end = vim.trim(end_line:sub(1, end_col))
  --               table.insert(outline_lines, string.rep("  ", depth) .. signature_end)
  --             end
  --             depth = depth - 1
  --           end
  --         end
  --
  --         parse_node(root)
  --
  --         if #outline_lines > 0 then
  --           output.outline = table.concat(outline_lines, "\n")
  --           output.symbols = symbols
  --         end
  --
  --         return output
  --       end
  --
  --       local function get_file(filename, filetype)
  --         notify.publish(notify.STATUS, "Reading file " .. filename)
  --
  --         local modified = utils.file_mtime(filename)
  --         if not modified then
  --           return nil
  --         end
  --
  --         local cached = file_cache[filename]
  --         if cached and cached.modified >= modified then
  --           return cached.outline
  --         end
  --
  --         local content = utils.read_file(filename)
  --         if content then
  --           local outline = build_outline(content, filename, filetype)
  --           file_cache[filename] = {
  --             outline = outline,
  --             modified = modified,
  --           }
  --
  --           return outline
  --         end
  --
  --         return nil
  --       end
  --
  --       -- ----------------------------------------------------------------------------
  --
  --       local files = {}
  --       for filename in input:gmatch("[^;]+") do
  --         table.insert(files, filename)
  --       end
  --
  --       local out = {}
  --
  --       -- Create selected file list in chunks
  --       local chunk_size = 100
  --       for i = 1, #files, chunk_size do
  --         local chunk = {}
  --         for j = i, math.min(i + chunk_size - 1, #files) do
  --           table.insert(chunk, files[j])
  --         end
  --
  --         local chunk_number = math.floor(i / chunk_size)
  --         local chunk_name = chunk_number == 0 and "file_map" or "file_map" .. tostring(chunk_number)
  --
  --         table.insert(out, {
  --           content = table.concat(chunk, "\n"),
  --           filename = chunk_name,
  --           filetype = "text",
  --         })
  --       end
  --
  --       -- Get selected files content
  --       async.util.scheduler()
  --       files = vim.tbl_filter(
  --         function(file)
  --           return file.ft ~= nil
  --         end,
  --         vim.tbl_map(function(file)
  --           return {
  --             name = utils.filepath(file),
  --             ft = utils.filetype(file),
  --           }
  --         end, files)
  --       )
  --
  --       for _, file in ipairs(files) do
  --         local file_data = get_file(file.name, file.ft)
  --         if file_data then
  --           table.insert(out, file_data)
  --         end
  --       end
  --
  --       return out
  --     end,
  --   },
  -- },
  functions = {
    gitlog = {
      description = "Get the last 10 git commits",
      uri = "gitlog://",
      schema = {
        type = "object",
      },
      resolve = function()
        local copilot_chat_utils = require("CopilotChat.utils")
        local cwd = vim.loop.cwd() or vim.fn.getcwd()
        local cmd = {
          "git",
          "--no-pager",
          "-C",
          cwd,
          "log",
          "--no-merges",
          "-10",
        }
        local out = copilot_chat_utils.system(cmd)
        return {
          {
            filename = "gitlog",
            mimetype = "text/gitcommit",
            data = out.stdout,
          }
        }
      end,
    },
  }
}

return M
