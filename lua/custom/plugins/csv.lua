-- CSV and TSV files shown as a table: csvview lines the columns up with virtual text,
-- so the file itself is unchanged, and draws the delimiters as │. The header row stays
-- at the top while scrolling. It turns on by itself for csv/tsv files;
-- `:CsvViewToggle` shows the raw file, or turns it on for other delimited files.
-- See `:help csvview`
vim.pack.add { 'https://github.com/hat0uma/csvview.nvim' }
require('csvview').setup {
  view = { display_mode = 'border' },
  -- Only while the table view is on, so these keys keep their usual meaning elsewhere
  keymaps = {
    -- A field as a text object, e.g. `cif` changes the field under the cursor and
    -- `daf` deletes it with its delimiter
    textobject_field_inner = { 'if', mode = { 'o', 'x' } },
    textobject_field_outer = { 'af', mode = { 'o', 'x' } },
    -- Move like a spreadsheet: tab and shift+tab between fields, enter and
    -- shift+enter between rows, staying in the same column
    jump_next_field_end = { '<Tab>', mode = { 'n', 'v' } },
    jump_prev_field_end = { '<S-Tab>', mode = { 'n', 'v' } },
    jump_next_row = { '<Enter>', mode = { 'n', 'v' } },
    jump_prev_row = { '<S-Enter>', mode = { 'n', 'v' } },
  },
}

-- Each column in its own colour, so one is easy to follow across a wide table, with
-- the │ borders in grey so they don't compete with the data, and the header in bold.
-- csvview takes its column colours from Vim's csv syntax file, which treesitter
-- replaces here, so without this they're all plain text. It cycles through 9, so the
-- theme's six colours (lua/custom/plugins/colorscheme.lua) go round one and a half
-- times; neighbouring columns always differ
local column_colours = { 'Red', 'Orange', 'Yellow', 'Green', 'Blue', 'Purple', 'Red', 'Orange', 'Yellow' }
local function csv_colours()
  for i, group in ipairs(column_colours) do
    vim.api.nvim_set_hl(0, 'CsvViewCol' .. (i - 1), { link = group })
  end
  for _, name in ipairs { 'CsvViewDelimiter', 'CsvViewStickyHeaderSeparator' } do
    vim.api.nvim_set_hl(0, name, { link = 'Grey' })
  end
  vim.api.nvim_set_hl(0, 'CsvViewHeaderLine', { bold = true })
end
csv_colours()
vim.api.nvim_create_autocmd('ColorScheme', { callback = csv_colours })

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'csv', 'tsv' },
  callback = function(args) require('csvview').enable(args.buf) end,
})

-- Which column the cursor is in, for the statusline (lua/custom/plugins/statusline.lua),
-- since the table has no column numbers of its own: e.g. `col 3/5: city`, with the
-- header's name for it when there's a header row. Empty outside the table view.
-- csvview has no public API for the header, so this reads its view and stays empty
-- if an update moves it
local M = {}

function M.column()
  local ok, cursor = pcall(require('csvview.util').get_cursor)
  if not ok or cursor.kind ~= 'field' then return '' end
  local col = cursor.pos[2]
  local view = require('csvview.view').get(0)
  local text = ('col %d/%d'):format(col, view.metrics:column_count())
  local found, fields = pcall(function() return view.header_lnum and view.metrics:get_logical_row_fields { lnum = view.header_lnum } end)
  local field = found and fields and fields[col]
  if field then
    local name = table.concat(vim.api.nvim_buf_get_text(0, field.start_row - 1, field.start_col, field.end_row - 1, field.end_col, {}), ' ')
    name = vim.trim(name:gsub('^"(.*)"$', '%1'))
    if name ~= '' then text = text .. ': ' .. name end
  end
  return text
end

return M
