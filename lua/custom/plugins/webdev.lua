-- Language servers for Laravel / PHP / TypeScript / Vue / Tailwind
-- See `:help lspconfig-all` for each server's options

-- Install the servers with Mason if they're missing
local mason_packages = { 'intelephense', 'vtsls', 'vue-language-server', 'tailwindcss-language-server' }
local registry = require 'mason-registry'
registry.refresh(function()
  for _, name in ipairs(mason_packages) do
    local package = registry.get_package(name)
    if not package:is_installed() then package:install() end
  end
end)

-- vtsls handles TypeScript inside .vue files via the Vue TypeScript plugin,
-- while vue_ls handles the template and style sections ("hybrid mode")
-- See https://github.com/vuejs/language-tools/wiki/Neovim
local vue_plugin = {
  name = '@vue/typescript-plugin',
  location = vim.fn.expand '$MASON/packages' .. '/vue-language-server/node_modules/@vue/language-server',
  languages = { 'vue' },
  configNamespace = 'typescript',
  enableForWorkspaceTypeScriptVersions = true, -- also load the plugin when using the project's own TypeScript
}

vim.lsp.config('vtsls', {
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = { vue_plugin },
      },
    },
  },
  filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
})

-- intelephense's rename and code actions need a licence (https://intelephense.com);
-- swap for 'phpactor' for a free alternative
vim.lsp.enable { 'intelephense', 'vtsls', 'vue_ls', 'tailwindcss' }
