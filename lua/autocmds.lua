vim.api.nvim_create_autocmd("FileType", { 
  pattern = "text",
  command = "setlocal commentstring=#\\ %s"
})

vim.api.nvim_create_autocmd("FileType", {
	  pattern = "sh,python,typescript,javascript,qml",
	  command = "setlocal commentstring=#\\ %s",
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

-- сброс подстветки поиска
vim.keymap.set('c', '<CR>', function()
  if vim.fn.getcmdtype() == ':' then
    vim.cmd('nohlsearch')  -- вызывает nohlsearch «в фоне», не показывая команду
  end
	return '<CR>'
end, { expr = true, noremap = true })
-- 
-- -- Авто-обновление Airline после VimEnter
-- vim.api.nvim_create_autocmd("VimEnter", {
-- 	  callback = function()
-- 	      vim.cmd("AirlineRefresh")
-- 		    e nd, 
-- })

vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    vim.cmd("startinsert")
  end,
})
