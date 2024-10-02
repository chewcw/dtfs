local utils_comment = require("core.utils_comment")

-- n, v, i, t = mode names

local M = {}

M.general = {
  i = {
    -- navigate within insert mode
    ["<A-h>"] = {
      function()
        require("core.utils").insert_mode_movement_disable_auto_completions("Left")
      end,
      "move left",
      opts = { silent = true },
    },
    ["<A-l>"] = {
      function()
        require("core.utils").insert_mode_movement_disable_auto_completions("Right")
      end,
      "move right",
      opts = { silent = true },
    },
    ["<A-j>"] = {
      function()
        require("core.utils").insert_mode_movement_disable_auto_completions("Down")
      end,
      "move down",
      opts = { silent = true },
    },
    ["<A-k>"] = {
      function()
        require("core.utils").insert_mode_movement_disable_auto_completions("Up")
      end,
      "move up",
      opts = { silent = true },
    },
    ["<A-w>"] = {
      function()
        require("core.utils").insert_mode_movement_disable_auto_completions("C-Right")
      end,
      "move next word",
      opts = { silent = true },
    },
    ["<A-b>"] = {
      function()
        require("core.utils").insert_mode_movement_disable_auto_completions("C-Left")
      end,
      "move previous word",
      opts = { silent = true },
    },

    -- tab
    ["<A-S-t>"] = { "<cmd> tabedit <CR> <Esc>", "new tab" },
    -- ["<A-S-w>"] = { "<cmd> tabclose <CR> <Esc>", "close tab" },
    -- ["<A-S-w>"] = {
    --   "<cmd> bprevious|bdelete!#<CR> <cmd> tabclose <CR> <Esc>",
    --   "delete buffer from buffer list and close tab",
    -- },
    ["<A-S-w>"] = {
      ":lua require('plugins.configs.buffer_utils').force_delete_buffer_switch_to_previous() <CR>",
      "close the buffer but keep the window",
      opts = { silent = true },
    },
    ["<A-S-d>"] = {
      ":lua require('plugins.configs.buffer_utils').force_delete_buffer_switch_to_previous() <CR>",
      "close the buffer but keep the window",
      opts = { silent = true },
    },
    -- ["<A-S-d>"] = {
    --   "<cmd> :lua require('plugins.configs.telescope_utils').delete_and_select_old_buffer() <CR>",
    --   "delete the buffer and select the old buffer",
    -- },
    ["<A-S-h>"] = { "<cmd> tabprevious <CR> <Esc>", "previous tab", opts = { silent = true } },
    ["<A-S-l>"] = { "<cmd> tabnext <CR> <Esc>", "next tab", opts = { silent = true } },
    ["<A-S-j>"] = {
      "<cmd> :lua require('plugins.configs.buffer_utils').switch_to_next_buffer_in_cwd() <CR>",
      "previous buffer",
      opts = { silent = true },
    },
    ["<A-S-k>"] = {
      "<cmd> :lua require('plugins.configs.buffer_utils').switch_to_previous_buffer_in_cwd() <CR>",
      "next previous",
      opts = { silent = true },
    },

    -- ["<C-n>"] = { "" }, -- unmap this
    ["<C-]>"] = { "<Esc>", "esc" }, -- i always press the wrong key

    -- should I map this, this leave probably here for future reference?
    -- https://vim.fandom.com/wiki/Prevent_escape_from_moving_the_cursor_one_character_to_the_left
    -- ["<Esc>"] = { "<C-O>:stopinsert<CR>" },
    -- This seems like autocomplete, disable this
    ["<C-n>"] = { "" },
    -- This seems like autocomplete, disable this
    ["<C-p>"] = { "" },
  },

  n = {
    ["<leader>n"] = { "<cmd> :lua require('core.utils').toggle_search_highlight() <CR>", "toggle highlights" },

    -- because of core.utils.toggle_search_highlight function, normal search using following
    -- mappings may not have highlights shown, because it has been toggled off, so
    -- these mappings made sure hlsearch will always be on.
    ["*"] = { "*:lua vim.o.hlsearch = true<CR>", "", opts = { silent = true } },
    ["#"] = { "#:lua vim.o.hlsearch = true<CR>", "", opts = { silent = true } },
    ["g*"] = { "g*:lua vim.o.hlsearch = true<CR>", "", opts = { silent = true } },
    ["g#"] = { "g#:lua vim.o.hlsearch = true<CR>", "", opts = { silent = true } },
    ["n"] = { "n:lua vim.o.hlsearch = true<CR>", "", opts = { silent = true } },
    ["N"] = { "N:lua vim.o.hlsearch = true<CR>", "", opts = { silent = true } },

    -- ["<C-e>"] = {
    --   function()
    --     local result = vim.treesitter.get_captures_at_cursor(0)
    --     print(vim.inspect(result))
    --   end,
    --   "get highlight group under cursor",
    -- },

    -- switch between windows
    ["<C-h>"] = { "<C-w>h", "window left" },
    ["<C-l>"] = { "<C-w>l", "window right" },
    ["<C-j>"] = { "<C-w>j", "window down" },
    ["<C-k>"] = { "<C-w>k", "window up" },

    -- Copy all
    ["<C-A-c>"] = { "<cmd> %y+ <CR>", "copy whole file" },

    -- line numbers
    ["<leader>ln"] = { "<cmd> set nu! <CR>", "toggle line number" },
    ["<leader>lr"] = { "<cmd> set rnu! <CR>", "toggle relative number" },

    -- listchars symbol
    ["<leader>ll"] = {
      "<cmd> :lua require('plugins.configs.buffer_utils').toggle_listchars_symbol() <CR>",
      "toggle listchars symbol",
    },
    -- newline symbol
    ["<leader>le"] = {
      "<cmd> :lua require('plugins.configs.buffer_utils').toggle_newline_symbol() <CR>",
      "toggle newline symbol",
    },

    -- Allow moving the cursor through wrapped lines with j, k, <Up> and <Down>
    -- http://www.reddit.com/r/vim/comments/2k4cbr/problem_with_gj_and_gk/
    -- empty mode is same as using <cmd> :map
    -- also don't use g[j|k] when in operator pending mode, so it doesn't alter d, y or c behaviour
    -- ["j"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', "move down", opts = { expr = true } },
    -- ["k"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', "move up", opts = { expr = true } },
    -- ["<Up>"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', "move up", opts = { expr = true } },
    -- ["<Down>"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', "move down", opts = { expr = true } },

    -- mark as jump point if moving more than 1 line
    -- https://superuser.com/a/539836
    ["j"] = { '(v:count > 1 ? "m\'" . v:count : "") . "j"', "move down", opts = { expr = true } },
    ["k"] = { '(v:count > 1 ? "m\'" . v:count : "") . "k"', "move up", opts = { expr = true } },
    ["<Down>"] = { '(v:count > 1 ? "m\'" . v:count : "") . "j"', "move down", opts = { expr = true } },
    ["<Up>"] = { '(v:count > 1 ? "m\'" . v:count : "") . "k"', "move up", opts = { expr = true } },

    -- new buffer
    ["<leader>bn"] = { "<cmd> enew <CR>", "new buffer" },
    ["<leader>b\\"] = { "<cmd> vnew <CR>", "new buffer" },
    ["<leader>b_"] = { "<cmd> new <CR>", "new buffer" },

    -- toggle last opened buffer
    -- use inkarkat/vim-EnhancedJumps
    -- see https://github.com/inkarkat/vim-EnhancedJumps
    -- ["<A-p>"] = { "<C-6>", "toggle last opened buffer" },
    ["<S-Tab>"] = { "<C-6>", "toggle last opened buffer" },

    -- marks
    ["<leader>m"] = { ':delmarks a-zA-Z0-9"^.[] <CR>', "delete all marks" },

    -- split
    ["<C-A-\\>"] = {
      "<cmd> :lua require('plugins.configs.telescope_utils').open_new_split_and_select_buffer('vertical') <CR>",
      "open new vsplit",
    },
    ["<A-\\>"] = { ":vsplit <CR>", "split vertically" },
    ["<C-A-_>"] = {
      "<cmd> :lua require('plugins.configs.telescope_utils').open_new_split_and_select_buffer('horizontal') <CR>",
      "open new split and select buffer",
    },
    ["<A-_>"] = { ":split <CR>", "split horizontally" },
    ["<A-=>"] = { ":resize +5 <CR>", "resize horizontally" },
    ["<A-->"] = { ":resize -5 <CR>", "resize horizontally" },
    ["<A-]>"] = { ":vertical resize +5 <CR>", "resize vertically" },
    ["<A-[>"] = { ":vertical resize -5 <CR>", "resize vertically" },

    -- macro
    ["|"] = { "@@", "repeat last called macro" },

    -- tab
    ["<A-S-e>"] = { ":tabedit <CR>", "new tab" },
    -- ["<A-S-w>"] = { "<cmd> bprevious|bdelete!#<CR> <cmd> tabclose <CR> <Esc>", "delete buffer from buffer list and close tab" },
    -- ["<A-S-d>"] = { "<cmd> :lua require('plugins.configs.telescope_utils').delete_and_select_old_buffer() <CR>", "delete the buffer and select the old buffer" },
    ["<A-S-w>"] = {
      ":lua require('plugins.configs.buffer_utils').force_delete_buffer_switch_to_previous() <CR>",
      "delete the buffer",
      opts = { silent = true },
    },
    ["<A-S-d>"] = {
      ":lua require('plugins.configs.buffer_utils').force_delete_buffer_switch_to_previous() <CR>",
      "delete the buffer",
      opts = { silent = true },
    },
    ["<A-S-h>"] = { ":tabprevious <CR>", "previous tab", opts = { silent = true } },
    ["<A-S-l>"] = { ":tabnext <CR>", "next tab", opts = { silent = true } },
    ["<A-S-j>"] = {
      "<cmd> :lua require('plugins.configs.buffer_utils').switch_to_next_buffer_in_cwd() <CR>",
      "previous buffer",
    },
    ["<A-S-k>"] = {
      "<cmd> :lua require('plugins.configs.buffer_utils').switch_to_previous_buffer_in_cwd() <CR>",
      "next previous",
    },
    -- normally if I run :tabclose, next tab will be focused, this keymap overrides
    -- it and focus on previous tab instead
    ["<C-e>c"] = { "<cmd> :lua require('core.utils').close_and_focus_previous_tab() <CR>", "close current tab" },
    ["<C-e>o"] = { ":tabonly <CR>", "close other tab" },
    -- open new tab and select buffer
    ["<C-A-e>"] = {
      "<cmd> :lua require('plugins.configs.telescope_utils').open_new_tab_and_select_buffer('vertical') <CR>",
      "open new tab",
    },

    -- link
    ["gx"] = { ":execute '!xdg-open ' .. shellescape(expand('<cfile>'), v:true)<CR><CR>", "open link" },

    -- wrap
    ["<leader>lww"] = {
      function()
        local current_win = vim.api.nvim_get_current_win()
        local wrap = vim.api.nvim_get_option_value("wrap", { win = current_win })
        vim.api.nvim_set_option_value("wrap", not wrap, { win = current_win })
        -- Notification
        local onoff = vim.api.nvim_get_option_value("wrap", { win = current_win })
        vim.notify("Wrap for current window is now " .. tostring(onoff))
      end,
      "toggle line wrapping",
    },
    ["<leader>lwt"] = {
      function()
        require("core.utils_window").save_window_sizes_and_restore(function()
          local current_win = vim.api.nvim_get_current_win()
          -- Get the current window's wrap setting
          local wrap = vim.api.nvim_get_option_value("wrap", { win = current_win })
          -- Get the current tabpage
          local current_tabpage = vim.api.nvim_get_current_tabpage()
          -- Iterate over all windows in current tab
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(current_tabpage)) do
            -- Get the iterated window's wrap setting
            local win_wrap = vim.api.nvim_get_option_value("wrap", { win = win })
            if win_wrap == wrap then
              vim.api.nvim_set_option_value("wrap", not win_wrap, { win = win })
            end
          end
          -- Notification
          local onoff = vim.api.nvim_get_option_value("wrap", { win = current_win })
          vim.notify("Wrap for all windows is now " .. tostring(onoff))
          vim.api.nvim_set_current_win(current_win)
        end)
      end,
      "toggle line wrapping for all windows in this tab",
    },
    ["<leader>lwa"] = {
      function()
        require("core.utils_window").save_window_sizes_and_restore(function()
          local current_win = vim.api.nvim_get_current_win()
          -- Get the current window's wrap setting
          local wrap = vim.api.nvim_get_option_value("wrap", { win = current_win })
          -- Iterate over all tabpages
          for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
            -- Iterate over all windows in the current tabpage
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
              -- Get the current window's wrap setting
              local win_wrap = vim.api.nvim_get_option_value("wrap", { win = win })
              if win_wrap == wrap then
                vim.api.nvim_set_option_value("wrap", not win_wrap, { win = win })
              end
            end
          end
          -- Notification
          local onoff = vim.api.nvim_get_option_value("wrap", { win = current_win })
          vim.notify("Wrap for all windows in all tabs is now " .. tostring(onoff))
          vim.api.nvim_set_current_win(current_win)
        end)
      end,
      "toggle line wrapping for all windows in all tabs",
    },

    -- cursor column
    ["<leader>lsw"] = {
      function()
        local current_win = vim.api.nvim_get_current_win()
        local cursor_column = vim.api.nvim_get_option_value("cursorcolumn", { win = current_win })
        vim.api.nvim_set_option_value("cursorcolumn", not cursor_column, { win = current_win })
        -- set virtualedit
        local cursor_column = vim.api.nvim_get_option_value("cursorcolumn", { win = current_win })
        if cursor_column then
          vim.opt.virtualedit = "all"
        else
          vim.opt.virtualedit = "insert,block"
        end
        -- Notification
        local onoff = vim.api.nvim_get_option_value("cursorline", { win = current_win })
        vim.notify("Cursorcolumn for this window is now " .. tostring(onoff))
      end,
      "toggle cursor column",
    },
    ["<leader>lst"] = {
      function()
        require("core.utils_window").save_window_sizes_and_restore(function()
          local current_win = vim.api.nvim_get_current_win()
          -- Get the current window's cursorcolumn setting
          local cursorcolumn = vim.api.nvim_get_option_value("cursorcolumn", { win = current_win })
          -- Get the current tabpage
          local current_tabpage = vim.api.nvim_get_current_tabpage()
          -- Iterate over all windows in current tab
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(current_tabpage)) do
            -- Get the iterated window's cursorcolumn setting
            local win_cursorcolumn = vim.api.nvim_get_option_value("cursorcolumn", { win = win })
            if win_cursorcolumn == cursorcolumn then
              vim.api.nvim_set_option_value("cursorcolumn", not win_cursorcolumn, { win = win })
            end
          end
          -- set virtualedit
          local cursor_column = vim.api.nvim_get_option_value("cursorcolumn", { win = current_win })
          if cursor_column then
            vim.opt.virtualedit = "all"
          else
            vim.opt.virtualedit = "insert,block"
          end
          -- Notification
          local onoff = vim.api.nvim_get_option_value("cursorcolumn", { win = current_win })
          vim.notify("Cursorcolumn for all windows is now " .. tostring(onoff))
          vim.api.nvim_set_current_win(current_win)
        end)
      end,
      "toggle cursorcolumn for all windows in this tab",
    },
    ["<leader>lsa"] = {
      function()
        require("core.utils_window").save_window_sizes_and_restore(function()
          local current_win = vim.api.nvim_get_current_win()
          -- Get the current window's cursorcolumn setting
          local cursorcolumn = vim.api.nvim_get_option_value("cursorcolumn", { win = current_win })
          -- Iterate over all tabpages
          for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
            -- Iterate over all windows in the current tabpage
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
              -- Get the current window's cursorcolumn setting
              local win_cursorcolumn = vim.api.nvim_get_option_value("cursorcolumn", { win = win })
              if win_cursorcolumn == cursorcolumn then
                vim.api.nvim_set_option_value("cursorcolumn", not win_cursorcolumn, { win = win })
              end
            end
          end
          -- set virtualedit
          local cursor_column = vim.api.nvim_get_option_value("cursorcolumn", { win = current_win })
          if cursor_column then
            vim.opt.virtualedit = "all"
          else
            vim.opt.virtualedit = "insert,block"
          end
          -- Notification
          local onoff = vim.api.nvim_get_option_value("cursorcolumn", { win = current_win })
          vim.notify("Cursorcolumn for all windows in all tabs is now " .. tostring(onoff))
          vim.api.nvim_set_current_win(current_win)
        end)
      end,
      "toggle cursorcolumn for all windows in all tabs",
    },

    -- undotree
    ["<leader>uu"] = { ":UndotreeToggle <CR> :UndotreeFocus <CR>", "toggle undotree" },
    ["<leader>uf"] = { ":UndotreeFocus <CR>", "focus undotree" },

    -- color column
    ["<leader>lmw"] = {
      function()
        local current_win = vim.api.nvim_get_current_win()
        local colorcolumn = vim.api.nvim_get_option_value("colorcolumn", { win = current_win })
        if colorcolumn == "0" then
          vim.api.nvim_set_option_value("colorcolumn", "85", { win = current_win })
        else
          vim.api.nvim_set_option_value("colorcolumn", "0", { win = current_win })
        end
        -- Notification
        local onoff = vim.api.nvim_get_option_value("colorcolumn", { win = current_win })
        vim.notify("Colorcolumn for current window is now " .. onoff)
      end,
      "toggle colorcolumn for this window",
    },
    ["<leader>lmt"] = {
      function()
        require("core.utils_window").save_window_sizes_and_restore(function()
          local current_win = vim.api.nvim_get_current_win()
          -- Get the current window's colorcolumn setting
          local colorcolumn = vim.api.nvim_get_option_value("colorcolumn", { win = current_win })
          -- Get the current tabpage
          local current_tabpage = vim.api.nvim_get_current_tabpage()
          -- Iterate over all windows in current tab
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(current_tabpage)) do
            -- Get the iterated window's colorcolumn setting
            local win_colorcolumn = vim.api.nvim_get_option_value("colorcolumn", { win = win })
            if win_colorcolumn == colorcolumn then
              if colorcolumn == "0" then
                vim.api.nvim_set_option_value("colorcolumn", "85", { win = win })
              else
                vim.api.nvim_set_option_value("colorcolumn", "0", { win = win })
              end
            end
          end
          -- Notification
          local onoff = vim.api.nvim_get_option_value("colorcolumn", { win = current_win })
          vim.notify("Colorcolumn for all windows is now " .. tostring(onoff))
          vim.api.nvim_set_current_win(current_win)
        end)
      end,
      "toggle colorcolumn for all windows in this tab",
    },
    ["<leader>lma"] = {
      function()
        require("core.utils_window").save_window_sizes_and_restore(function()
          local current_win = vim.api.nvim_get_current_win()
          -- Get the current window's colorcolumn setting
          local colorcolumn = vim.api.nvim_get_option_value("colorcolumn", { win = current_win })
          -- Iterate over all tabpages
          for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
            -- Iterate over all windows in the current tabpage
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
              -- Get the iterated window's colorcolumn setting
              local win_colorcolumn = vim.api.nvim_get_option_value("colorcolumn", { win = win })
              if win_colorcolumn == colorcolumn then
                if colorcolumn == "0" then
                  vim.api.nvim_set_option_value("colorcolumn", "85", { win = win })
                else
                  vim.api.nvim_set_option_value("colorcolumn", "0", { win = win })
                end
              end
            end
          end
          -- Notification
          local onoff = vim.api.nvim_get_option_value("colorcolumn", { win = current_win })
          vim.notify("Colorcolumn for all windows is now " .. tostring(onoff))
          vim.api.nvim_set_current_win(current_win)
        end)
      end,
      "toggle colorcolumn for all windows in all tabs",
    },

    -- cursor line
    ["<leader>lcw"] = {
      function()
        require("core.utils_window").save_window_sizes_and_restore(function()
          local current_win = vim.api.nvim_get_current_win()
          -- Get the current window's cursorlineopt setting
          local cursorlineopt = vim.api.nvim_get_option_value("cursorlineopt", { win = current_win })
          if cursorlineopt == "both" then
            vim.api.nvim_set_option_value("cursorline", true, { win = current_win })
            vim.api.nvim_set_option_value("cursorlineopt", "number", { win = current_win })
          else
            vim.api.nvim_set_option_value("cursorline", true, { win = current_win })
            vim.api.nvim_set_option_value("cursorlineopt", "both", { win = current_win })
          end
          -- Notification
          local onoff = vim.api.nvim_get_option_value("cursorlineopt", { win = current_win })
          vim.notify("Cursorline for this window is now " .. onoff)
          vim.api.nvim_set_current_win(current_win)
        end)
      end,
      "toggle cursorline for this window",
    },
    ["<leader>lct"] = {
      function()
        require("core.utils_window").save_window_sizes_and_restore(function()
          local current_win = vim.api.nvim_get_current_win()
          -- Get the current window's cursorlineopt setting
          local cursorlineopt = vim.api.nvim_get_option_value("cursorlineopt", { win = current_win })
          -- Get the current tabpage
          local current_tabpage = vim.api.nvim_get_current_tabpage()
          -- Iterate over all windows in current tab
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(current_tabpage)) do
            -- Get the iterated window's cursorlineopt setting
            local win_cursorlineopt = vim.api.nvim_get_option_value("cursorlineopt", { win = win })
            if win_cursorlineopt == cursorlineopt then
              if cursorlineopt == "both" then
                vim.api.nvim_set_option_value("cursorline", true, { win = win })
                vim.api.nvim_set_option_value("cursorlineopt", "number", { win = win })
              else
                vim.api.nvim_set_option_value("cursorline", true, { win = win })
                vim.api.nvim_set_option_value("cursorlineopt", "both", { win = win })
              end
            end
          end
          -- Notification
          local onoff = vim.api.nvim_get_option_value("cursorlineopt", { win = current_win })
          vim.notify("Cursorline for all windows is now " .. onoff)
          vim.api.nvim_set_current_win(current_win)
        end)
      end,
      "toggle cursorline all windows in this tab",
    },
    ["<leader>lca"] = {
      function()
        require("core.utils_window").save_window_sizes_and_restore(function()
          local current_win = vim.api.nvim_get_current_win()
          -- Get the current window's cursorlineopt setting
          local cursorlineopt = vim.api.nvim_get_option_value("cursorlineopt", { win = current_win })
          -- Get the current tabpage
          local current_tabpage = vim.api.nvim_get_current_tabpage()
          -- Iterate over all tabpages
          for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
            -- Iterate over all windows in the current tabpage
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
              -- Get the iterated window's cursorlineopt setting
              local win_cursorlineopt = vim.api.nvim_get_option_value("cursorlineopt", { win = win })
              if win_cursorlineopt == cursorlineopt then
                if cursorlineopt == "both" then
                  vim.api.nvim_set_option_value("cursorline", true, { win = win })
                  vim.api.nvim_set_option_value("cursorlineopt", "number", { win = win })
                else
                  vim.api.nvim_set_option_value("cursorline", true, { win = win })
                  vim.api.nvim_set_option_value("cursorlineopt", "both", { win = win })
                end
              end
            end
          end
          -- Notification
          local onoff = vim.api.nvim_get_option_value("cursorlineopt", { win = current_win })
          vim.notify("Cursorline for all windows in all tabs is now " .. onoff)
          vim.api.nvim_set_current_win(current_win)
        end)
      end,
      "toggle cursorline for all windows in all tabs",
    },

    -- write comment
    ["<leader>ch"] = { utils_comment.insert_comment_with_trails, "write comment with trails" },
    ["<leader>cs"] = { utils_comment.insert_comment_with_solid_line, "write comment with solid line" },
    ["<leader>cH"] = { utils_comment.insert_comment_with_header, "write comment with header" },

    -- split window max out width and height
    ["<C-w>f"] = { "<C-w>|<C-w>_", "make split window max out width and height" },

    -- toggle indentation between 2 and 4 spaces
    ["g4"] = {
      function()
        require("core.utils_window").save_window_sizes_and_restore(function()
          local current_win = vim.api.nvim_get_current_win()
          vim.cmd([[windo set shiftwidth=4]])
          vim.cmd([[windo set tabstop=4]])
          vim.cmd([[windo set softtabstop=4]])
          print("tab is 4 spaces now")
          vim.api.nvim_set_current_win(current_win)
        end)
      end,
      "indentation 4 spaces",
    },
    ["g2"] = {
      function()
        require("core.utils_window").save_window_sizes_and_restore(function()
          local current_win = vim.api.nvim_get_current_win()
          vim.cmd([[windo set shiftwidth=2]])
          vim.cmd([[windo set tabstop=2]])
          vim.cmd([[windo set softtabstop=2]])
          print("tab is 2 spaces now")
          vim.api.nvim_set_current_win(current_win)
        end)
      end,
      "indentation 2 spaces",
    },
    -- ["g."] = {
    --   function()
    --     if vim.opt.shiftwidth:get() == 2 and vim.opt.tabstop:get() == 2 and vim.opt.softtabstop:get() == 2 then
    --       vim.cmd([[bufdo set shiftwidth=4]])
    --       vim.cmd([[bufdo set tabstop=4]])
    --       vim.cmd([[bufdo set softtabstop=4]])
    --       print("tab is 4 spaces now")
    --     else
    --       vim.cmd([[bufdo set shiftwidth=2]])
    --       vim.cmd([[bufdo set tabstop=2]])
    --       vim.cmd([[bufdo set softtabstop=2]])
    --       print("tab is 2 spaces now")
    --     end
    --   end,
    --   "toggle indentation between 3 and 4 spaces",
    -- },

    -- https://stackoverflow.com/questions/25101915/vim-case-insensitive-ex-command-completion
    -- ["/"] = { "/\\C", "search without case sensitive" },
    -- ["/"] = {
    -- function()
    -- local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    -- vim.api.nvim_buf_set_text(0, row, col, row, col, {"/\\C"})
    -- vim.api.nvim_buf_set_text(0, 0, 0, 0, 0, {"/\\C"})
    -- vim.api.nvim_buf_set_text(0, 0, 1, 0, 1, {""})
    -- "/\\C"
    -- end,
    -- (function()
    --   -- vim.api.nvim_win_set_cursor(0, { 0, 0})
    --   local text = "/\\C"
    --   return text
    --   vim.cmd("norm! hh")
    -- end)(),
    -- "/\\C",
    -- "search without case sensitive" },
    ["<leader>r"] = { ":%s/", "replace in normal mode" },
    ["<leader>s"] = { "/\\%V", "search in last visual selection" },
    ["<leader>e"] = { ":e! <CR>", "e!" },
    ["<leader>q"] = { ":q! <CR>", "q!" },
    ["<C-A-l>"] = { ":tabmove +1 <CR>", opts = { silent = true } },
    -- ["<C-A-l>"] = {
    --   "<cmd> :lua require('plugins.configs.buffer_utils').navigate_to_next_buffer() <CR>",
    --   "goto previous buffer",
    -- },
    ["<C-A-h>"] = { ":tabmove -1 <CR>", opts = { silent = true } },
    -- ["<C-A-h>"] = {
    --   "<cmd> :lua require('plugins.configs.buffer_utils').navigate_to_previous_buffer() <CR>",
    --   "goto next buffer",
    -- },
    ["<C-A-w>"] = {
      ":lua require('plugins.configs.buffer_utils').force_delete_buffer_switch_to_previous() <CR>",
      "close the buffer but keep the window",
      opts = { silent = true },
    },
    -- ["<C-A-d>"] = { "<cmd> bwipeout! <CR>", "wipe out the buffer from buffer list" },
    ["<C-A-d>"] = {
      ":lua require('plugins.configs.buffer_utils').force_delete_buffer_switch_to_previous() <CR>",
      "close the buffer but keep the window",
      opts = { silent = true },
    },

    -- https://vim.fandom.com/wiki/Swapping_characters,_words_and_lines
    ["gL"] = { '"_yiw:s/\\(\\%#\\w\\+\\)\\(\\W\\+\\)\\(\\w\\+\\)/\\3\\2\\1/<CR>``:redraw<CR>:nohlsearch<CR>' },
    ["gH"] = {
      '"_yiw?\\w\\+\\_W\\+\\%#<CR>:s/\\(\\%#\\w\\+\\)\\(\\_W\\+\\)\\(\\w\\+\\)/\\3\\2\\1/<CR>``:redraw<CR>:nohlsearch<CR>',
    },

    -- https://stackoverflow.com/a/1269631
    -- ["<C-w>th"] = { "<C-w>K", "switch from vertical split to horizontal split" },
    -- ["<C-w>tv"] = { "<C-w>H", "switch from horizontal split to vertical split" },

    -- for Git related nvimdiff
    ["<leader>gl"] = { ":diffget LOCAL <CR>", "diffget from local" },
    ["<leader>gr"] = { ":diffget REMOTE <CR>", "diffget from remote" },
    ["<leader>gs"] = { ":diffget BASE <CR>", "diffget from base" },
    ["<leader>gq"] = { ":cq <CR>", "cquit" },

    -- gf open in new tab
    -- ["gF"] = { "<C-w>gf", "open file in new tab" },

    -- overloads
    ["<C-s>"] = { ":LspOverloadsSignature<CR>", "show function overloads" },

    ["gV"] = { "`[v`]", "select last pasted content" }, --https://stackoverflow.com/a/4313335
    ["gv"] = { "`<v`>", "select last selected content" },

    ["]q"] = { ":cnext<CR>", "select next item in the quickfix list" },
    ["[q"] = { ":cprevious<CR>", "select previous item in the quickfix list" },
    ["]l"] = { ":lnext<CR>", "select next item in the location list" },
    ["[l"] = { ":lprevious<CR>", "select previous item in the location list" },
    ["]e"] = {
      ":lua require('core.utils').swap_line_with_below(vim.v.count1)<CR>",
      "exchange the current line with [count] lines below it",
    },
    ["[e"] = {
      ":lua require('core.utils').swap_line_with_above(vim.v.count1)<CR>",
      "exchange the current line with [count] lines above it",
    },
    ["]w"] = {
      ":lua require('core.utils').move_line(vim.v.count1, 'down')<CR>",
      "move the current line with [count] lines below it",
    },
    ["[w"] = {
      ":lua require('core.utils').move_line(vim.v.count1, 'up')<CR>",
      "move the current line with [count] lines above it",
    },
    ["[<Space>"] = {
      ":lua require('core.utils').blank_up(vim.v.count1)<CR>",
      "Add [count] blank lines above the cursor",
    },
    ["]<Space>"] = {
      ":lua require('core.utils').blank_down(vim.v.count1)<CR>",
      "Add [count] blank lines below the cursor",
    },
    ["[t"] = {
      function()
        if pcall(require, "treesitter-context") then
          require("treesitter-context").go_to_context(vim.v.count1)
        end
      end,
      "Jump to treesitter context (upwards)",
      { opts = { silent = true } },
    },
    ["g<CR>"] = {
      "<cmd> :lua require('core.utils').search_word_under_cursor() <CR>",
      "Search current word, but not move the cursor",
    },

    ["<C-w><C-h>"] = { "<C-w>h|<C-w>|", "switch to left window and maximize it horizontally" },
    ["<C-w><C-l>"] = { "<C-w>l|<C-w>|", "switch to right window and maximize it horizontally" },
    ["<C-w><C-k>"] = { "<C-w>k|<C-w>_", "switch to top window and maximize it vertically" },
    ["<C-w><C-j>"] = { "<C-w>j|<C-w>_", "switch to bottom window and maximize it vertically" },

    ["<A-e>"] = { "<cmd> BufferLinePick <CR>", "bufferline pick" },
    ["<A-Tab>"] = {
      ":lua require('plugins.configs.telescope_tabs').go_to_previous() <CR>",
      "go to previous opened tab",
      opts = { silent = true },
    },

    ["<C-r>"] = {
      ":lua require('plugins.configs.buffer_utils').run_git_related_when_the_buffer_name_matches() <CR>",
      "Reload Gll",
      opts = { silent = true },
    },

    ["<leader>M"] = {
      function()
        local buf_nr = vim.api.nvim_get_current_buf()
        local buf_name = vim.api.nvim_buf_get_name(buf_nr)
        if buf_name:match("MINIMAP") then
          pcall(function()
            vim.cmd("MinimapClose")
          end)
        else
          pcall(function()
            vim.cmd("MinimapToggle")
          end)
        end
      end,
      "Toggle minimap",
    },

    ["<A-w>"] = {
      ":lua require('plugins.configs.buffer_utils').focus_window_by_selecting_it() <CR>",
      "Focus window by selecting it",
    },
  },

  v = {
    ["<Up>"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', "move up", opts = { expr = true } },
    ["<Down>"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', "move down", opts = { expr = true } },
    ["<leader>r"] = { ":s/\\%V", "replace in visual mode" },
    -- https://vim.fandom.com/wiki/Swapping_characters,_words_and_lines
    ["<C-x>"] = { '<Esc>`.``gv"*d"-P``"*P' },
    -- switch between windows
    ["<C-h>"] = { "<C-w>h", "window left" },
    ["<C-l>"] = { "<C-w>l", "window right" },
    ["<C-j>"] = { "<C-w>j", "window down" },
    ["<C-k>"] = { "<C-w>k", "window up" },

    -- for Git related nvimdiff
    ["<leader>gl"] = { ":diffget LOCAL <CR>", "diffget from local" },
    ["<leader>gr"] = { ":diffget REMOTE <CR>", "diffget from remote" },
    ["<leader>gs"] = { ":diffget BASE <CR>", "diffget from base" },
    ["<leader>gq"] = { ":cq <CR>", "cquit" },

    ["g<CR>"] = {
      "<cmd> :lua require('core.utils').search_visual_selection() <CR>",
      "Search selected words in visual mode",
    },

    ["<leader>s"] = { "<Esc>/\\%V", "search in visual selection" },
  },

  x = {
    ["j"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', "move down", opts = { expr = true } },
    ["k"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', "move up", opts = { expr = true } },
    -- Don't copy the replaced text after pasting in visual mode
    -- https://vim.fandom.com/wiki/Replace_a_word_with_yanked_text#Alternative_mapping_for_paste
    ["p"] = { 'p:let @+=@0<CR>:let @"=@0<CR>', "dont copy replaced text", opts = { silent = true } },
  },

  c = {
    -- navigate within command mode
    ["<A-h>"] = {
      function()
        require("core.utils").insert_mode_movement_disable_auto_completions("Left")
      end,
      "move left",
      opts = { silent = true },
    },
    ["<A-l>"] = {
      function()
        require("core.utils").insert_mode_movement_disable_auto_completions("Right")
      end,
      "move right",
      opts = { silent = true },
    },
    ["<A-j>"] = {
      function()
        require("core.utils").insert_mode_movement_disable_auto_completions("Down")
      end,
      "move down",
      opts = { silent = true },
    },
    ["<A-k>"] = {
      function()
        require("core.utils").insert_mode_movement_disable_auto_completions("Up")
      end,
      "move up",
      opts = { silent = true },
    },
    ["<A-w>"] = {
      function()
        require("core.utils").insert_mode_movement_disable_auto_completions("C-Right")
      end,
      "move next word",
      opts = { silent = true },
    },
    ["<A-b>"] = {
      function()
        require("core.utils").insert_mode_movement_disable_auto_completions("C-Left")
      end,
      "move previous word",
      opts = { silent = true },
    },
    ["<A-\\>"] = {
      function()
        pcall(function()
          local last_command = vim.fn.getcmdline()
          local modified_command = ":vertical " .. last_command
          if last_command:find("^" .. "Gll") ~= nil then
            pcall(function()
              vim.g.gll_reload_manually_or_open_new = true
              vim.cmd("vnew") -- open vsplit
              vim.cmd(modified_command)
              vim.cmd("wincmd k")
              local dummy_bufnr = vim.api.nvim_get_current_buf()
              vim.cmd("wincmd q")
              vim.api.nvim_input("<Esc>")
              vim.cmd("bdelete! " .. dummy_bufnr)
            end)
            return
          end
          if last_command:find("^" .. "Redir G") ~= nil then
            local args = last_command:gsub("^Redir ", "")
            require("core.utils_redir").nredir(args, "vertical")
            vim.cmd("wincmd k")
            local dummy_bufnr = vim.api.nvim_get_current_buf()
            vim.cmd("wincmd q")
            vim.api.nvim_input("<Esc>")
            vim.cmd("bdelete! " .. dummy_bufnr)
            return
          end
          if last_command:find("^" .. "Redir") ~= nil then
            local args = last_command:gsub("^Redir ", "")
            require("core.utils_redir").nredir(args, "vertical")
            vim.api.nvim_input("<Esc>")
            return
          end
          if not pcall(function()
                vim.cmd(modified_command)
              end) then
            vim.cmd(last_command)
          end
          vim.api.nvim_input("<Esc>")
        end)
      end,
      "add `vertical` to the beginning of the command to open in vertical mode",
    },
    ["<A-e>"] = {
      function()
        pcall(function()
          local last_command = vim.fn.getcmdline()
          local modified_command = ":tab " .. last_command
          if last_command:find("^" .. "Gll") ~= nil then
            pcall(function()
              vim.g.gll_reload_manually_or_open_new = true
              modified_command = ":tabnew | execute('" .. last_command .. "')"
              vim.cmd(modified_command)
              vim.cmd("wincmd k")
              vim.cmd("wincmd q")
              vim.api.nvim_input("<Esc>")
            end)
            return
          end
          if last_command:find("^" .. "Redir G") ~= nil then
            local args = last_command:gsub("^Redir ", "")
            require("core.utils_redir").nredir(args, "tab")
            vim.cmd("wincmd k")
            vim.cmd("wincmd q")
            vim.api.nvim_input("<Esc>")
            return
          end
          if last_command:find("^" .. "Redir") ~= nil then
            local args = last_command:gsub("^Redir ", "")
            require("core.utils_redir").nredir(args, "tab")
            vim.api.nvim_input("<Esc>")
            return
          end
          if not pcall(function()
                vim.cmd(modified_command)
              end) then
            vim.cmd(last_command)
          end
          vim.api.nvim_input("<Esc>")
        end)
      end,
      "add `tab` to the beginning of the command to open in new tab",
    },
    ["<A-0>"] = {
      function()
        pcall(function()
          local last_command = vim.fn.getcmdline()
          local modified_command = "0" .. last_command
          if last_command:find("^" .. "Gll") ~= nil then
            pcall(function()
              -- current buf before running the command
              local current_buf = vim.api.nvim_get_current_buf()
              -- see if there is any record for the current buffer
              -- have to do this temporary variable thing, see https://github.com/nanotee/nvim-lua-guide#caveats-3
              local x = vim.g.gll_records
              x = x or {}
              if x[tostring(current_buf)] ~= nil and x[tostring(current_buf)].is_gll == true then
                -- clear the record, as this command that we are running now is going to
                -- replace the current buffer
                x[tostring(current_buf)] = nil
                vim.g.gll_records = x
              end
              -- then run the Gll command
              require("core.utils_window").save_window_sizes_and_restore(function()
                vim.g.gll_reload_manually_or_open_new = true
                modified_command = last_command
                vim.cmd(modified_command)
                vim.cmd("wincmd k")
                vim.cmd("wincmd q")
                vim.cmd("wincmd p") -- make sure to focus on the Gll window
                vim.api.nvim_input("<Esc>")
              end)
            end)
            return
          end
          if last_command:find("^" .. "Redir G") ~= nil then
            pcall(function()
              local args = last_command:gsub("^Redir ", "")
              require("core.utils_redir").nredir(args, "horizontal")
              vim.cmd("wincmd k")
              vim.cmd("wincmd q")
              vim.api.nvim_input("<Esc>")
            end)
            return
          end
          if not pcall(function()
                vim.cmd(modified_command)
              end) then
            vim.cmd(last_command)
          end
          vim.api.nvim_input("<Esc>")
        end)
      end,
      "add `0` to the beginning of the command to open in current window (useful for fugitive :Git log)",
    },
    ["<A-_>"] = {
      function()
        pcall(function()
          local last_command = vim.fn.getcmdline()
          local modified_command = last_command
          if last_command:find("^" .. "Gll") ~= nil then
            pcall(function()
              vim.g.gll_reload_manually_or_open_new = true
              vim.cmd(last_command)
              vim.api.nvim_input("<Esc>")
            end)
            return
          end
          if last_command:find("^" .. "Redir G") ~= nil then
            local args = last_command:gsub("^Redir ", "")
            require("core.utils_redir").nredir(args, "horizontal")
            vim.cmd("wincmd k")
            local dummy_bufnr = vim.api.nvim_get_current_buf()
            vim.cmd("wincmd q")
            vim.api.nvim_input("<Esc>")
            vim.cmd("bdelete! " .. dummy_bufnr)
            return
          end
          if last_command:find("^" .. "Redir") ~= nil then
            local args = last_command:gsub("^Redir ", "")
            require("core.utils_redir").nredir(args, "horizontal")
            vim.api.nvim_input("<Esc>")
            return
          end
          if not pcall(function()
                vim.cmd(modified_command)
              end) then
            vim.cmd(last_command)
          end
          vim.api.nvim_input("<Esc>")
        end)
      end,
      "open fugitive :Git log in horizontal split",
    },

    ["<C-r><C-k>"] = {
      [[<C-r>=line('.')<CR>]],
      "Echo current line number",
      opts = { silent = true, noremap = true },
    },
  },
}

M.tabufline = {
  plugin = true,
}

M.lspconfig = {
  plugin = true,

  -- See `<cmd> :help vim.lsp.*` for documentation on any of the below functions

  i = {
    ["<C-s>"] = {
      function()
        vim.lsp.buf.signature_help()
      end,
      "lsp signature_help",
    },
  },

  n = {
    -- ["gD"] = {
    --  function()
    --    vim.lsp.buf.declaration()
    --  end,
    --  "lsp declaration",
    -- },

    -- ["gd"] = {
    --  function()
    --    vim.lsp.buf.definition()
    --  end,
    --  "lsp definition",
    -- },

    ["gh"] = {
      function()
        vim.lsp.buf.hover()
      end,
      "lsp hover",
    },

    -- ["gi"] = {
    --  function()
    --    vim.lsp.buf.implementation()
    --  end,
    --  "lsp implementation",
    -- },

    -- ["<leader>ls"] = {
    --   function()
    --     vim.lsp.buf.signature_help()
    --   end,
    --   "lsp signature_help",
    -- },

    -- ["<leader>D"] = {
    --  function()
    --    vim.lsp.buf.type_definition()
    --  end,
    --  "lsp definition type",
    -- },

    ["gn"] = {
      function()
        -- utils_renamer.open()
        vim.lsp.buf.rename()
      end,
      "lsp rename",
    },

    ["g."] = {
      function()
        vim.lsp.buf.code_action()
      end,
      "lsp code_action",
    },

    -- ["gr"] = {
    --  function()
    --    vim.lsp.buf.references()
    --  end,
    --  "lsp references",
    -- },

    -- ["<leader>f"] = {
    --  function()
    --    vim.diagnostic.open_float({ border = "rounded" })
    --  end,
    --  "floating diagnostic",
    -- },

    ["ge"] = {
      function()
        vim.diagnostic.open_float()
      end,
      "show diagnostics message",
    },

    ["gE"] = {
      function()
        if vim.diagnostic.config().virtual_text then
          vim.diagnostic.config({ virtual_text = false })
        else
          vim.diagnostic.config({ virtual_text = true })
        end
      end,
      "show diagnostics message",
    },

    ["[z"] = {
      function()
        vim.diagnostic.goto_prev()
      end,
      "goto prev",
    },

    ["]z"] = {
      function()
        vim.diagnostic.goto_next()
      end,
      "goto_next",
    },

    -- ["<leader>q"] = {
    --  function()
    --    vim.diagnostic.setloclist()
    --  end,
    --  "diagnostic setloclist",
    -- },

    ["<A-f>"] = {
      function()
        vim.lsp.buf.format({ async = true })
      end,
      "Format document",
    },

    -- ["<leader>wa"] = {
    --  function()
    --    vim.lsp.buf.add_workspace_folder()
    --  end,
    --  "add workspace folder",
    -- },

    -- ["<leader>wr"] = {
    --  function()
    --    vim.lsp.buf.remove_workspace_folder()
    --  end,
    --  "remove workspace folder",
    -- },

    -- ["<leader>wl"] = {
    --  function()
    --    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    --  end,
    --  "list workspace folders",
    -- },
  },
}

M.nvimtree = {
  plugin = true,

  n = {
    -- toggle
    ["<leader>NN"] = { "<cmd> NvimTreeToggle <CR>", "toggle nvimtree" },
    ["<leader>NF"] = { "<cmd> NvimTreeFindFile <CR>", "find file in nvimtree" },
  },
}

M.telescope = {
  plugin = true,

  n = {
    -- file browser
    ["<leader>fs"] = {
      "<cmd> let g:telescope_picker_temporary_cwd_from_file_browser='false' | Telescope file_browser <CR>",
      "file browser",
    },

    -- find
    -- set global variable here so that the telescope picker knows this is a normal finder
    -- see telescope config file for more information
    ["<leader>ff"] = {
      function()
        vim.g.find_files_type = "normal"
        vim.g.telescope_picker_type = "find_files"
        require("plugins.configs.telescope_utils").find_files()
      end,
      "find files",
    },
    ["<leader>fa"] = {
      function()
        vim.g.find_files_type = "all"
        vim.g.telescope_picker_type = "find_files"
        require("plugins.configs.telescope_utils").find_all_files()
      end,
      "find all",
    },
    -- ["<leader>fG"] = { "<cmd> let g:telescope_picker_type='live_grep' | Telescope live_grep <CR>", "live grep" },
    ["<leader>fg"] = {
      "<cmd> :lua require('plugins.configs.telescope_utils').custom_rg() <CR>",
      "live grep (custom)",
    },
    ["<leader>fb"] = {
      "<cmd> Telescope buffers ignore_current_buffer=true cwd_only=true <CR>",
      "find buffers for current working directory",
    },
    ["<leader>fB"] = { "<cmd> Telescope buffers ignore_current_buffer=true <CR>", "find buffers" },
    ["<leader>fh"] = { "<cmd> Telescope help_tags <CR>", "help page" },
    ["<leader>fo"] = {
      "<cmd> Telescope oldfiles cwd_only=true <CR>",
      "find oldfiles for current working directory",
    },
    ["<leader>fO"] = { "<cmd> Telescope oldfiles <CR>", "find oldfiles" },
    ["<leader>fz"] = { "<cmd> Telescope current_buffer_fuzzy_find <CR>", "find in current buffer" },
    ["<leader>f*"] = {
      ":lua require('plugins.configs.telescope_utils').grep_string_custom({}) <CR>",
      "search for string under cursor in cwd",
    },
    ["<leader>ft"] = { ":lua require('plugins.configs.telescope_tabs').list_tabs() <CR>", "list tabs" },
    ["<leader>fj"] = { "<cmd> Telescope jumplist <CR>", "list jumplist" },

    ["<leader>fr"] = {
      function()
        local status, config_telescope = pcall(require, "plugins.configs.telescope_utils")
        if status then
          config_telescope.resume_with_cache()
        end
      end,
      "resume with cache",
    },

    ["<leader>fR"] = { "<cmd> Telescope pickers <CR>", "cache pickers" },

    -- terminal switcher
    ["<leader>tt"] = { "<cmd> TermSelect <CR>", "select terminal" },
    -- open terminal in new buffer not using toggleterm
    ["<leader>tn"] = { ":term zsh || fish || bash <CR>", "open terminal in new buffer" },

    -- workspaces
    ["<leader>fw"] = { "<cmd> Telescope workspaces <CR>", "list workspaces" },

    -- modified buffers
    ["<leader>fm"] = {
      ":lua require('plugins.configs.telescope_utils').get_modified_buffers(false) <CR>",
      "list modified buffers in current cwd",
      opts = { silent = true },
    },
    ["<leader>fM"] = {
      ":lua require('plugins.configs.telescope_utils').get_modified_buffers(true) <CR>",
      "list modified buffers ",
      opts = { silent = true },
    },

    -- lsp
    ["gi"] = {
      ":lua require('plugins.configs.telescope_utils').open_lsp_implementation_conditional({show_line='false', jump_type='never', reuse_win='true'}) <CR>",
      "lsp implementation",
      opts = { silent = true },
    },
    -- ["gI"] = {
    --   "<cmd> Telescope lsp_implementations show_line=false jump_type=never <CR>",
    --   "lsp implementation in vsplit",
    -- },
    ["gr"] = {
      ":lua require('plugins.configs.telescope_utils').open_lsp_references_conditional({show_line='false', jump_type='never', reuse_win='true'}) <CR>",
      "lsp references",
      opts = { silent = true },
    },
    -- ["gR"] = { "<cmd> Telescope lsp_references show_line=false jump_type=never <CR>", "lsp references in vsplit" },
    -- ["gd"] = { "<cmd> Telescope lsp_definitions show_line=false <CR>", "lsp definitions" },
    ["gd"] = {
      ":lua require('plugins.configs.telescope_utils').open_lsp_definitions_conditional({show_line='false', jump_type='never', reuse_win='true'}) <CR>",
      "lsp definitions",
      opts = { silent = true },
    },
    -- ["gD"] = {
    --   "<cmd> Telescope lsp_definitions show_line=false jump_type=never <CR>",
    --   "lsp definitions in vsplit",
    -- },
    -- ["gD"] = {
    --   "<cmd> :lua require('plugins.configs.telescope_utils').open_lsp_definitions_conditional({show_line=false, jump_type='never'}) <CR>",
    --   "lsp definitions in vsplit",
    -- },
    ["gt"] = {
      ":lua require('plugins.configs.telescope_utils').open_lsp_type_definition_conditional({show_line='false', jump_type='never', reuse_win='true'}) <CR>",
      "lsp type definitions",
      opts = { silent = true },
    },
    -- ["gT"] = {
    --   "<cmd> Telescope lsp_type_definitions show_line=false jump_type=never <CR>",
    --   "lsp type definitions in vsplit",
    -- },
    ["gs"] = { "<cmd> Telescope lsp_document_symbols symbol_width=60 <CR>", "lsp document symbols" },
    ["gS"] = { "<cmd> Telescope lsp_workspace_symbols symbol_width=60 <CR>", "lsp workspace symbols" },

    -- diagnostic
    ["gZ"] = { "<cmd> Telescope diagnostics <CR>", "open workspace diagnostics" },
    ["gz"] = { "<cmd> Telescope diagnostics bufnr=0 <CR>", "open current buffer diagnostics" },

    -- this is just a note, this is to open file (like gf), but take consideration of
    -- the row and col appended to the filename, see core.utils_vimfetch
    ["<leader>of"] = {
      ":lua require('plugins.configs.buffer_utils').open_file_in_current_window(false, vim.v.count) <CR>",
      "open file in current window",
      opts = { silent = true },
    },
    ["<leader>oF"] = {
      ":lua require('plugins.configs.buffer_utils').open_file_in_new_tab(false, vim.v.count) <CR>",
      "open file in new tab",
      opts = { silent = true },
    },
    ["<leader>oT"] = {
      ":lua require('plugins.configs.buffer_utils').open_file_or_buffer_in_specific_tab(false, vim.v.count) <CR>",
      "open file in specific tab",
      opts = { silent = true },
    },
    ["<leader>ot"] = {
      ":lua require('plugins.configs.buffer_utils').open_file_or_buffer_in_tab(false, vim.v.count) <CR>",
      "open file in tab",
      opts = { silent = true },
    },
    ["<leader>ow"] = {
      ":lua require('plugins.configs.buffer_utils').open_file_or_buffer_in_window(false, vim.v.count) <CR>",
      "open file in window",
      opts = { silent = true },
    },
  },

  v = {
    ["<leader>f*"] = {
      ":lua require('plugins.configs.telescope_utils').grep_string_custom({}) <CR>",
      "search for string under cursor in cwd",
    },
    -- this is just a note, this is to open file (like gf), but take consideration of
    -- the row and col appended to the filename, see core.utils_vimfetch
    ["<leader>of"] = {
      ":lua require('plugins.configs.buffer_utils').open_file_in_current_window(true, vim.v.count) <CR>",
      "open file in current window",
      opts = { silent = true },
    },
    ["<leader>oF"] = {
      ":lua require('plugins.configs.buffer_utils').open_file_in_new_tab(true, vim.v.count) <CR>",
      "open file in new tab",
      opts = { silent = true },
    },
    ["<leader>oT"] = {
      ":lua require('plugins.configs.buffer_utils').open_file_in_specific_tab(true, vim.v.count) <CR>",
      "open file in specific tab",
      opts = { silent = true },
    },
    ["<leader>ot"] = {
      ":lua require('plugins.configs.buffer_utils').open_file_in_new_tab(true, vim.v.count) <CR>",
      "open file in tab",
      opts = { silent = true },
    },
    ["<leader>ow"] = {
      ":lua require('plugins.configs.buffer_utils').open_file_or_buffer_in_window(true, vim.v.count) <CR>",
      "open file in window",
      opts = { silent = true },
    },
  },
}

M.whichkey = {
  plugin = true,

  n = {
    ["<leader>wK"] = {
      function()
        vim.cmd("WhichKey")
      end,
      "which-key all keymaps",
    },
    ["<leader>wk"] = {
      function()
        local input = vim.fn.input("WhichKey: ")
        vim.cmd("WhichKey " .. input)
      end,
      "which-key query lookup",
    },
  },
}

M.blankline = {
  plugin = true,

  n = {
    ["<leader>cc"] = {
      function()
        local ok, start = require("indent_blankline.utils").get_current_context(
          vim.g.indent_blankline_context_patterns,
          vim.g.indent_blankline_use_treesitter_scope
        )

        if ok then
          vim.api.nvim_win_set_cursor(vim.api.nvim_get_current_win(), { start, 0 })
          vim.cmd([[normal! _]])
        end
      end,

      "Jump to current_context",
    },
  },
}

M.gitsigns = {
  plugin = true,

  n = {
    -- Navigation through hunks
    ["]c"] = {
      function()
        -- if vim.wo.diff then
        --   return "]c"
        -- end
        -- vim.schedule(function()
        require("gitsigns").next_hunk()
        -- end)
        -- return "<Ignore>"
      end,
      "Jump to next hunk",
      -- opts = { expr = true },
    },

    ["[c"] = {
      function()
        -- if vim.wo.diff then
        --   return "[c"
        -- end
        -- vim.schedule(function()
        require("gitsigns").prev_hunk()
        -- end)
        -- return "<Ignore>"
      end,
      "Jump to prev hunk",
      -- opts = { expr = true },
    },

    -- Git related actions
    ["<leader>gR"] = {
      function()
        require("gitsigns").reset_hunk()
      end,
      "Reset hunk",
    },

    -- ["<leader>gp"] = {
    --   function()
    --     require("gitsigns").preview_hunk()
    --   end,
    --   "Preview hunk",
    -- },

    -- ["<leader>gP"] = {
    --   function()
    --     require("gitsigns").preview_hunk_inline()
    --   end,
    --   "Preview hunk",
    -- },

    -- ["<leader>gb"] = {
    --   function()
    --     require("gitsigns").toggle_current_line_blame()
    --   end,
    --   "Toggle current line blame",
    -- },

    -- ["<leader>gB"] = {
    --   function()
    --     require("gitsigns").blame_line()
    --   end,
    --   "Current line blame",
    -- },

    ["<leader>gdd"] = { ":lua require('gitsigns').toggle_deleted() <CR>", "Toggle deleted" },

    ["<leader>gdv"] = { ":Gvdiffsplit <CR>", "Diff this (vertical)" },
    ["<leader>gdh"] = { ":Ghdiffsplit <CR>", "Diff this (horizontal)" },
    ["<leader>gb"] = {
      ":G blame <CR>",
      "Open git blame",
      opts = { silent = true },
    },

    -- ["<leader>gD"] = {
    --   function()
    --     require("gitsigns").diffthis()
    --   end,
    --   "Diff this",
    -- },
  },
}

-- M.easymotion = {
--   plugin = true,
--
--   n = {
--     ["<leader>s"] = {
--       "<Plug>(easymotion-s2)",
--       "Easymotion search 2 character",
--     },
--   },
-- }

M.toggleterm = {
  plugin = true,

  n = {
    ["<A-.>"] = {
      function()
        require("plugins.configs.toggleterm_utils").toggle_term("horizontal")
      end,
      "toggle term in horizontal mode",
    },
    ["<A->>"] = {
      function()
        require("plugins.configs.toggleterm_utils").toggle_term("vertical")
      end,
      "toggle term in vertical mode",
    },
    ["<A-/>"] = {
      function()
        require("plugins.configs.toggleterm_utils").toggle_term("float")
      end,
      "toggle term in float mode",
    },
    ["<A-,>"] = {
      function()
        require("plugins.configs.toggleterm_utils").toggle_term("tab")
      end,
      "toggle term in tab mode",
    },
  },

  t = {
    ["<C-n>"] = { vim.api.nvim_replace_termcodes("<C-\\><C-N>", true, true, true), "escape terminal mode" },
    ["<A-.>"] = { "<C-n> <cmd> ToggleTerm <CR>", "toggle term" },
    ["<A->>"] = { "<C-n> <cmd> ToggleTerm <CR>", "toggle term" },
    ["<A-/>"] = { "<C-n> <cmd> ToggleTerm <CR>", "toggle term" },
    ["<A-,>"] = { "<C-n> <cmd> ToggleTerm <CR>", "toggle term" },
    -- window navigation
    -- ["<A-h>"] = { "<C-\\><C-N> <cmd>wincmd h<CR>", "navigate left" },
    -- ["<A-j>"] = { "<C-\\><C-N> <cmd>wincmd j<CR>", "navigate down" },
    -- ["<A-k>"] = { "<C-\\><C-N> <cmd>wincmd k<CR>", "navigate up" },
    -- ["<A-l>"] = { "<C-\\><C-N> <cmd>wincmd l<CR>", "navigate right" },
  },
}

M.codeium = {
  plugin = true,

  i = {
    ["<A-]>"] = {
      function()
        pcall(function()
          return vim.fn["codeium#CycleCompletions"](1)
        end)
      end,
      opts = { silent = true, expr = true },
    },
    ["<A-[>"] = {
      function()
        pcall(function()
          return vim.fn["codeium#CycleCompletions"](-1)
        end)
      end,
      opts = { silent = true, expr = true },
    },
    ["<A-Tab>"] = {
      function()
        if vim.fn["codeium#Accept"] then
          return vim.fn["codeium#Accept"]()
        end
      end,
      opts = { silent = true, expr = true },
    },
    ["<A-q>"] = {
      function()
        pcall(function()
          return vim.fn["codeium#Clear"]()
        end)
      end,
      opts = { silent = true, expr = true },
    },
  },
}

-- these are mappings and configuration for vim-visual-multi
M.vm = {
  plugin = true,

  init = function()
    vim.g.VM_default_mappings = 0
    vim.g.VM_maps = {}
    vim.g.VM_mouse_mappings = 1
    vim.g.VM_set_statusline = 1
    vim.g.VM_silent_exit = 1
    vim.g.VM_persistent_registers = true
    vim.g.VM_add_cursor_at_pos_no_mappings = 1
    vim.g.VM_custom_remaps = {
      ["v"] = "<Tab>",
      ["<C-k>"] = "<Up>",
      ["<C-j>"] = "<Down>",
      ["<C-h>"] = "<Left>",
      ["<C-l>"] = "<Right>",
    }
    vim.g.VM_custom_noremaps = {
      ["=="] = "==",
      ["<<"] = "<<",
      [">>"] = ">>",
    }
    vim.g.VM_maps = {
      ["Find Under"] = "<leader>vb",
      ["Find Subword Under"] = "<leader>vb",
      ["Select All"] = "<M-C-n>",
      ["Select Cursor Down"] = "<M-C-j>",
      ["Select Cursor Up"] = "<M-C-k>",
      ["Skip Region"] = "q",
      ["Remove Region"] = "Q",
      ["Invert Direction"] = "o",
      ["Goto Next"] = "]",
      ["Goto Prev"] = "[",
      ["Surround"] = "S",
      ["Undo"] = "u",
      ["Redo"] = "<C-r>",
      ["Reselect Last"] = "<leader>vgv",
      ["Add Cursor At Pos"] = "<leader>vc",
      ["Toggle Mappings"] = "<leader>vs",
    }
  end,
}

M.nvim_dap = {
  n = {
    ["<leader>dR"] = {
      function()
        require("dap").run_to_cursor()
      end,
      "Run to Cursor",
    },
    ["<leader>dE"] = {
      function()
        require("dapui").eval(vim.fn.input("[Expression] > "))
      end,
      "Evaluate Input",
    },
    ["<leader>dC"] = {
      function()
        require("dap").set_breakpoint(vim.fn.input("[Condition] > "))
      end,
      "Conditional Breakpoint",
    },
    ["<leader>dU"] = {
      function()
        require("dapui").toggle()
      end,
      "Toggle UI",
    },
    ["<leader>db"] = {
      function()
        require("dap").step_back()
      end,
      "Step Back",
    },
    ["<leader>dc"] = {
      function()
        require("dap").continue()
      end,
      "Continue",
    },
    ["<leader>dd"] = {
      function()
        require("dap").disconnect()
      end,
      "Disconnect",
    },
    ["<leader>de"] = {
      function()
        require("dapui").eval()
      end,
      "Evaluate",
    },
    ["<leader>dg"] = {
      function()
        require("dap").session()
      end,
      "Get Session",
    },
    ["<leader>dh"] = {
      function()
        require("dap.ui.widgets").hover()
      end,
      "Hover Variables",
    },
    ["<leader>dS"] = {
      function()
        require("dap.ui.widgets").scopes()
      end,
      "Scopes",
    },
    ["<leader>di"] = {
      function()
        require("dap").step_into()
      end,
      "Step Into",
    },
    ["<leader>do"] = {
      function()
        require("dap").step_over()
      end,
      "Step Over",
    },
    ["<leader>dp"] = {
      function()
        require("dap").pause.toggle()
      end,
      "Pause",
    },
    ["<leader>dq"] = {
      function()
        require("dap").close()
      end,
      "Quit",
    },
    ["<leader>dr"] = {
      function()
        require("dap").repl.toggle()
      end,
      "Toggle REPL",
    },
    ["<leader>ds"] = {
      function()
        require("dap").continue()
      end,
      "Start",
    },
    ["<leader>dt"] = {
      function()
        require("dap").toggle_breakpoint()
      end,
      "Toggle Breakpoint",
    },
    ["<leader>dx"] = {
      function()
        require("dap").terminate()
      end,
      "Terminate",
    },
    ["<leader>du"] = {
      function()
        require("dap").step_out()
      end,
      "Step Out",
    },
  },
  v = {
    ["<leader>de"] = {
      function()
        require("dapui").eval()
      end,
      "Evaluate",
    },
  },
}

M.trouble = {
  n = {
    ["tr"] = { "<cmd> Trouble lsp_references toggle focus=true <CR>", "lsp references" },
    ["ti"] = { "<cmd> Trouble lsp_implementations toggle focus=true <CR>", "lsp implementation" },
    ["td"] = { "<cmd> Trouble lsp_definitions toggle focus=true <CR>", "lsp definitions" },
    ["tz"] = { "<cmd> Trouble diagnostics toggle focus=true filter.buf=0 <CR>", "open current buffer diagnostics" },
    ["tZ"] = { "<cmd> Trouble diagnostics toggle focus=true <CR>", "open workspace diagnostics" },
    ["t."] = { "<cmd> Trouble quickfix toggle focus=true <CR>", "open quickfix" },
    ["ts"] = { "<cmd> Trouble lsp_document_symbols toggle focus=true <CR>", "open document symbols" },
  },
}

M.yanky = {
  plugin = true,
  n = {
    ["p"] = { "<Plug>(YankyPutAfter)", "yanky p" },
    ["P"] = { "<Plug>(YankyPutBefore)", "yanky P" },
    ["gp"] = { "<Plug>(YankyGPutAfter)", "yanky gp" },
    ["gP"] = { "<Plug>(YankyGPutBefore)", "yanky gP" },
    ["<C-p>n"] = { "<Plug>(YankyNextEntry)", "yanky paste next entry from yank ring history" },
    ["<C-p>p"] = { "<Plug>(YankyPreviousEntry)", "yanky paste previous entry from yank ring history" },
  },
  x = {
    ["p"] = { "<Plug>(YankyPutAfter)", "yanky p" },
    ["P"] = { "<Plug>(YankyPutBefore)", "yanky P" },
    ["gp"] = { "<Plug>(YankyGPutAfter)", "yanky gp" },
    ["gP"] = { "<Plug>(YankyGPutBefore)", "yanky gP" },
  },
}

M.enhancedJumps = {
  plugin = true,
  n = {
    ["g;"] = { "g;" }, -- the EnhancedJumps version of this command seems weird, map this to original version
    ["g,"] = { "g," }, -- the EnhancedJumps version of this command seems weird, map this to original version
  },
}

return M
