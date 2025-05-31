vim.cmd [[
	call plug#begin(stdpath('data') . '/plugged')
"	Plug 'scrooloose/nerdtree'
	Plug 'preservim/nerdcommenter'
	Plug 'ryanoasis/vim-devicons'
	Plug 'tpope/vim-fugitive'
	Plug 'vim-airline/vim-airline'
	Plug 'vim-airline/vim-airline-themes'
	Plug 'neoclide/coc.nvim'
	Plug 'lambdalisue/suda.vim'
	Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
	Plug 'junegunn/fzf.vim'
	Plug 'rhysd/conflict-marker.vim'
	Plug 'lewis6991/gitsigns.nvim'
	Plug 'kyazdani42/nvim-tree.lua'
	Plug 'kyazdani42/nvim-web-devicons'
	Plug 'nvim-lua/plenary.nvim'
	Plug 'nvim-telescope/telescope.nvim', {'tag': '0.1.3'}
	call plug#end()
]]

-- 2) Настройка nvim-tree (убираем adaptive_size!)
require("nvim-tree").setup {
  disable_netrw       = true,
  hijack_netrw        = true,
  update_focused_file = { enable = true, update_root = true },
  view = {
    width         = 30,
    side          = "left",
    adaptive_size = false,  -- 👈 Важно: ОТКЛЮЧАЕМ adaptive_size
  },
  filters = {
    dotfiles = false,
    custom   = { "^.git$" },
  },
  hijack_directories = {
    enable    = true,
    auto_open = false,      -- 👈 Выключаем встроенное авто-открытие
  },
}
