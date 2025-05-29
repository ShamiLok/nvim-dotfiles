vim.cmd [[
	call plug#begin(stdpath('data') . '/plugged')
	Plug 'scrooloose/nerdtree'
	Plug 'preservim/nerdcommenter'
	Plug 'ryanoasis/vim-devicons'
	Plug 'vim-airline/vim-airline'
	Plug 'vim-airline/vim-airline-themes'
	Plug 'neoclide/coc.nvim'
	Plug 'lambdalisue/suda.vim'
	Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
	Plug 'junegunn/fzf.vim'
	Plug 'tpope/vim-fugitive'
	Plug 'rhysd/conflict-marker.vim'
	Plug 'lewis6991/gitsigns.nvim'
	call plug#end()
]]
