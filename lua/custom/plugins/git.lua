-- VSCode-style repo-wide diffs and file history. See `:help codediff`
-- Press `q` in a CodeDiff tab to close it, `g?` for its keymaps
vim.pack.add { 'https://github.com/esmuellert/codediff.nvim' }

require('codediff').setup {
  highlights = {
    -- Changed words match Neogit's, set by diff_backgrounds() below. codediff resolves
    -- these when its plugin file loads and on ColorScheme, both after that has run
    char_insert = 'NeogitDiffAddInline',
    char_delete = 'NeogitDiffDeleteInline',
  },
  diff = {
    filler_text = '', -- blank alignment rows instead of ╱╱╱ hatching
    highlight_added_deleted_files = true, -- tint whole new or deleted files green or red
  },
  explorer = {
    line_stats = { enabled = true }, -- +added -removed line counts beside each file
  },
}

-- Side by side needs about 80 columns a side plus the 40-column file list, which nvim
-- doesn't get beside Claude in cook's tmux split. When narrower, open diffs inline (one
-- pane, like GitHub's unified view). Checked on resize, so zooming the tmux pane
-- (prefix z) before opening a diff gets side by side. `t` in a diff toggles it
local function codediff_layout()
  require('codediff.config').options.diff.layout = vim.o.columns >= 200 and 'side-by-side' or 'inline'
end
codediff_layout()
vim.api.nvim_create_autocmd('VimResized', { callback = codediff_layout })

vim.keymap.set('n', '<leader>gd', '<cmd>CodeDiff<CR>', { desc = '[G]it [d]iff working tree' })
vim.keymap.set('n', '<leader>gm', '<cmd>CodeDiff origin/HEAD...<CR>', { desc = '[G]it diff branch against [m]ain' })
vim.keymap.set('n', '<leader>gh', '<cmd>CodeDiff history %<CR>', { desc = '[G]it [h]istory of current file' })
vim.keymap.set('n', '<leader>gH', '<cmd>CodeDiff history<CR>', { desc = '[G]it [H]istory of repo' })
vim.keymap.set('v', '<leader>gh', ":'<,'>CodeDiff history<CR>", { desc = '[G]it [h]istory of selected lines' })

-- Diff unsaved changes against the file on disk, for any file, tracked by git or not.
-- Based on `:help :DiffOrig`, but reads the file by path rather than through '#', whose
-- alternate file isn't always set (E499 on a second run). `]c`/`[c` jump between changes.
-- `q` in either panel, or <leader>gs again, closes the saved copy and leaves the edited
-- buffer open with its changes. `q` is only remapped in the edited buffer while the diff
-- is open, so macro recording works again once it closes

local diff_orig_scratch = {} -- edited buffer -> its saved-copy scratch buffer

local function diff_orig_close(buf)
  local scratch = diff_orig_scratch[buf] or (vim.b[buf].diff_orig_source and buf)
  if scratch and vim.api.nvim_buf_is_valid(scratch) then
    vim.api.nvim_buf_delete(scratch, { force = true }) -- BufWipeout below does the cleanup
    return true
  end
  return false
end

local function diff_orig()
  if diff_orig_close(vim.api.nvim_get_current_buf()) then return end

  local orig_buf = vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(0)
  if vim.bo.buftype ~= '' or vim.fn.filereadable(path) == 0 then
    vim.notify('DiffOrig: this buffer has no saved file to diff against', vim.log.levels.WARN)
    return
  end
  local filetype = vim.bo.filetype
  local orig_win = vim.api.nvim_get_current_win()

  vim.cmd 'leftabove vert new' -- saved version on the left, like codediff
  local scratch = vim.api.nvim_get_current_buf()
  vim.bo[scratch].buftype = 'nofile'
  vim.bo[scratch].bufhidden = 'wipe'
  vim.cmd('silent read ++edit ' .. vim.fn.fnameescape(path))
  vim.cmd 'silent 0delete _'
  vim.bo[scratch].filetype = filetype
  vim.bo[scratch].modifiable = false
  vim.b[scratch].diff_orig_source = orig_buf
  vim.cmd 'diffthis'

  diff_orig_scratch[orig_buf] = scratch
  local close = function() diff_orig_close(orig_buf) end
  for _, buf in ipairs { scratch, orig_buf } do
    vim.keymap.set('n', 'q', close, { buffer = buf, desc = 'Close diff against saved file' })
  end

  -- Closing the edited buffer's window takes the saved copy with it
  local win_closed = vim.api.nvim_create_autocmd('WinClosed', { pattern = tostring(orig_win), once = true, callback = function() vim.schedule(close) end })

  vim.api.nvim_create_autocmd('BufWipeout', {
    buffer = scratch,
    once = true,
    callback = function()
      diff_orig_scratch[orig_buf] = nil
      pcall(vim.api.nvim_del_autocmd, win_closed)
      if vim.api.nvim_buf_is_valid(orig_buf) then pcall(vim.keymap.del, 'n', 'q', { buffer = orig_buf }) end
      if vim.api.nvim_win_is_valid(orig_win) then vim.api.nvim_win_call(orig_win, function() vim.cmd 'diffoff' end) end
    end,
  })

  vim.api.nvim_set_current_win(orig_win)
  vim.cmd 'diffthis'
end
vim.api.nvim_create_user_command('DiffOrig', diff_orig, { desc = 'Diff the buffer against the file on disk' })
vim.keymap.set('n', '<leader>gs', '<cmd>DiffOrig<CR>', { desc = '[G]it diff against [s]aved file (toggle)' })

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
  -- Unchanged lines get a grey block that doesn't match the transparent background. Drop
  -- it, keeping the grey cursor line (NeogitDiffContextCursor) so you can see where you are
  for _, name in ipairs { 'NeogitDiffContext', 'NeogitDiffContextHighlight' } do
    local context = vim.api.nvim_get_hl(0, { name = name, link = false })
    vim.api.nvim_set_hl(0, name, { fg = context.fg })
  end
  -- Changed words within a line: neogit's defaults are solid yellow/pink blocks that hide
  -- syntax colours. Instead, move the theme's line background 10% (0x19) towards its
  -- add/remove colour, as Monokai Pro's VS Code theme layers changed text over changed
  -- lines, with no fg so syntax colours show through. codediff uses these too (its
  -- char_insert/char_delete above)
  local function mix(a, b, amount)
    local channel = function(shift) return math.floor(bit.band(bit.rshift(a, shift), 255) * (1 - amount) + bit.band(bit.rshift(b, shift), 255) * amount + 0.5) end
    return bit.bor(bit.lshift(channel(16), 16), bit.lshift(channel(8), 8), channel(0))
  end
  for kind, theme in pairs { Add = { 'DiffAdd', 'Added' }, Delete = { 'DiffDelete', 'Removed' } } do
    local line = vim.api.nvim_get_hl(0, { name = theme[1], link = false }).bg
    local accent = vim.api.nvim_get_hl(0, { name = theme[2], link = false }).fg
    if line and accent then vim.api.nvim_set_hl(0, 'NeogitDiff' .. kind .. 'Inline', { bg = mix(line, accent, 0x19 / 255) }) end
  end
end
diff_backgrounds()
vim.api.nvim_create_autocmd('ColorScheme', { callback = diff_backgrounds })

vim.keymap.set('n', '<leader>gg', '<cmd>Neogit<CR>', { desc = '[G]it status (Neo[g]it)' })
vim.keymap.set('n', '<leader>gc', '<cmd>Neogit commit<CR>', { desc = '[G]it [c]ommit' })

require('which-key').add {
  { '<leader>g', group = '[G]it', mode = { 'n', 'v' } },
}
