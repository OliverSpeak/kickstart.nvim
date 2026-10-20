local starter = require 'mini.starter'

starter.setup {
  -- A function so it re-runs each time the start screen opens
  header = function()
    local project = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
    local branch = vim.fn.system('git branch --show-current 2>/dev/null'):gsub('\n', '')
    return branch ~= '' and ('%s  ·  %s'):format(project, branch) or project
  end,
  items = {
    { name = 'Find file', action = 'Telescope find_files', section = 'Search' },
    { name = 'Grep project', action = 'Telescope live_grep', section = 'Search' },
    { name = 'Recent files', action = 'Telescope oldfiles', section = 'Search' },
    starter.sections.recent_files(5, true), -- recent files in this directory only
    starter.sections.builtin_actions(),     -- new buffer, quit
  },
  footer = os.date '%A %d %B',
  content_hooks = {
    starter.gen_hook.adding_bullet(),
    starter.gen_hook.aligning('center', 'center'),
  },
}
