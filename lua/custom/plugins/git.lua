-- VSCode-style repo-wide diffs and file history. See `:help codediff`
-- Press `q` in a CodeDiff tab to close it, `g?` for its keymaps
vim.pack.add { 'https://github.com/esmuellert/codediff.nvim' }

require('codediff').setup {}

vim.keymap.set('n', '<leader>gd', '<cmd>CodeDiff<CR>', { desc = '[G]it [d]iff working tree' })
vim.keymap.set('n', '<leader>gm', '<cmd>CodeDiff origin/HEAD...<CR>', { desc = '[G]it diff branch against [m]ain' })
vim.keymap.set('n', '<leader>gh', '<cmd>CodeDiff history %<CR>', { desc = '[G]it [h]istory of current file' })
vim.keymap.set('n', '<leader>gH', '<cmd>CodeDiff history<CR>', { desc = '[G]it [H]istory of repo' })
vim.keymap.set('v', '<leader>gh', ":'<,'>CodeDiff history<CR>", { desc = '[G]it [h]istory of selected lines' })

-- Magit-style git interface: stage, commit, push, branch, rebase. See `:help neogit`
-- Press `?` in the status buffer for its keymaps
vim.pack.add {
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/NeogitOrg/neogit',
}

require('neogit').setup {
  diff_viewer = 'codediff', -- open diffs from neogit in codediff rather than diffview
}

vim.keymap.set('n', '<leader>gg', '<cmd>Neogit<CR>', { desc = '[G]it status (Neo[g]it)' })
vim.keymap.set('n', '<leader>gc', '<cmd>Neogit commit<CR>', { desc = '[G]it [c]ommit' })

require('which-key').add {
  { '<leader>g', group = '[G]it', mode = { 'n', 'v' } },
}
