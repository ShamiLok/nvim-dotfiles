-- vim.o.langmap = "й,q,ц,w,у,e,к,r,е,t,н,y,г,u,ш,i,щ,o,з,p,х,[,ъ,],ф,a,ы,s,в,d,а,f,п,g,р,h,р,j,о,k,л,l,д,z,ж,x,э,c,я,v,ч,b,с,n,ш,m,м,<,я,>,ё"
-- vim.keymap.set("n", "<leader>n", ":NERDTreeToggle<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>n", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- В Normal mode: вставка текста из буфера обмена перед курсором
vim.keymap.set('n', '<C-v>', '"+P', { noremap = true })

-- В Insert mode: вставка текста из буфера обмена в позиции курсора
vim.keymap.set('i', '<C-v>', '<C-r>+', { noremap = true })

-- В Command-line mode: вставка текста из буфера обмена в командной строке
vim.keymap.set('c', '<C-v>', '<C-r>+', { noremap = true })

-- вставка в visual mode
vim.keymap.set('v', '<C-v>', '"+P', { noremap = true })

-- Tab autocomplete with CoC
vim.api.nvim_set_keymap("i", "<Tab>", "coc#pum#visible() ? coc#pum#confirm() : '<Tab>'", { noremap = true, expr = true, silent = true })

-- Close terminal with ESC
vim.api.nvim_set_keymap("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })

-- global files search 
--vim.api.nvim_set_keymap('n', '<leader>f', ':Files<CR>', { noremap = true, silent = true })

-- global text search
--vim.api.nvim_set_keymap('n', '<leader>r', ':Rg ', { noremap = true })


local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>f', builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set('n', '<leader>r', builtin.live_grep,  { desc = "Telescope live grep" })

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
