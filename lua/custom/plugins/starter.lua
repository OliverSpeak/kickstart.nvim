-- Start screen: project and branch, then recent sessions and files. See `:help alpha`
-- Move with j/k, press <CR> or an item's key to open it
vim.pack.add { 'https://github.com/goolord/alpha-nvim' }

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
      width = 50,
      cursor = 0,
      keymap = { 'n', key, action, { nowait = true, silent = true } },
    },
  }
end

-- Padded to the item width so it lines up with the left edge of the items below
local function heading(text) return { type = 'text', val = ('%-50s'):format(text), opts = { position = 'center', hl = 'Red' } } end

local function sessions()
  local detected = vim.tbl_values(require('mini.sessions').detected)
  table.sort(detected, function(a, b) return a.modify_time > b.modify_time end)
  local items = {}
  for i, session in ipairs(vim.list_slice(detected, 1, 5)) do
    items[i] = item(tostring(i), session.name, function() require('mini.sessions').read(session.name) end)
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
      table.insert(items, item(key, vim.fn.fnamemodify(path, ':.'), function() vim.cmd.edit(vim.fn.fnameescape(path)) end))
    end
  end
  return items
end

require('alpha').setup {
  layout = {
    { type = 'padding', val = function() return math.floor(vim.o.lines * 0.3) end },
    {
      type = 'text',
      val = function()
        local project = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
        local branch = vim.fn.system('git branch --show-current 2>/dev/null'):gsub('\n', '')
        return branch ~= '' and ('%s  ·  %s'):format(project, branch) or project
      end,
      opts = { position = 'center', hl = 'Title' },
    },
    { type = 'padding', val = 1 },
    heading 'Sessions',
    { type = 'group', val = sessions, opts = { spacing = 0 } },
    { type = 'padding', val = 1 },
    heading 'Recent files',
    { type = 'group', val = recent_files, opts = { spacing = 0 } },
  },
}
