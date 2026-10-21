local sessions = require 'mini.sessions'

-- Sessions live in stdpath('data')/session and are listed on the start screen.
-- The active session is saved again automatically when quitting.
sessions.setup { autowrite = true }

require('which-key').add { { '<leader>S', group = '[S]ession' } }

-- Name sessions after the project directory, e.g. `dotfiles`
vim.keymap.set('n', '<leader>Ss', function()
  sessions.write(vim.fn.fnamemodify(vim.fn.getcwd(), ':t'))
end, { desc = '[S]ession [s]ave for this project' })
vim.keymap.set('n', '<leader>Sl', function() sessions.select 'read' end, { desc = '[S]ession [l]oad' })
vim.keymap.set('n', '<leader>Sd', function() sessions.select 'delete' end, { desc = '[S]ession [d]elete' })
