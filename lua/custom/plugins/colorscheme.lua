vim.pack.add { 'https://github.com/sainnhe/sonokai' }

-- Options must be set before the colorscheme loads. See `:help sonokai`
vim.g.sonokai_style = 'shusia' -- or 'atlantis', 'andromeda', 'shusia', 'maia', 'espresso'
vim.cmd.colorscheme 'sonokai'
