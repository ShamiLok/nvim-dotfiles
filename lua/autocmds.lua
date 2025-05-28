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
--vim.api.nvim_create_autocmd("FocusGained", {
--	pattern = "*",
--	command = "NERDTreeRefreshRoot"
--})


-- после того как setup уже отработал:
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function(data)
    -- если Neovim запустили на директории, то откроем её
    if vim.fn.isdirectory(data.file) == 1 then
      require("nvim-tree.api").tree.open { dir = data.file }
    else
      -- иначе просто откроем корень проекта
      require("nvim-tree.api").tree.open {}
    end
  end
})
