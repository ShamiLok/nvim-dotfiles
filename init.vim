let mapleader=","

" Кодировка UTF-8
set encoding=utf8

" Отключение совместимости с vi. Нужно для правильной работы некоторых опций
set nocompatible

" Игнорировать регистр при поиске
set ignorecase

" Не игнорировать регистр, если в паттерне есть большие буквы
set smartcase

" Подсвечивать найденный паттерн
set hlsearch

" Интерактивный поиск
set incsearch

" Размер табов
set tabstop=4
set softtabstop=4
set shiftwidth=4

" корректная табуляция
set noexpandtab

" Таб перед строкой будет вставлять количество пробелов определённое в shiftwidth
set smarttab

" Копировать отступ на новой строке
set autoindent
set smartindent

" Показывать номера строк
set number

" Относительные номера строк
set norelativenumber

" Автокомплиты в командной строке
set wildmode=longest,list

" Подсветка синтаксиса
syntax on
set foldmethod=indent

" Разрешить использование мыши
set mouse=a

" Использовать системный буфер обмена
set clipboard=unnamedplus

" Быстрый скроллинг
set ttyfast

" Курсор во время скроллинга будет всегда в середине экрана
set so=30

" Встроенный плагин для распознавания отступов
filetype plugin indent on

" Подсветка строки текущей строки
set cursorline
set cursorlineopt=number
highlight CursorLineNr cterm=bold ctermfg=Yellow guifg=#FFD700 gui=bold

call plug#begin( stdpath('data') . '/plugged' )
Plug 'scrooloose/nerdtree'
Plug 'preservim/nerdcommenter'
Plug 'ryanoasis/vim-devicons'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'neoclide/coc.nvim'
Plug 'lambdalisue/suda.vim'
Plug 'karb94/neoscroll.nvim'       " для плавной прокрутки
Plug 'psliwka/vim-smoothie'        " для плавных переходов
call plug#end()

" neoscroll
lua << EOF
require('neoscroll').setup()
-- (опционально) mappings…
EOF

" 1) Для обычных текстовых файлов — комментарий "# "
autocmd FileType text    setlocal commentstring=#\ %s

" 2) Для любых буферов без распознанного FileType (например, файл без расширения)
autocmd BufReadPost,BufNewFile * if &filetype == '' | setlocal commentstring=#\ %s | endif

" 3) (Опционально) Если хочешь, чтобы файлы без расширения сразу считались текстовыми
"    и при этом работали другие текстовые фичи:
autocmd BufReadPost,BufNewFile * if &filetype == '' | setlocal filetype=text | endif

" Автоматическое открытие NERDTree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * NERDTree | wincmd p

" Включить/выключить NERDTree при нажатии \n
nnoremap <leader>n :NERDTreeToggle<CR>
" Юникодные иконки папок (Работает только с плагином vim-devicons)
let g:WebDevIconsUnicodeDecorateFolderNodes = 1
" Показывает количество строк в файлах
let g:NERDTreeFileLines = 1
" Игнорировать указанные папки
let g:NERDTreeIgnore = ['^node_modules$', '^__pycache__$']
" Закрыть vim, если единственная вкладка - это NERDTree
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_statusline_ontop=0
let g:airline_theme='deus'
let g:airline#extensions#tabline#formatter = 'default'

" Автокомплиты через Tab
inoremap <expr> <Tab> coc#pum#visible() ? coc#pum#confirm() : "\<Tab>"

" Close terminal on esc btn
tnoremap <Esc> <C-\><C-n>

" Включаем отображение скрытых символов
set list
" Настраиваем отображение символов:
" таб — → , пробел — · , конец строки — ↴
set listchars=space:·,tab:→\ ,trail:·,nbsp:␣,eol:↴
