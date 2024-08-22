local M = {}

M.toggle_term = function(target_direction)
  if vim.g.toggle_term_direction == nil and vim.g.toggle_term_opened == nil and vim.g.toggle_term_count == nil then
    vim.g.toggle_term_direction = target_direction
    vim.g.toggle_term_opened = false
    vim.g.toggle_term_count = 1
  end

  local count = vim.v.count or 1

  if count ~= 0 then
    if count ~= vim.g.toggle_term_count then
      if vim.g.toggle_term_direction == target_direction then
        if not vim.g.toggle_term_opened then
          -- open term for direction [target_direction]
          vim.cmd(count .. "ToggleTerm direction=" .. target_direction)
          vim.g.toggle_term_opened = true
          vim.g.toggle_term_count = count
          goto done
        end

        if vim.g.toggle_term_opened then
          -- close existing term
          vim.cmd(vim.g.toggle_term_count .. "ToggleTerm")
          vim.g.toggle_term_opened = false
          -- open [count] term for same direction [target_direction]
          vim.cmd(count .. "ToggleTerm direction=" .. target_direction)
          vim.g.toggle_term_opened = true
          vim.g.toggle_term_count = count
          goto done
        end
        goto done
      end

      -- different direction
      if not vim.g.toggle_term_opened then
        -- open [count] term for different direction [target_direction]
        vim.cmd(count .. "ToggleTerm direction=" .. target_direction)
        vim.g.toggle_term_opened = true
        vim.g.toggle_term_count = count
        goto done
      end

      if vim.g.toggle_term_opened then
        -- close existing term
        vim.cmd(vim.g.toggle_term_count .. "ToggleTerm")
        vim.g.toggle_term_opened = false
        -- open [count] term for different direction [target_direction]
        vim.cmd(count .. "ToggleTerm direction=" .. target_direction)
        vim.g.toggle_term_opened = true
        vim.g.toggle_term_count = count
        goto done
      end
    else
      if vim.g.toggle_term_direction == target_direction then
        if not vim.g.toggle_term_opened then
          -- open term for direction [target_direction]
          vim.cmd(count .. "ToggleTerm direction=" .. target_direction)
          vim.g.toggle_term_opened = true
          vim.g.toggle_term_count = count
          goto done
        end

        if vim.g.toggle_term_opened then
          -- close the term
          vim.cmd(vim.g.toggle_term_count .. "ToggleTerm")
          vim.g.toggle_term_opened = false
          vim.g.toggle_term_count = count
          goto done
        end
        goto done
      end

      -- different direction
      if not vim.g.toggle_term_opened then
        -- open [count] term for different direction [target_direction]
        vim.cmd(count .. "ToggleTerm direction=" .. target_direction)
        vim.g.toggle_term_opened = true
        vim.g.toggle_term_count = count
        goto done
      end

      if vim.g.toggle_term_opened then
        -- close existing term
        vim.cmd(vim.g.toggle_term_count .. "ToggleTerm")
        vim.g.toggle_term_opened = false
        -- open [count] term for different direction [target_direction]
        vim.cmd(count .. "ToggleTerm direction=" .. target_direction)
        vim.g.toggle_term_opened = true
        vim.g.toggle_term_count = count
        goto done
      end
    end
  else
    if vim.g.toggle_term_direction == target_direction then
      if not vim.g.toggle_term_opened then
        -- open term for direction
        vim.cmd("ToggleTerm direction=" .. target_direction)
        vim.g.toggle_term_opened = true
        goto done
      end

      if vim.g.toggle_term_opened then
        -- close term
        vim.cmd("ToggleTerm")
        vim.g.toggle_term_opened = false
        goto done
      end
      goto done
    end

    -- different direction
    if not vim.g.toggle_term_opened then
      -- open term for different direction
      vim.cmd("ToggleTerm direction=" .. target_direction)
      vim.g.toggle_term_opened = true
      goto done
    end

    if vim.g.toggle_term_opened then
      -- close term first
      vim.cmd("ToggleTerm")
      vim.g.toggle_term_opened = false
      -- then open term for different direction
      vim.cmd("ToggleTerm direction=" .. target_direction)
      vim.g.toggle_term_opened = true
      goto done
    end
  end

  ::done::
  vim.g.toggle_term_direction = target_direction
end

return M
