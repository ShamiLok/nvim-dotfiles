vim.g.mapleader = ","

vim.opt.encoding = "utf-8"
vim.opt.compatible = false

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false
vim.opt.smarttab = true
vim.opt.autoindent = true
vim.opt.smartindent = true

vim.opt.number = true
vim.opt.relativenumber = false

vim.opt.wildmode = { "longest", "list" }

vim.cmd("syntax on")
vim.opt.foldmethod		= "indent" -- фолд по табам
vim.opt.foldnestmax		= 1 -- уровни вложенности
vim.opt.foldminlines	= 20 -- количество строк для фолда
vim.opt.foldlevel		= 1 -- по умолчанию все будет свернуто на уровень 1

vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.ttyfast = true
vim.opt.scrolloff = 30

vim.cmd("filetype plugin indent on")

vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.cmd("highlight CursorLineNr cterm=bold ctermfg=Yellow guifg=#FFD700 gui=bold")

vim.opt.list = true
vim.opt.listchars = {
  space = '·',
  tab = '→ ',
  trail = '·',
  nbsp = '␣',
  eol = '↴'
}

-- vim.cmd('packadd vim-fugitive')

-- airline
vim.g["airline#extensions#tabline#enabled"] = 1
vim.g.airline_powerline_fonts = 1
vim.g.airline_statusline_ontop = 0
vim.g.airline_theme = 'deus'
vim.g["airline#extensions#tabline#formatter"] = 'default'
vim.g["airline#extensions#coc#enabled"] = 0

-- 1) Включаем родное расширение веток
vim.g["airline#extensions#branch#enabled"]   = 1
-- отключаем показ статистики
vim.g["airline#extensions#branch#show_state"] = 0
-- 2) Форматируем так: 🔀 %s в имени ветки, и добавляем ⚡ если есть нечёрные изменения
vim.g["airline#extensions#branch#formatter"] = " %s%{len(getbufvar(bufnr('%'), '&mod')) and '⚡' or ''}"

vim.g.airline_section_c = ''  -- Убирает текущий файл (lua/options.lua)
vim.g.airline_section_x = '%{&filetype}'  -- Убирает тип файла (Lua)
vim.g.airline_section_y = ''  -- Убирает формат файла ([unix])
vim.g.airline_section_z = ''  -- Процент прокрутки

