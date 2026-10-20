vim.pack.add { 'https://github.com/sainnhe/sonokai' }

-- Options must be set before the colorscheme loads. See `:help sonokai`
vim.g.sonokai_style = 'shusia' -- or 'atlantis', 'andromeda', 'shusia', 'maia', 'espresso'
vim.g.sonokai_transparent_background = 1 -- let the terminal background show through; 2 also clears UI bars
vim.cmd.colorscheme 'sonokai'
