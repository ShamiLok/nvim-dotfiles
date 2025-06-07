vim.g.mapleader = ","

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

-- В самом верху файла (или перед тем, как вызывать setup) подключаем модули:
local lspconfig = require("lspconfig")
-- модуль configs хранит все «известные» конфигурации серверов
local configs   = require("lspconfig.configs")
local util      = require("lspconfig.util")

-- Проверяем, не зарегистрирован ли уже (чтобы не перезаписывать дважды, если вы перезагрузите файл)
if not configs.myqtjs then
  configs.myqtjs = {
    default_config = {
      -- 1) Абсолютный путь к вашему LSP-серверу
      --    Убедитесь, что файл действительно лежит по этому пути
      --    и запускается через python3 без ошибок.
      cmd = { "python3", "/home/uzver/work/iptvApp/qmlcore/myqtjs_lsp.py" },

      -- 2) Для каких filetype запускать сервер. 
      --    Мы хотим, чтобы LSP работал только на *.qml
      filetypes = { "qml" },

      -- 3) Как определять «корень» проекта. 
      --    В этом примере мы ищем ближайший каталог с .git или src.
      --    Если не нашли – по умолчанию попадём в директорию файла.
      root_dir = function(fname)
        return util.root_pattern(".git", "src")(fname)
               or util.path.dirname(fname)
      end,

      -- 4) Любые дополнительные поля, которые ваш сервер ожидает при инициализации.
      --    Мы оставим пустым ({}), но впоследствии, если сервер будет принимать
      --    какие-то init_options или настройки, сюда их можно поместить.
      settings = {},
    }
  }
end

-- Наконец, вызываем setup для нашего «myqtjs».
-- После этого Neovim/LSPConfig «знает», как работать с сервером myqtjs.
lspconfig.myqtjs.setup {
  -- Здесь вы можете добавить своё on_attach, capabilities и т. д.
  on_attach = function(client, bufnr)
    -- Например, привязка горячих клавиш для LSP
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local opts = { noremap=true, silent=true }
    buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
    buf_set_keymap("n", "K",  "<cmd>lua vim.lsp.buf.hover()<CR>",      opts)
    -- … и так далее …
  end,
  flags = {
    debounce_text_changes = 150,
  },
}
