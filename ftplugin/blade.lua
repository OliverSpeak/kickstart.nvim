-- Neovim ships no settings for Blade, so `gcc` / `gc` have no comment style to use.
-- Embedded <script>, <style> and @php blocks still get their own via treesitter
vim.bo.commentstring = '{{-- %s --}}'
