vim.pack.add { 'https://github.com/sainnhe/sonokai' }

-- Options must be set before the colorscheme loads. See `:help sonokai`
vim.g.sonokai_style = 'shusia' -- or 'atlantis', 'andromeda', 'shusia', 'maia', 'espresso'
vim.g.sonokai_transparent_background = 1 -- let the terminal background show through; 2 also clears UI bars
-- Monokai Pro (Filter Spectrum) colours, so nvim matches the terminal, Claude Code and
-- delta. Text and accents are from the official Sublime/VS Code themes (dotfiles
-- themes/); diff backgrounds are VS Code's 10% green/pink over #222222. Each entry is
-- { gui, cterm }; cterm values are sonokai's own
vim.g.sonokai_colors_override = {
  fg = { '#f7f1ff', '250' },
  red = { '#fc618d', '203' },
  orange = { '#fd9353', '215' },
  yellow = { '#fce566', '179' },
  green = { '#7bd88f', '107' },
  blue = { '#5ad4e6', '110' },
  purple = { '#948ae3', '176' },
  bg_green = { '#2b342d', '22' }, -- DiffAdd
  bg_red = { '#37282c', '52' }, -- DiffDelete
}
vim.cmd.colorscheme 'sonokai'
