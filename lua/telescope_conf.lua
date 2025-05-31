-- Загрузка необходимых модулей
local telescope = require("telescope")
local previewers = require("telescope.previewers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

-- Основная настройка Telescope
telescope.setup{
  defaults = {
    -- Аргументы для vimgrep (использует локальный rg)
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
    },

    -- Префиксы и отображение путей
    prompt_prefix   = "🔍 ",
    selection_caret = "➤ ",
    path_display    = { "shorten" },

    -- Preview через стандартный buffer_previewer_maker
    buffer_previewer_maker = previewers.buffer_previewer_maker,

    -- Маппинги, которые срабатывают внутри окна Telescope
    mappings = {
      i = {
        -- Вставочный режим: Enter → открыть файл, на котором стоит курсор
        ["<CR>"] = function(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          if not entry or not entry.path then
            return
          end
          actions.close(prompt_bufnr)
          vim.cmd("edit " .. vim.fn.fnameescape(entry.path))
        end,
        -- Можно добавить другие горячие клавиши здесь (Esc, Ctrl-C и т.д.)
      },
      n = {
		["<Esc>"] = actions.close,
        -- Нормальный режим: Enter → открыть файл
        ["<CR>"] = function(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          if not entry or not entry.path then
            return
          end
          actions.close(prompt_bufnr)
          vim.cmd("edit " .. vim.fn.fnameescape(entry.path))
        end,
      },
    },

    -- Количество строк в превью (по желанию)
    preview = {
      filesize_limit = 50,  -- если файл >50MB, не показываем превью
    },
  },

  pickers = {
    -- Настройка поиска файлов (:Telescope find_files)
    find_files = {
      -- Использовать rg для поиска списка файлов (рекурсивно, включая скрытые,
      -- но игнорируя .git и node_modules)
      find_command = {
        "rg",
        "--files",
        "--hidden",
        "--follow",
        "--glob",
        "!.git/*",
        "--glob",
        "!node_modules/*"
      }
    },

    -- Настройка live_grep (:Telescope live_grep)
    live_grep = {
      -- По умолчанию уже использует defaults.vimgrep_arguments
      -- Можно указать дополнительные параметры, но обычно не нужно.
    },
  },

  extensions = {
    -- Здесь можно подключать и настраивать расширения (fzf-native, media_files и т.д.)
  },
}
