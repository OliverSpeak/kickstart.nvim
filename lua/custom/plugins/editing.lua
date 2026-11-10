-- Typing an opening bracket or quote inserts its closing pair; typing the closing one
-- steps over it, and <BS> between an empty pair deletes both. See `:help mini.pairs`
require('mini.pairs').setup()

-- Typing the `>` of an opening HTML tag adds its closing tag, and renaming either tag
-- of a pair renames the other. Works in HTML, Vue, Svelte, JSX/TSX and Blade, in any
-- buffer with a treesitter parser. See `:help nvim-ts-autotag`
vim.pack.add { 'https://github.com/windwp/nvim-ts-autotag' }
require('nvim-ts-autotag').setup {}
