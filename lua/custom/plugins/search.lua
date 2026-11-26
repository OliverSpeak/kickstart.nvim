-- Search and replace across the project: a buffer with fields for the search, the
-- replacement, a files filter (e.g. *.php), flags and paths, with every match listed
-- below as you type, and each change shown as a diff once there's a replacement.
-- Uses ripgrep, so .gitignore is respected and the search is a regex (--fixed-strings
-- in the flags for plain text). Keys are listed at the top of its buffer.
-- See `:help grug-far`
vim.pack.add { 'https://github.com/MagicDuck/grug-far.nvim' }
require('grug-far').setup {
  -- Its own tab, so results get the full width: a split is cramped in nvim's half of
  -- cook's tmux window, beside Claude
  windowCreationCommand = 'tab split',
  transient = true, -- unlisted, and deleted once its window closes
}

vim.keymap.set('n', '<leader>sR', function() require('grug-far').open() end, { desc = '[S]earch and [R]eplace in the project' })
-- With text selected, it starts with that as the search
vim.keymap.set('x', '<leader>sR', function() require('grug-far').with_visual_selection() end, { desc = '[S]earch and [R]eplace the selection' })
