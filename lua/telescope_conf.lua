local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  return
end

local actions       = require("telescope.actions")
local action_state  = require("telescope.actions.state")
local previewers    = require("telescope.previewers")
local sorters       = require("telescope.sorters")

--- Общая функция, которая вызывается при нажатии <CR>:
--- берёт entry, закрывает окно и открывает файл на нужной строке
local function open_with_position(prompt_bufnr)
  local entry = action_state.get_selected_entry()
  if not entry or not entry.path then
    return
  end
  -- Закрываем окно Telescope
  actions.close(prompt_bufnr)
  -- Если entry содержит поля 'path' и 'line', можно сразу перейти
  -- entry.value выглядит как "path:line:col:	text..."
  -- Вызов select_default сделает это автоматически, но мы можем явно распарсить:
  local filename = entry.path
  local lnum = entry.line or entry.lnum or entry.row or nil
  if lnum then
    vim.cmd(string.format("edit +%d %s", lnum, vim.fn.fnameescape(filename)))
  else
    vim.cmd("edit " .. vim.fn.fnameescape(filename))
  end
end

telescope.setup{
  defaults = {
    -- Параметры для live_grep (rg с возвратом file:line:col:match)
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      -- Исключения.
      "--glob", "!node_modules/*",
    },

    prompt_prefix   = "🔍 ",
    selection_caret = "➤ ",
    path_display    = { "shorten" },

    -- Preview всего файла (или фрагмента вокруг match)
    buffer_previewer_maker = previewers.buffer_previewer_maker,

    file_sorter = sorters.get_fzy_sorter,

    -- Настройки для маппингов внутри Telescope
    mappings = {
      i = {
        -- TODO: Навигация без wrap
        ["<C-n>"] = function(prompt_bufnr)
          actions.move_selection_next(prompt_bufnr, { wrap = false })
        end,
        ["<C-p>"] = function(prompt_bufnr)
          actions.move_selection_previous(prompt_bufnr, { wrap = false })
        end,
        ["<Down>"] = function(prompt_bufnr)
          actions.move_selection_next(prompt_bufnr, { wrap = false })
        end,
        ["<Up>"] = function(prompt_bufnr)
          actions.move_selection_previous(prompt_bufnr, { wrap = false })
        end,

        -- Закрытие по ESC
        ["<Esc>"] = actions.close,
        -- При выборе Enter — использовать нашу функцию,
        -- чтобы перейти на строку/столбец (если доступны)
        ["<CR>"]  = open_with_position,
      },
      n = {
        ["<C-n>"] = function(prompt_bufnr)
          actions.move_selection_next(prompt_bufnr, { wrap = false })
        end,
        ["<C-p>"] = function(prompt_bufnr)
          actions.move_selection_previous(prompt_bufnr, { wrap = false })
        end,
        ["<Down>"] = function(prompt_bufnr)
          actions.move_selection_next(prompt_bufnr, { wrap = false })
        end,
        ["<Up>"] = function(prompt_bufnr)
          actions.move_selection_previous(prompt_bufnr, { wrap = false })
        end,

        ["<Esc>"] = actions.close,
        ["<CR>"]  = open_with_position,
      },
    },
  },

  pickers = {
    -- find_files: ищем все файлы, но исключаем node_modules и .git
    find_files = {
      find_command = {
        "rg",
        "--files",
        "--hidden",
        "--follow",
        "--glob", "!.git/*",
        "--glob", "!node_modules/*",
      },
      -- Превью по умолчанию (buffer_previewer_maker)
    },
    -- live_grep: наследует vimgrep_arguments из defaults
    live_grep = {
      -- никаких дополнительных настроек не требуется
    },
  },

  extensions = {
    -- Можно тут подключать fzf-native, media_files и т.п.
  },
}
