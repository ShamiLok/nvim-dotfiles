
vim.api.nvim_create_autocmd("StdinReadPre", {
  pattern = "*",
  command = "let s:std_in=1"
})
vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  command = "NERDTree | wincmd p"
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  command = [[if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif]]
})

vim.g.WebDevIconsUnicodeDecorateFolderNodes = 1
vim.g.NERDTreeFileLines = 1
vim.g.NERDTreeIgnore = { '^node_modules$', '^__pycache__$' }
