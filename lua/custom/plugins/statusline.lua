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
  sections = {
    lualine_x = {
      -- With no command line row, 'recording @q' has nowhere else to show
      {
        function() return 'recording @' .. vim.fn.reg_recording() end,
        cond = function() return vim.fn.reg_recording() ~= '' end,
        -- The theme's red, from the palette set in colorscheme.lua
        color = { fg = vim.g.sonokai_colors_override.red[1], gui = 'bold' },
      },
      'encoding',
      'fileformat',
      'filetype',
    },
  },
}

-- Redraw as soon as recording starts or stops, rather than on the next refresh tick.
-- reg_recording() is still set during RecordingLeave, so wait until after it
vim.api.nvim_create_autocmd({ 'RecordingEnter', 'RecordingLeave' }, {
  callback = function() vim.schedule(require('lualine').refresh) end,
})

-- Merge the command line into the statusline: the command line only takes over
-- the bottom row while typing a command. ui2 (experimental, built in) shows
-- messages in a corner window and long output in a pager instead of hit-enter
-- prompts. See `:help ui2` and `:help 'cmdheight'`
vim.o.cmdheight = 0
require('vim._core.ui2').enable { msg = { targets = 'msg' } }

-- Color the cursor line number by mode, matching lualine's mode colors
-- Needs 'number' and 'cursorline', both set in init.lua. See `:help modicator`
vim.pack.add { 'https://github.com/mawkler/modicator.nvim' }
require('modicator').setup {}
