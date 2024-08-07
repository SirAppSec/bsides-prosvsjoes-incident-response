# Incident Response
cheatsheet



### If using vim, use the following lua script to run commands in terminal:

```lua

-- Initialize the toggleterm plugin if not already done
require('toggleterm').setup {
      direction = 'vertical',
      size = 50,
}

-- Function to execute the current line or visual selection in an existing terminal
function _G.exec_line_or_selection_in_term()
      local mode = vim.api.nvim_get_mode().mode
      local lines = {}

      if mode == 'v' then
            -- Get the visually selected lines
          local start_pos = vim.fn.getpos("'<")
          local end_pos = vim.fn.getpos("'>")
          lines = vim.fn.getline(start_pos[2], end_pos[2])
      else
          -- Get the current line
          table.insert(lines, vim.fn.getline('.'))
      end

      -- Find the existing terminal buffer
      local term_bufnr = nil
      local buffers = vim.api.nvim_list_bufs()

      for _, buf in ipairs(buffers) do
          if vim.api.nvim_buf_get_option(buf, 'buftype') == 'terminal' then
                term_bufnr = buf
              break
          end
      end

      if term_bufnr then
            -- Switch to the terminal buffer
          vim.api.nvim_set_current_buf(term_bufnr)

          -- Get the job ID of the terminal
          local term_job_id = vim.b.terminal_job_id

          -- Send the command to the terminal
          for _, line in ipairs(lines) do
              vim.api.nvim_chan_send(term_job_id, line .. "\n")
          end

          -- Switch back to the previous buffer
          vim.cmd("b#")
      else
          print("No terminal buffer found.")
      end
  end

-- Key mappings
vim.api.nvim_set_keymap('n', '<leader>e', ':lua exec_line_or_selection_in_term()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<leader>e', ':lua exec_line_or_selection_in_term()<CR>', { noremap = true, silent = true })
}
```
