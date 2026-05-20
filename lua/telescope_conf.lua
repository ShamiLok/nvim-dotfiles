local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  return
end

local actions       = require("telescope.actions")
local action_state  = require("telescope.actions.state")
local previewers    = require("telescope.previewers")
local sorters       = require("telescope.sorters")

local function normalize_path(path)
  return vim.fn.fnamemodify(path, ":p")
end

local function find_buf_by_path(path)
  local target = normalize_path(path)

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= "" and normalize_path(name) == target then
        return buf
      end
    end
  end
end

local function find_line_by_text(buf, needle, around_lnum, radius)
  if type(needle) ~= "string" or needle == "" then
    return nil
  end

  around_lnum = around_lnum or 1
  radius = radius or 100

  local total = vim.api.nvim_buf_line_count(buf)
  local start_lnum = math.max(1, around_lnum - radius)
  local end_lnum = math.min(total, around_lnum + radius)

  local lines = vim.api.nvim_buf_get_lines(buf, start_lnum - 1, end_lnum, false)
  for i, line in ipairs(lines) do
    if line:find(needle, 1, true) then
      return start_lnum + i - 1
    end
  end

  return nil
end

local function open_with_position(prompt_bufnr)
  local entry = action_state.get_selected_entry()
  if not entry then
    return
  end

  local filename = entry.path or entry.filename or entry.value
  if not filename then
    return
  end

  local lnum = entry.line or entry.lnum or entry.row
  local col = entry.col or entry.column or 1

  -- лучше брать именно текст строки, если он есть
  local text = entry.text
  if type(text) ~= "string" or text == "" then
    text = nil
  end

  actions.close(prompt_bufnr)

  vim.schedule(function()
    local target_buf = find_buf_by_path(filename)

    if target_buf then
      vim.api.nvim_set_current_buf(target_buf)

      if vim.bo[target_buf].modified and text then
        local found = find_line_by_text(target_buf, text, lnum, 150)
        if found then
          lnum = found
        end
      end

      if lnum then
        vim.api.nvim_win_set_cursor(0, { lnum, math.max(col - 1, 0) })
      end
      return
    end

    local cmd
    if lnum then
      cmd = string.format("keepalt edit +%d %s", lnum, vim.fn.fnameescape(filename))
    else
      cmd = "keepalt edit " .. vim.fn.fnameescape(filename)
    end

    vim.cmd(cmd)

    if lnum and col then
      vim.api.nvim_win_set_cursor(0, { lnum, math.max(col - 1, 0) })
    end
  end)
end

telescope.setup{
  defaults = {
    -- Параметры для live_grep (rg с возвратом file:line:col:match)
    -- vimgrep_arguments = {
      -- "rg",
      -- "--color=never",
      -- "--no-heading",
      -- "--with-filename",
      -- "--line-number",
      -- "--column",
      -- "--smart-case",
      -- -- Исключения.
      -- "--glob", "!node_modules/*",
    -- },

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
		["<C-v>"] = function(prompt_bufnr)
		  -- Симулируем нажатие <C-r>+ в prompt-е, чтобы вставить содержимое системного буфера
		  local paste = vim.api.nvim_replace_termcodes("<C-r>+", true, false, true)
		  vim.api.nvim_feedkeys(paste, "i", false)
		end,
-- перемещение по списку результатов
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        -- если хочешь также листать историю запросов:
        ["<C-Down>"] = actions.cycle_history_next,
        ["<C-Up>"] = actions.cycle_history_prev,
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
        "--glob", "!dist/*",
        "--glob", "!build/*",
        "--glob", "!target/*",
        "--glob", "!.venv/*",
        "--glob", "!.cache/*",
        "--glob", "!.idea/*",
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

-- замена с telescpope
local function escape_for_vimgrep(str)
  -- экранируем слеши и спецсимволы, если нужно; здесь базово: заменить '/' на '\/'
  return str:gsub("/", "\\/")
end

local function replace_on_existing_quickfix()
  -- Проверяем, что quickfix не пуст
  local qfl = vim.fn.getqflist()
  if vim.tbl_isempty(qfl) then
    print("Quickfix list is empty; run live_grep + <C-q> first")
    return
  end
  -- Спрашиваем паттерн и замену
  vim.ui.input({ prompt = "Search pattern (for replacement): " }, function(pattern)
    if not pattern or pattern == "" then
      print("Cancelled")
      return
    end
    local esc_pattern = escape_for_vimgrep(pattern)
    vim.ui.input({ prompt = "Replacement text: " }, function(replacement)
      if replacement == nil then
        print("Cancelled")
        return
      end
      local esc_replacement = replacement:gsub("/", "\\/")
      vim.cmd('copen')
      vim.ui.input({ prompt = "Run replace on quickfix matches with confirmation? (yes): " }, function(ans)
        if not ans or ans:lower()~="yes" then
          print("Aborted")
          return
        end
        vim.cmd('cfdo %s/'..esc_pattern..'/'..esc_replacement..'/gc | update')
        print("Done")
      end)
    end)
  end)
end

vim.keymap.set('n', '<leader>t', replace_on_existing_quickfix, { desc="Replace on existing quickfix" })
-- замена с telescope end
