vim.cmd [[
	call plug#begin(stdpath('data') . '/plugged')
	" комменты
	" TODO: Comment.nvim
	Plug 'preservim/nerdcommenter'
	" git
	Plug 'tpope/vim-fugitive'
	" bar
	Plug 'vim-airline/vim-airline'
		Plug 'vim-airline/vim-airline-themes'
	" load extensions and language servers
	" Plug 'neoclide/coc.nvim'
	" action at sudo
	Plug 'lambdalisue/suda.vim'
	" git conflicts 
	Plug 'rhysd/conflict-marker.vim'
	" git intergation
	Plug 'lewis6991/gitsigns.nvim'
	" file manager
	" Plug 'kyazdani42/nvim-tree.lua'
	" nvim-tree requirements
	" Plug 'kyazdani42/nvim-web-devicons'
	" new file manager
	Plug 'nvim-neo-tree/neo-tree.nvim'
		" neo-tree and telescope requirement
		Plug 'nvim-lua/plenary.nvim'
		" neo-tree reccommended requirement
		Plug 'nvim-tree/nvim-web-devicons'
		" neo-tree reuirement
		Plug 'MunifTanjim/nui.nvim'
	" global search
	Plug 'nvim-telescope/telescope.nvim',
	" start window
	Plug 'goolord/alpha-nvim'
	" completion lsp snippets
	Plug 'neovim/nvim-lspconfig'
	Plug 'hrsh7th/cmp-nvim-lsp'
	Plug 'hrsh7th/vim-vsnip'
	Plug 'hrsh7th/nvim-cmp'
	Plug 'rafamadriz/friendly-snippets'
	" подсветка слов/блоков
	Plug 'echasnovski/mini.nvim'
	Plug 'norcalli/nvim-colorizer.lua'
	call plug#end()
]]

require('mini.cursorword').setup() -- подстветка слов
require('mini.indentscope').setup() -- выделение текущего блока/функции по табам

-- 2) Настройка nvim-tree (убираем adaptive_size!)
-- require("nvim-tree").setup {
--   disable_netrw       = true,
--   hijack_netrw        = true,
--   update_focused_file = { enable = true, update_root = true },
--   view = {
--     width         = 30,
--     side          = "left",
--     adaptive_size = false,  -- 👈 Важно: ОТКЛЮЧАЕМ adaptive_size
--   },
--   filters = {
--     dotfiles = false,
--     custom   = { "^.git$" },
--   },
--   hijack_directories = {
--     enable    = true,
--     auto_open = false,      -- 👈 Выключаем встроенное авто-открытие
--   },
-- }

-- default config from github:
-- Attaches to every FileType mode
require 'colorizer'.setup()

-- Attach to certain Filetypes, add special configuration for `html`
-- Use `background` for everything else.
require 'colorizer'.setup {
  'css';
  'javascript';
  html = {
    mode = 'foreground';
  }
}

-- Use the `default_options` as the second parameter, which uses
-- `foreground` for every mode. This is the inverse of the previous
-- setup configuration.
require 'colorizer'.setup({
  'css';
  'javascript';
  html = { mode = 'background' };
}, { mode = 'foreground' })

-- Use the `default_options` as the second parameter, which uses
-- `foreground` for every mode. This is the inverse of the previous
-- setup configuration.
require 'colorizer'.setup {
  '*'; -- Highlight all files, but customize some others.
  css = { rgb_fn = true; }; -- Enable parsing rgb(...) functions in css.
  html = { names = false; } -- Disable parsing "names" like Blue or Gray
}

-- Exclude some filetypes from highlighting by using `!`
require 'colorizer'.setup {
  '*'; -- Highlight all files, but customize some others.
  '!vim'; -- Exclude vim from highlighting.
  -- Exclusion Only makes sense if '*' is specified!
}
