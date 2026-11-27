-- Getting around a file without counting lines

-- flash: type a character or two of where you want to go and every match on screen,
-- in every split, gets a label; press the label to jump there. Labels are never the
-- next letter you'd type, so typing more narrows the matches instead. It also
-- improves f/F/t/T: they work across lines, highlight every target, and pressing f
-- again goes to the next one. All of these work after an operator too, e.g.
-- `d s re <label>` deletes up to that `re`. mini.surround is on gs so that s is free
-- (see init.lua). See `:help flash.nvim.txt`
vim.pack.add { 'https://github.com/folke/flash.nvim' }
local flash = require 'flash'
flash.setup {}

-- Only the labels get a coloured block, so the eye goes straight to them. By default
-- the matched text sits on a bright green block (Search) right beside the yellow
-- label, and the two compete. Matches are bold white text instead, which still
-- stands out because flash greys the rest of the screen. Set again on ColorScheme,
-- since loading a colorscheme clears these
local function flash_highlights()
  vim.api.nvim_set_hl(0, 'FlashMatch', { fg = '#f7f1ff', bold = true })
  vim.api.nvim_set_hl(0, 'FlashCurrent', { link = 'FlashMatch' })
  vim.api.nvim_set_hl(0, 'FlashLabel', { fg = '#2d2a2e', bg = '#fce566', bold = true })
end
flash_highlights()
vim.api.nvim_create_autocmd('ColorScheme', { callback = flash_highlights })

vim.keymap.set({ 'n', 'x', 'o' }, 's', flash.jump, { desc = 'Flash jump' })
-- Labels the treesitter nodes around the cursor (expression, argument, block,
-- function, ...) at both ends, e.g. `v S <label>` selects a whole function
vim.keymap.set({ 'n', 'x', 'o' }, 'S', flash.treesitter, { desc = 'Flash select code block' })

-- Counted j/k (e.g. 12j) go in the jumplist, so ctrl+o comes back from them, which
-- Vim only does for bigger motions. Without a count they move by screen line, so
-- they don't skip over the rest of a wrapped line
local function counted(key)
  return function() return vim.v.count > 1 and "m'" .. vim.v.count .. key or 'g' .. key end
end
vim.keymap.set({ 'n', 'x' }, 'j', counted 'j', { expr = true, desc = 'Down (counted jumps go in the jumplist)' })
vim.keymap.set({ 'n', 'x' }, 'k', counted 'k', { expr = true, desc = 'Up (counted jumps go in the jumplist)' })
