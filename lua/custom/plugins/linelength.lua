-- Line length guide that only appears while a line in the file goes past it. Widths match
-- what each formatter enforces; a project's .editorconfig max_line_length wins over these.
-- Only real files get it (empty 'buftype'): plugin UIs like Neogit, codediff, oil and the
-- start screen all set a buftype, so none of them need listing. See `:help 'colorcolumn'`
local default_width = 80 -- prettier's default printWidth, for JS / TS / Vue / Svelte / CSS
local widths = {
  php = 120, -- PSR-12, which pint follows
  lua = 160, -- column_width in .stylua.toml
  gitcommit = 72, -- git's convention for commit message bodies
}
local skip_filetypes = { text = true, markdown = true } -- prose, where long lines are normal

local function width(buf)
  local editorconfig = vim.b[buf].editorconfig
  return editorconfig and tonumber(editorconfig.max_line_length) -- nil when 'off'
    or widths[vim.bo[buf].filetype]
    or default_width
end

local function too_long(buf, limit)
  for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    if vim.fn.strdisplaywidth(line) > limit then return true end
  end
  return false
end

local function update(buf)
  local colorcolumn = ''
  if vim.bo[buf].buftype == '' and not skip_filetypes[vim.bo[buf].filetype] then
    local limit = width(buf)
    if too_long(buf, limit) then colorcolumn = tostring(limit) end
  end
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.wo[win].colorcolumn = colorcolumn
  end
end

-- Rechecked when the text changes rather than on every cursor move, since the whole file
-- is checked; BufWinEnter also clears a guide left by the window's previous buffer
vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinEnter', 'FileType', 'TextChanged', 'TextChangedI' }, {
  group = vim.api.nvim_create_augroup('LineLengthGuide', {}),
  callback = function(args) update(args.buf) end,
})
