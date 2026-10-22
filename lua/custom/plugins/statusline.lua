-- Statusline with powerline-style pointed edges (needs a Nerd Font)
-- Replaces kickstart's mini.statusline. See `:help lualine.txt`

-- Both lualine's 'auto' theme and modicator read colors from the colorscheme,
-- and custom plugin files load in no fixed order, so load it first
require 'custom.plugins.colorscheme'

vim.pack.add { 'https://github.com/nvim-lualine/lualine.nvim' }

require('lualine').setup {
  options = {
    theme = 'auto', -- picks up the colorscheme's lualine theme when it has one
    section_separators = { left = '\u{e0b0}', right = '\u{e0b2}' }, -- solid arrows
    component_separators = { left = '\u{e0b1}', right = '\u{e0b3}' }, -- thin arrows
  },
}

-- Color the cursor line number by mode, matching lualine's mode colors
-- Needs 'number' and 'cursorline', both set in init.lua. See `:help modicator`
vim.pack.add { 'https://github.com/mawkler/modicator.nvim' }
require('modicator').setup {}
