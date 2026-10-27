-- Start screen: project and git status, then recent sessions and files. See `:help alpha`
-- Move with j/k, press <CR> or an item's key to open it
vim.pack.add { 'https://github.com/goolord/alpha-nvim' }

-- Items are 50 columns, or less in a narrow window. alpha pads each item's text to
-- this width with its key on the right; anything longer pushes the key out and the
-- row out of line, so text is shortened to fit first (see fit_path/fit_text)
local function row_width() return math.max(20, math.min(50, vim.api.nvim_win_get_width(0) - 4)) end

-- Room for an item's text: the row less its one-character key and a two-space gap
local function text_width() return row_width() - 3 end

-- Cut from the end with an ellipsis
local function fit_text(text, max)
  if vim.fn.strchars(text) <= max then return text end
  return vim.fn.strcharpart(text, 0, max - 1) .. '…'
end

-- Shorten folders to their first letter (keeping a leading dot), leftmost first and
-- only as far as needed, so the file name stays whole: r/j/components/ui/button.tsx.
-- If even that is too long, keep the end of the path after an ellipsis
local function fit_path(path, max)
  if vim.fn.strchars(path) <= max then return path end
  local parts = vim.split(path, '/', { plain = true })
  for i = 1, #parts - 1 do
    parts[i] = parts[i]:match '^%.?[^.]?' or parts[i]
    local shortened = table.concat(parts, '/')
    if vim.fn.strchars(shortened) <= max then return shortened end
  end
  local shortened = table.concat(parts, '/')
  return '…' .. vim.fn.strcharpart(shortened, vim.fn.strchars(shortened) - (max - 1))
end

local function item(key, text, action)
  return {
    type = 'button',
    val = text,
    on_press = action,
    opts = {
      position = 'center',
      shortcut = key,
      align_shortcut = 'right',
      hl_shortcut = 'Keyword',
      width = row_width(),
      cursor = 0,
      keymap = { 'n', key, action, { nowait = true, silent = true } },
    },
  }
end

-- Padded to the item width so it lines up with the left edge of the items below. A
-- function, so the width follows the window when alpha redraws
local function heading(text)
  return {
    type = 'group',
    val = function() return { { type = 'text', val = ('%-' .. row_width() .. 's'):format(text), opts = { position = 'center', hl = 'Red' } } } end,
  }
end

local function sessions()
  local detected = vim.tbl_values(require('mini.sessions').detected)
  table.sort(detected, function(a, b) return a.modify_time > b.modify_time end)
  local items = {}
  for i, session in ipairs(vim.list_slice(detected, 1, 5)) do
    items[i] = item(tostring(i), fit_text(session.name, text_width()), function() require('mini.sessions').read(session.name) end)
  end
  return items
end

-- Recent files in this directory only
local function recent_files()
  local cwd = vim.fn.getcwd() .. '/'
  local items = {}
  for _, path in ipairs(vim.v.oldfiles) do
    if #items == 5 then break end
    if vim.startswith(path, cwd) and vim.fn.filereadable(path) == 1 then
      local key = string.char(('a'):byte() + #items)
      table.insert(items, item(key, fit_path(vim.fn.fnamemodify(path, ':.'), text_width()), function() vim.cmd.edit(vim.fn.fnameescape(path)) end))
    end
  end
  return items
end

-- Branch, upstream and file status with the same symbols and colours as the p10k prompt:
-- ⇣behind ⇡ahead ⇠⇢ push remote *stashes ~conflicted +staged !unstaged ?untracked, e.g. `master ⇡1 +2 !3 ?1`
-- Returns a list of { text, highlight } segments, or nil outside a repo
local function git_summary()
  local lines = vim.fn.systemlist 'git status --porcelain=v2 --branch --show-stash 2>/dev/null'
  if vim.v.shell_error ~= 0 then return nil end
  local branch = ''
  local n = { behind = 0, ahead = 0, stash = 0, conflicted = 0, staged = 0, unstaged = 0, untracked = 0 }
  for _, line in ipairs(lines) do
    if line:match '^# branch.head ' then
      branch = line:sub(15)
    elseif line:match '^# branch.ab ' then
      local ahead, behind = line:match '%+(%d+) %-(%d+)'
      n.ahead, n.behind = tonumber(ahead), tonumber(behind)
    elseif line:match '^# stash ' then
      n.stash = tonumber(line:sub(9))
    elseif line:match '^u ' then
      n.conflicted = n.conflicted + 1
    elseif line:match '^[12] ' then
      if line:sub(3, 3) ~= '.' then n.staged = n.staged + 1 end
      if line:sub(4, 4) ~= '.' then n.unstaged = n.unstaged + 1 end
    elseif line:match '^%? ' then
      n.untracked = n.untracked + 1
    end
  end
  local segments = { { branch, 'Purple' } }
  local sync = (n.behind > 0 and ('⇣' .. n.behind) or '') .. (n.ahead > 0 and ('⇡' .. n.ahead) or '')
  if sync ~= '' then table.insert(segments, { sync, 'Green' }) end
  -- Like p10k (gitstatus), only count against the push remote when one is configured, comparing
  -- with <push remote>/<branch> rather than @{push}, which some push.default settings can't resolve
  local function config(key) return vim.fn.systemlist({ 'git', 'config', key })[1] end
  local push_remote = branch ~= '(detached)' and (config('branch.' .. branch .. '.pushRemote') or config 'remote.pushDefault')
  if push_remote then
    local ref = ('refs/remotes/%s/%s'):format(push_remote, branch)
    local counts = vim.fn.systemlist({ 'git', 'rev-list', '--left-right', '--count', ref .. '...HEAD' })[1] or ''
    local push_behind, push_ahead = counts:match '^(%d+)%s+(%d+)$'
    if push_behind then
      local push = (push_behind ~= '0' and ('⇠' .. push_behind) or '') .. (push_ahead ~= '0' and ('⇢' .. push_ahead) or '')
      if push ~= '' then table.insert(segments, { push, 'Green' }) end
    end
  end
  for _, field in ipairs {
    { 'stash', '*', 'Green' },
    { 'conflicted', '~', 'Red' },
    { 'staged', '+', 'Yellow' },
    { 'unstaged', '!', 'Yellow' },
    { 'untracked', '?', 'Blue' },
  } do
    local count = n[field[1]]
    if count > 0 then table.insert(segments, { field[2] .. count, field[3] }) end
  end
  return segments
end

-- `project  ·  branch status`, each git segment in its own colour
local function header()
  local text = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
  local hl = { { 'Purple', 0, #text } }
  for i, segment in ipairs(git_summary() or {}) do
    if i == 1 then
      hl[1][3] = #text + #'  ·  ' -- the separator is purple along with the project name
      text = text .. '  ·  '
    else
      text = text .. ' '
    end
    table.insert(hl, { segment[2], #text, #text + #segment[1] })
    text = text .. segment[1]
  end
  return { { type = 'text', val = text, opts = { position = 'center', hl = hl } } }
end

require('alpha').setup {
  layout = {
    { type = 'padding', val = function() return math.floor(vim.o.lines * 0.3) end },
    { type = 'group', val = header },
    { type = 'padding', val = 1 },
    heading 'Sessions',
    { type = 'group', val = sessions, opts = { spacing = 0 } },
    { type = 'padding', val = 1 },
    heading 'Recent files',
    { type = 'group', val = recent_files, opts = { spacing = 0 } },
  },
}
