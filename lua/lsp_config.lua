local lspconfig = require('lspconfig')
local configs   = require('lspconfig.configs')
local util      = require('lspconfig.util')
local lsp_path = vim.fn.stdpath("config") .. "/pureqml-lsp/myqtjs_lsp.py"

if not configs.myqtjs then
  configs.myqtjs = {
    default_config = {
      cmd       = { 'python', lsp_path},
      filetypes = { 'qml' },
      root_dir  = function(fname)
        return util.root_pattern('.git', 'src')(fname) or util.path.dirname(fname)
      end,
      settings = {},
    },
  }
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument = {
  completion = { completionItem = { snippetSupport = true } }
}
local cmp_lsp_ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if cmp_lsp_ok then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

lspconfig.myqtjs.setup {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr })
  end,
  flags = { debounce_text_changes = 150 },
}
