vim.api.nvim_create_autocmd("FileType", {
  pattern = "text",
  command = "setlocal commentstring=#\\ %s"
})

vim.api.nvim_create_autocmd({"BufReadPost", "BufNewFile"}, {
  pattern = "*",
  callback = function()
    if vim.bo.filetype == "" then
      vim.bo.commentstring = "# %s"
      vim.bo.filetype = "text"
    end
  end
})

-- auto nerdtree refresh
vim.api.nvim_create_autocmd("FocusGained", {
	pattern = "*",
	command = "NERDTreeRefreshRoot"
})
