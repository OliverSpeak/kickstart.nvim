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
  treesitter_diff_highlight = true, -- syntax highlight code in the status buffer's inline diffs
}

-- sonokai links NeogitDiffAdd/Delete to plain Green/Red, so added and removed lines
-- only get a background in the hunk under the cursor. Give them that background everywhere
local function diff_backgrounds()
  for _, kind in ipairs { 'Add', 'Delete' } do
    local base = vim.api.nvim_get_hl(0, { name = 'NeogitDiff' .. kind, link = false })
    local cursor_hunk = vim.api.nvim_get_hl(0, { name = 'NeogitDiff' .. kind .. 'Highlight', link = false })
    vim.api.nvim_set_hl(0, 'NeogitDiff' .. kind, { fg = base.fg, bg = cursor_hunk.bg })
  end
end
diff_backgrounds()
vim.api.nvim_create_autocmd('ColorScheme', { callback = diff_backgrounds })

vim.keymap.set('n', '<leader>gg', '<cmd>Neogit<CR>', { desc = '[G]it status (Neo[g]it)' })
vim.keymap.set('n', '<leader>gc', '<cmd>Neogit commit<CR>', { desc = '[G]it [c]ommit' })

require('which-key').add {
  { '<leader>g', group = '[G]it', mode = { 'n', 'v' } },
}
