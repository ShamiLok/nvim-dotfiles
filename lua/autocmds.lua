-- vim.api.nvim_create_autocmd({"BufReadPost", "BufNewFile"}, {
	-- pattern = "*",
	-- callback = function()
		-- if vim.bo.filetype == "" then
			-- vim.bo.commentstring = "# %s"
			-- vim.bo.filetype = "text"
		-- end
	-- end
-- })

-- auto nerdtree refresh
--vim.api.nvim_create_autocmd("FocusGained", {
--	pattern = "*",
--	command = "NERDTreeRefreshRoot"
--})



-- после того как setup уже отработал:
-- vim.api.nvim_create_autocmd("VimEnter", {
-- 	callback = function(data)
-- 		-- если Neovim запустили на директории, то откроем её
-- 		if vim.fn.isdirectory(data.file) == 1 then
-- 			require("nvim-tree.api").tree.open { dir = data.file }
-- 		else
-- 			-- иначе просто откроем корень проекта
-- 			require("nvim-tree.api").tree.open {}
-- 		end
-- 	end
-- })

-- lua/autocmds.lua

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function(data)
    local args = vim.fn.argc()      -- число переданных файлов/директорий
    -- Если есть аргументы
    if args > 0 then
      -- data.file будет либо первым аргументом (путь к файлу/дире)
      if vim.fn.isdirectory(data.file) == 1 then
        -- если это директория — открываем дерево
        require("nvim-tree.api").tree.open { dir = data.file }
      else
        -- иначе просто редактируем файл (это уже по умолчанию)
        -- не нужно ничего, :edit <file> выполнилось автоматически
      end
    else
      -- НИКАКИХ nvim-tree! — вместо этого стартовый экран
      require("alpha").start(true)
    end
  end,
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

-- Функция для удаления флагов r и o из локального formatoptions
local function remove_comment_formatflags()
  local bufnr = vim.api.nvim_get_current_buf()
  local fo = vim.api.nvim_buf_get_option(bufnr, "formatoptions")
  local new_fo = fo:gsub("[ro]", "")
  if new_fo ~= fo then
    vim.api.nvim_buf_set_option(bufnr, "formatoptions", new_fo)
  end
end

-- Убираем после FileType, после BufEnter, после InsertLeave
vim.api.nvim_create_autocmd({"FileType", "BufEnter", "InsertLeave"}, {
	pattern = "*",
	callback = remove_comment_formatflags,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    vim.defer_fn(function()
	  vim.cmd("normal! zM") -- сворачивсем все
	  vim.cmd("normal! zr") -- раскрываем первый уровень
    end, 50)
  end,
})

-- Автоматически включать wrap в превьюере Telescope
vim.api.nvim_create_autocmd("User", {
  pattern = "TelescopePreviewerLoaded",
  callback = function()
    -- Только для окна предпросмотра
    vim.wo.wrap = true
    vim.wo.linebreak = true
    -- При желании можно также настроить:
    -- vim.wo.showbreak = "↪ "   -- префикс для перенесённых строк
  end,
})

-- :make
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qml",
  callback = function()
    vim.bo.makeprg = "python qmlcore/build"
    vim.opt_local.errorformat = {
      -- ловим строку: file: error: at line X:Y:
      "%f: error: at line %l:%c:",
      -- на случай, если вдруг сообщение появится сразу после колонки:
      "%f: error: at line %l:%c: %m",
      -- на всякий случай общий формат file:line:col: message
      "%f:%l:%c: %m",
    }
  end,
})

-- после запуска :make проверяем ошибки
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  pattern = "make",
  callback = function()
    -- получить список ошибок
    local qfl = vim.fn.getqflist()
    if #qfl > 0 then
      -- если есть хотя бы одна запись с filename и lnum, открыть окно
      vim.cmd("cwindow")
    else
      -- если нет ошибок, закрыть quickfix-окно
      vim.cmd("cclose")
    end
  end,
})

