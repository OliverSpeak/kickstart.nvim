local starter = require 'mini.starter'

starter.setup {
  -- A function so it re-runs each time the start screen opens
  header = function()
    local project = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
    local branch = vim.fn.system('git branch --show-current 2>/dev/null'):gsub('\n', '')
    return branch ~= '' and ('%s  ·  %s'):format(project, branch) or project
  end,
  items = {
    starter.sections.sessions(5, true), -- most recently used sessions
    starter.sections.recent_files(5, true), -- recent files in this directory only
  },
  -- Empty rather than unset, which would show mini.starter's usage help
  footer = '',
  content_hooks = {
    starter.gen_hook.adding_bullet(),
    starter.gen_hook.aligning('center', 'center'),
  },
}
