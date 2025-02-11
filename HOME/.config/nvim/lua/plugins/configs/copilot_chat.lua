local M = {}

M.opts = {
  model = "claude-3.5-sonnet",
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
      insert = "<C-c>",
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
      "Explain the given words with pronounciation, translation to English and its explanation, translation to Chinese and its explanation, translation to Japanese and its explanation. Also provide list of examples using the words in sentences, along with synonyms and their pronounciation, antonyms and their pronounciation, all in English, Chinese, Japanese and in different contexts respectively. Return the result for each language in its own section.\n\n",
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
      "Using Llama-3.3-70b, you are a highly skilled multilingual expert that corrects grammatical errors in given text and provides a brief explanation of the changes made. You will receive a sentence or paragraph as input. Only correct grammar, spelling, punctuation, and word choice, do not change the meaning of the original text. Return the corrected version, followed by a short explanation of the corrections. Also provide different options of the tones addressing the same meaning.",
      description = "Fix grammar",
      agent = "models",
      selection = function(source)
        return require("CopilotChat.select").visual(source)
      end,
    },
  },
}

return M
