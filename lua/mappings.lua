-- vim.o.langmap = "й,q,ц,w,у,e,к,r,е,t,н,y,г,u,ш,i,щ,o,з,p,х,[,ъ,],ф,a,ы,s,в,d,а,f,п,g,р,h,р,j,о,k,л,l,д,z,ж,x,э,c,я,v,ч,b,с,n,ш,m,м,<,я,>,ё"
-- vim.keymap.set("n", "<leader>n", ":NERDTreeToggle<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>n", ":Neotree toggle<CR>", { noremap = true, silent = true })

-- В Normal mode: вставка текста из буфера обмена перед курсором
vim.keymap.set('n', '<C-v>', '"+P', { noremap = true })

-- В Insert mode: вставка текста из буфера обмена в позиции курсора
vim.keymap.set('i', '<C-v>', '<C-o>:set paste<CR><C-r>+<C-o>:set nopaste<CR>', { noremap = true })

-- В Command-line mode: вставка текста из буфера обмена в командной строке
vim.keymap.set('c', '<C-v>', '<C-r>+', { noremap = true })

-- вставка в visual mode
vim.keymap.set('v', '<C-v>', '"+P', { noremap = true })

-- Tab autocomplete with CoC
-- vim.api.nvim_set_keymap("i", "<Tab>", "coc#pum#visible() ? coc#pum#confirm() : '<Tab>'", { noremap = true, expr = true, silent = true })

-- Close terminal with ESC
vim.api.nvim_set_keymap("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })

-- global files search 
--vim.api.nvim_set_keymap('n', '<leader>f', ':Files<CR>', { noremap = true, silent = true })

-- global text search
--vim.api.nvim_set_keymap('n', '<leader>r', ':Rg ', { noremap = true })


local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>f', builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set('n', '<leader>R', builtin.live_grep,  { desc = "Telescope search" })
vim.keymap.set('n', '<leader>r', function()
	builtin.live_grep({
		vimgrep_arguments = {
		  "rg", "--color=never", "--no-heading", "--with-filename",
		  "--line-number", "--column", "--smart-case", "--fixed-strings"
		},
	})
end, { desc = "Telescope search" })

-- switch buffer
vim.api.nvim_set_keymap('n', '<leader>l', ':bnext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>h', ':bprevious<CR>', { noremap = true, silent = true })

--comments 
vim.keymap.set("n", "<leader>c", "<Plug>NERDCommenterToggle", {})
vim.keymap.set("v", "<leader>c", "<Plug>NERDCommenterToggle", {})

-- get changes
vim.api.nvim_set_keymap('n', '<leader>g', ':Gitsigns preview_hunk<CR>', { noremap = true, silent = true })

-- vsplit
vim.keymap.set("n", "<leader>v", ":vsplit<Space>", { noremap = true, silent = true })

-- ⌘+= / Ctrl+= (в зависимости от платформы) — увеличить масштаб
vim.keymap.set('n', '<C-=>', function()
	vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1
end, { silent = true, desc = "Neovide: zoom in" })

-- ⌘+- / Ctrl+- — уменьшить масштаб
vim.keymap.set('n', '<C-->', function()
	vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1
end, { silent = true, desc = "Neovide: zoom out" })

-- W == w Q == w
vim.cmd([[command! W w]])
vim.cmd([[command! Q q]])

-- Навигация в командной строке (command-line mode) с помощью Ctrl + hjkl
vim.keymap.set('c', '<C-h>', '<Left>',  { noremap = true })
vim.keymap.set('c', '<C-l>', '<Right>', { noremap = true })
vim.keymap.set('c', '<C-j>', '<Down>',  { noremap = true })
vim.keymap.set('c', '<C-k>', '<Up>',    { noremap = true })

vim.keymap.set('n', 'x', '"_x', { noremap = true }) -- удаление x всегда в black hole
vim.keymap.set('v', 'x', '"_x', { noremap = true }) -- удаление x всегда в black hole
