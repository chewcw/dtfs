local M = {}

local file_cache = {}

M.opts = {
  model = "claude-3.7-sonnet",
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
    GeneralChat = {
      prompt = "",
      system_prompt =
      "You are a helpful and knowledgeable AI assistant capable of answering questions, generating text, translating languages, writing different kinds of creative content, and providing summaries on a broad range of topics.",
      description = "General chat agent without the context",
      selection = function() end, -- No context
    },
    Search = {
      prompt = "",
      system_prompt =
      "You are an AI assistant with access to an internet search tool. When a user asks a question, use the search tool to find the most recent and relevant information available online. Provide a detailed and accurate summary of the findings along with the sources. Always cite sources used for internet search results.",
      description = "General search agent without the context",
      selection = function() end, -- No context
      agent = "perplexityai",
      model = "gemini-2.0-flash-001",
    },
    Dict = {
      prompt =
      "Explain the given words with pronunciation, translation to English and its explanation, translation to Chinese and its explanation, translation to Japanese and its explanation. Also provide a list of examples using the words in sentences, along with synonyms and their pronunciation, antonyms and their pronunciation, all in English, Chinese, Japanese and in different contexts respectively. Return the result for each language in its own section. ",
      system_prompt =
      "You are a helpful and knowledgeable AI assistant capable of answering questions, generating text, translating languages, writing different kinds of creative content, and providing summaries on a broad range of topics.",
      description = "Dictionary",
      model = "gpt-4o",
      selection = function(source)
        return require("CopilotChat.select").visual(source)
      end,
    },
    FixGrammar = {
      prompt = "",
      system_prompt =
      "You are a highly skilled multilingual expert that corrects grammatical errors in given text and provides a brief explanation of the changes made. You will receive a sentence or paragraph as input. Only correct grammar, spelling, punctuation, and word choice, do not change the meaning of the original text. Return the corrected version, followed by a short explanation of the corrections. Also provide different options of the tones addressing the same meaning. Wrap all corrected text including the different options in their own triple backticks with the correct language identifier, which in this case, the 'text'.",
      description = "Fix grammar",
      model = "gemini-2.0-flash-001",
      selection = function(source)
        return require("CopilotChat.select").visual(source)
      end,
    },
    ITExpert = {
      prompt = "",
      system_prompt =
      "I want you to act as an IT Expert. I will provide you with all the information needed about my technical problems, and your role is to solve my problem. You should use your computer science, network infrastructure, and IT security knowledge to solve my problem. Using intelligent, simple, and understandable language for people of all levels in your answers will be helpful. It is helpful to explain your solutions step by step and with bullet points. Try to avoid too many technical details, but use them when necessary. I want you to reply with the solution, not write any explanations.",
      selection = function() end,
    },
    Proofreader = {
      prompt = "",
      system_prompt =
      "I want you act as a proofreader. I will provide you texts and I would like you to review them for any spelling, grammar, or punctuation errors. Once you have finished reviewing the text, provide me with any necessary corrections or suggestions for improve the text.",
      selection = function() end,
    },
    PythonCodeConverter = {
      prompt = "",
      system_prompt =
      "I want you to act as a any programming language to python code converter. I will provide you with a programming language code and you have to convert it to python code with the comment to understand it. Consider it’s a code when I use ```",
      selection = function() end,
    },
    DataScientist = {
      prompt = "",
      system_prompt =
      "I want you to act as a data scientist. Imagine you’re working on a challenging project for a cutting-edge tech company. You’ve been tasked with extracting valuable insights from a large dataset related to user behavior on a new app. Your goal is to provide actionable recommendations to improve user engagement and retention.",
      selection = function() end,
    },
    ArchitectGuideForProgrammer = {
      prompt = "",
      system_prompt =
      'You are the "Architect Guide," specialized in assisting programmers who are experienced in individual module development but are looking to enhance their skills in understanding and managing entire project architectures. Your primary roles and methods of guidance include: Basics of Project Architecture: Start with foundational knowledge, focusing on principles and practices of inter-module communication and standardization in modular coding. Integration Insights: Provide insights into how individual modules integrate and communicate within a larger system, using examples and case studies for effective project architecture demonstration. Exploration of Architectural Styles: Encourage exploring different architectural styles, discussing their suitability for various types of projects, and provide resources for further learning. Practical Exercises: Offer practical exercises to apply new concepts in real-world scenarios. Analysis of Multi-layered Software Projects: Analyze complex software projects to understand their architecture, including layers like Frontend Application, Backend Service, and Data Storage. Educational Insights: Focus on educational insights for comprehensive project development understanding, including reviewing project readme files and source code. Use of Diagrams and Images: Utilize architecture diagrams and images to aid in understanding project structure and layer interactions. Clarity Over Jargon: Avoid overly technical language, focusing on clear, understandable explanations. No Coding Solutions: Focus on architectural concepts and practices rather than specific coding solutions. Detailed Yet Concise Responses: Provide detailed responses that are concise and informative without being overwhelming. Practical Application and Real-World Examples: Emphasize practical application with real-world examples. Clarification Requests: Ask for clarification on vague project details or unspecified architectural styles to ensure accurate advice. Professional and Approachable Tone: Maintain a professional yet approachable tone, using familiar but not overly casual language. Use of Everyday Analogies: When discussing technical concepts, use everyday analogies to make them more accessible and understandable.',
      selection = function() end,
    },
    LogicBuilder = {
      prompt = "",
      system_prompt =
      "I want you to act as a logic-building tool. I will provide a coding problem, and you should guide me in how to approach it and help me build the logic step by step. Please focus on giving hints and suggestions to help me think through the problem, and do not provide the solution.",
      selection = function() end,
    },
    RegexGenerator = {
      prompt = "",
      system_prompt =
      "I want you to act as a regex generator. Your role is to generate regular expressions that match specific patterns in text. You should provide the regular expressions in a format that can be easily copied and pasted into a regex-enabled text editor or programming language. Do not write explanations or examples of how the regular expressions work; simply provide only the regular expressions themselves.",
      selection = function() end,
    },
    CustomCommitter = {
      prompt =
        "> #gitlog\n\n> #git:staged\n\nUse gitlog as reference of the commit title format, if there are relevant commits found in gitlog, for example there are similar changes, please mention `correlated to commit` followed by the relevant short commit hash, if none found, just omit it, and then write the commit message for the current changes. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.",
    },
  },
  contexts = {
    file = {
      input = function(callback)
        local telescope = require("telescope.builtin")
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        telescope.find_files({
          attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              callback(selection[1])
            end)
            return true
          end,
        })
      end,
    },
    somefiles = {
      input = function(callback)
        local telescope = require("telescope.builtin")
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        telescope.find_files({
          attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
              local picker = action_state.get_current_picker(prompt_bufnr)
              local num_selections = #picker:get_multi_selection()
              if not num_selections or num_selections <= 1 then
                actions.add_selection(prompt_bufnr)
              end
              actions.send_selected_to_qflist(prompt_bufnr)
              local qf_items = vim.fn.getqflist()
              -- Extract filenames from quickfix items
              local filenames = {}
              for _, item in ipairs(qf_items) do
                table.insert(filenames, item.text)
              end
              local filename = table.concat(filenames, ";")
              callback(filename)
            end)
            return true
          end,
        })
      end,
      resolve = function(input, source)
        local context = require("CopilotChat.context")
        local notify = require("CopilotChat.notify")
        local utils = require("CopilotChat.utils")
        local async = require("plenary.async")

        notify.publish(notify.STATUS, "Scanning files")

        -- ----------------------------------------------------------------------------
        -- These are all from CopilotChat.context
        -- ----------------------------------------------------------------------------
        local NAME_TYPES = {
          "name",
          "identifier",
          "heading_content",
        }

        local OUTLINE_TYPES = {
          "local_function",
          "function_item",
          "arrow_function",
          "function_definition",
          "function_declaration",
          "method_definition",
          "method_declaration",
          "proc_declaration",
          "template_declaration",
          "macro_declaration",
          "constructor_declaration",
          "field_declaration",
          "class_definition",
          "class_declaration",
          "interface_definition",
          "interface_declaration",
          "record_declaration",
          "type_alias_declaration",
          "import_statement",
          "import_from_statement",
          "atx_heading",
          "list_item",
        }

        local OFF_SIDE_RULE_LANGUAGES = {
          "python",
          "coffeescript",
          "nim",
          "elm",
          "curry",
          "fsharp",
        }

        local function get_node_name(node, content)
          for _, name_type in ipairs(NAME_TYPES) do
            local name_field = node:field(name_type)
            if name_field and #name_field > 0 then
              return vim.treesitter.get_node_text(name_field[1], content)
            end
          end

          return nil
        end

        local function get_full_signature(start_row, start_col, lines)
          local start_line = lines[start_row + 1]
          local signature = vim.trim(start_line:sub(start_col + 1))

          -- Look ahead for opening brace on next line
          if not signature:match("{") and (start_row + 2) <= #lines then
            local next_line = vim.trim(lines[start_row + 2])
            if next_line:match("^{") then
              signature = signature .. " {"
            end
          end

          return signature
        end

        -- This function is from CopilotChat.context
        local function build_outline(content, filename, ft)
          local output = {
            filename = filename,
            filetype = ft,
            content = content,
          }

          local lang = vim.treesitter.language.get_lang(ft)
          local ok, parser = false, nil
          if lang then
            ok, parser = pcall(vim.treesitter.get_string_parser, content, lang)
          end
          if not ok or not parser then
            ft = string.gsub(ft, "react", "")
            ok, parser = pcall(vim.treesitter.get_string_parser, content, ft)
            if not ok or not parser then
              return output
            end
          end

          local root = parser:parse()[1]:root()
          local lines = vim.split(content, "\n")
          local symbols = {}
          local outline_lines = {}
          local depth = 0

          local function parse_node(node)
            local type = node:type()
            local is_outline = vim.tbl_contains(OUTLINE_TYPES, type)
            local start_row, start_col, end_row, end_col = node:range()

            if is_outline then
              depth = depth + 1
              local name = get_node_name(node, content)
              local signature_start = get_full_signature(start_row, start_col, lines)
              table.insert(outline_lines, string.rep("  ", depth) .. signature_start)

              -- Store symbol information
              table.insert(symbols, {
                name = name,
                signature = signature_start,
                type = type,
                start_row = start_row + 1,
                start_col = start_col + 1,
                end_row = end_row,
                end_col = end_col,
              })
            end

            for child in node:iter_children() do
              parse_node(child)
            end

            if is_outline then
              if not vim.tbl_contains(OFF_SIDE_RULE_LANGUAGES, ft) then
                local end_line = lines[end_row + 1]
                local signature_end = vim.trim(end_line:sub(1, end_col))
                table.insert(outline_lines, string.rep("  ", depth) .. signature_end)
              end
              depth = depth - 1
            end
          end

          parse_node(root)

          if #outline_lines > 0 then
            output.outline = table.concat(outline_lines, "\n")
            output.symbols = symbols
          end

          return output
        end

        local function get_file(filename, filetype)
          notify.publish(notify.STATUS, "Reading file " .. filename)

          local modified = utils.file_mtime(filename)
          if not modified then
            return nil
          end

          local cached = file_cache[filename]
          if cached and cached.modified >= modified then
            return cached.outline
          end

          local content = utils.read_file(filename)
          if content then
            local outline = build_outline(content, filename, filetype)
            file_cache[filename] = {
              outline = outline,
              modified = modified,
            }

            return outline
          end

          return nil
        end

        -- ----------------------------------------------------------------------------

        local files = {}
        for filename in input:gmatch("[^;]+") do
          table.insert(files, filename)
        end

        local out = {}

        -- Create selected file list in chunks
        local chunk_size = 100
        for i = 1, #files, chunk_size do
          local chunk = {}
          for j = i, math.min(i + chunk_size - 1, #files) do
            table.insert(chunk, files[j])
          end

          local chunk_number = math.floor(i / chunk_size)
          local chunk_name = chunk_number == 0 and "file_map" or "file_map" .. tostring(chunk_number)

          table.insert(out, {
            content = table.concat(chunk, "\n"),
            filename = chunk_name,
            filetype = "text",
          })
        end

        -- Get selected files content
        async.util.scheduler()
        files = vim.tbl_filter(
          function(file)
            return file.ft ~= nil
          end,
          vim.tbl_map(function(file)
            return {
              name = utils.filepath(file),
              ft = utils.filetype(file),
            }
          end, files)
        )

        for _, file in ipairs(files) do
          local file_data = get_file(file.name, file.ft)
          if file_data then
            table.insert(out, file_data)
          end
        end

        return out
      end,
    },
    gitlog = {
      description = "Include previous 10 commits' title",
      resolve = function(_, source)
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
        return {{
          content = out.stdout,
          filename = "gitlog",
          filetype = "gitcommit",
        }}
      end,
    },
  },
}

return M
