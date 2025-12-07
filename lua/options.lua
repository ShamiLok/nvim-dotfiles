vim.g.mapleader = ","
vim.o.shellredir = ">%s 2>&1"
vim.o.shellpipe  = ">%s 2>&1"

vim.opt.encoding = "utf-8"
vim.opt.compatible = false

vim.opt.ignorecase = true
vim.opt.smartcase = false
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
vim.opt.relativenumber = true

vim.opt.wildmode = { "longest", "list" }

vim.cmd("syntax on")
vim.opt.foldenable		= true
vim.opt.foldmethod		= "indent" -- фолд по табам
vim.opt.foldnestmax		= 2 -- уровни вложенности
vim.opt.foldminlines	= 20 -- количество строк для фолда
vim.opt.foldlevel		= 1 -- по умолчанию все будет свернуто на уровень 1

vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.ttyfast = true
vim.opt.scrolloff = 30

vim.cmd("filetype plugin indent on")

vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"

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

-- В самом верху файла (или перед тем, как вызывать setup) подключаем модули:
local lspconfig = require("lspconfig")
-- модуль configs хранит все «известные» конфигурации серверов
local configs   = require("lspconfig.configs")
local util      = require("lspconfig.util")

vim.g.NERDCommenterPadding = 1
vim.g.NERDDefaultAlign = nil
vim.g.NERDSpaceDelims = 1
vim.g.NERDCommenterAlignLeft = 0      -- выравнивание по текущему отступу
vim.g.NERDCommenterFixIndent = 1      -- сохранять текущий отступ
-- vim.g.neovide_font = "JetBrainsMono Nerd Font"
-- vim.o.guifont = "JetBrainsMono Nerd Font"

-- some colors
vim.cmd("colorscheme koehler")
vim.cmd("highlight comment guifg=gray")
vim.cmd("highlight CursorLineNr cterm=bold ctermfg=Yellow guifg=#FFD700 gui=bold")
vim.api.nvim_set_hl(0, "ModeMsg", { bg = "NONE" })
vim.api.nvim_set_hl(0, "Whitespace", { fg = "#5c6370", bg = "NONE" })
vim.api.nvim_set_hl(0, "NonText",    { fg = "#5c6370", bg = "NONE" })
vim.api.nvim_set_hl(0, "SpecialKey", { fg = "#5c6370", bg = "NONE" })

require("neo-tree").setup({
  filesystem = {
    filtered_items = {
      -- включить отображение скрытых и отфильтрованных элементов
      visible = true,

      -- не скрывать файлы/папки, начинающиеся с точки
      hide_dotfiles = false,

      -- не скрывать другие системные скрытые файлы
      hide_hidden = false,

      -- если у вас есть какие‑то patterns в hide_by_name – очистите их
      hide_by_name = {},
      never_show = {},          -- можно перечислить имена, которые всегда будут скрыты
      never_show_by_pattern = {}, -- можно перечислить паттерны, которые всегда будут скрыты
    },
    -- (остальная ваша конфигурация в filesystem…)
  },
  -- ... другие секции (buffers, git_status и т. д.) ...
})

vim.opt.mouse = ""

vim.opt.guicursor = "n-v-c:block,i-ci:block,r-cr:block"

-- nvim colorizer requirements
vim.opt.termguicolors = true
