-- Edit the filesystem like a buffer: rename by editing a line, `dd` to delete, add a
-- line to create (end it in / for a directory), `dd` and `p` in another directory to
-- move. `:w` shows the changes and asks before applying them. Replaces netrw, so
-- `nvim .` opens it. Press `g?` in an oil buffer for its keymaps. See `:help oil`
vim.pack.add { 'https://github.com/stevearc/oil.nvim' }

require('oil').setup {
  delete_to_trash = true, -- deleted files go to the macOS Trash rather than being removed
  view_options = {
    show_hidden = true, -- dotfiles like .env, matching telescope's find_files. `g.` toggles
  },
  -- Leave <C-h>/<C-l> to move between windows, as everywhere else (init.lua). Horizontal
  -- split moves to <C-x>, Telescope's key for it; refresh is dropped as oil re-reads after `:w`
  keymaps = {
    ['<C-h>'] = false,
    ['<C-l>'] = false,
    ['<C-x>'] = { 'actions.select', opts = { horizontal = true } },
  },
}

vim.keymap.set('n', '-', '<cmd>Oil<CR>', { desc = 'Open parent directory' })
