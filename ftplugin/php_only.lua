-- Not a real filetype: `php_only` is the treesitter language for PHP inside Blade's
-- @php blocks and directive arguments. Commenting looks up a language's comment style
-- through a filetype of the same name, so this gives `gcc` PHP comments there
vim.bo.commentstring = '// %s'
