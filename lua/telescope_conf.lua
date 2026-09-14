local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  return {} -- пустой модуль: mappings.lua увидит отсутствие функций и уйдёт в fallback
end

local actions       = require("telescope.actions")
local action_state  = require("telescope.actions.state")
local previewers    = require("telescope.previewers")
local sorters       = require("telescope.sorters")
local finders       = require("telescope.finders")
local pickers       = require("telescope.pickers")
local make_entry    = require("telescope.make_entry")
local conf          = require("telescope.config").values
local Job           = require("plenary.job")

local IS_WINDOWS = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1

-- Общие исключения директорий.
-- Trailing slash = rg вообще не заходит внутрь (полное отсечение, а не фильтрация содержимого).
local EXCLUDE_GLOBS = {
  "!.git/",
  "!node_modules/",
  "!dist/",
  "!build/",
  "!target/",
  "!.venv/",
  "!.cache/",
  "!.idea/",
  "!AppData/",           -- Windows: профиль пользователя (тысячи файлов + антивирус)
  "!Application Data/",  -- Windows: junction-петля в профиле
}

local function with_exclude_globs(args)
  for _, g in ipairs(EXCLUDE_GLOBS) do
    table.insert(args, "--glob")
    table.insert(args, g)
  end
  return args
end

-- Аргументы rg для поиска файлов
local function rg_files_args()
  local args = { "rg", "--files", "--color=never", "--hidden" }
  if not IS_WINDOWS then
    -- На Windows --follow опасен: junction-точки создают петли,
    -- из-за чего одни и те же директории сканируются многократно.
    table.insert(args, "--follow")
  end
  return with_exclude_globs(args)
end

-- Базовые аргументы rg для поиска по содержимому (live_grep)
local VIMGREP_ARGS = with_exclude_globs({
  "rg",
  "--color=never",
  "--no-heading",
  "--with-filename",
  "--line-number",
  "--column",
  "--smart-case",
})

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
    vimgrep_arguments = VIMGREP_ARGS,

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
    -- (используется как fallback для :Telescope find_files;
    --  основной поиск по <leader>f идёт через find_files_fast ниже)
    find_files = {
      find_command = rg_files_args(),
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

----------------------------------------------------------------------
-- Быстрый find_files с кешем (stale-while-revalidate)
--
-- Проблема: на Windows полное рекурсивное сканирование rg при каждом
-- открытии пикера может занимать десятки секунд (антивирус проверяет
-- каждое чтение каталога).
--
-- Решение:
--  1. Список файлов кешируется на диске (per cwd) и показывается
--     МГНОВЕННО при открытии — даже из прошлых сессий.
--  2. Свежее сканирование идёт в фоне и обновляет уже открытый пикер
--     (набранный запрос сохраняется).
--  3. Если cwd — корень git-репозитория (без подмодулей), вместо обхода
--     файловой системы читается индекс git (миллисекунды даже на Windows).
--  4. <C-r> в пикере — принудительное обновление кеша.
----------------------------------------------------------------------

local M = {}

local CACHE_DIR        = vim.fn.stdpath("cache") .. "/telescope-file-cache"
local CACHE_TTL        = 30      -- сек: повторное открытие в течение TTL не пересканирует
local MAX_CACHE_LINES  = 300000  -- защита от патологически больших деревьев
local CACHE_MAX_AGE    = 30 * 24 * 60 * 60 -- чистим кеши старше 30 дней

local scan_in_progress = {} -- root -> true
local last_scan_done   = {} -- root -> os.time()
local pending_pickers  = {} -- root -> { { picker=..., is_closed=fn, opts=... }, ... }

local function normalize_root(path)
  path = vim.fn.fnamemodify(path, ":p")
  path = path:gsub("\\", "/"):gsub("/+$", "")
  if IS_WINDOWS then
    path = path:lower() -- регистронезависимая ФС
  end
  return path
end

local function cache_file(root)
  return CACHE_DIR .. "/" .. vim.fn.sha256(root) .. ".txt"
end

local function read_cache(root)
  local path = cache_file(root)
  if vim.fn.filereadable(path) ~= 1 then
    return nil
  end
  local ok, lines = pcall(vim.fn.readfile, path, "", MAX_CACHE_LINES)
  if not ok or type(lines) ~= "table" or #lines == 0 then
    return nil
  end
  return lines
end

local function write_cache(root, lines)
  pcall(vim.fn.mkdir, CACHE_DIR, "p")
  pcall(vim.fn.writefile, lines, cache_file(root))
end

-- cwd является корнем git-репозитория?
-- (.git может быть файлом — worktree/submodule)
local function is_git_root(root)
  return vim.fn.isdirectory(root .. "/.git") == 1
      or vim.fn.filereadable(root .. "/.git") == 1
end

-- Команда сканирования. git ls-files читает индекс и не трогает
-- файловую систему рекурсивно — на порядки быстрее на медленных дисках.
-- Исключение: репозитории с подмодулями — git ls-files не заходит внутрь
-- подмодулей, а rg заходит, поэтому там используем rg (старое поведение).
local function build_scan_command(root)
  if vim.fn.executable("git") == 1
      and is_git_root(root)
      and vim.fn.filereadable(root .. "/.gitmodules") ~= 1 then
    return { "git", "ls-files", "--cached", "--others", "--exclude-standard" }
  end
  if vim.fn.executable("rg") == 1 then
    return rg_files_args()
  end
  return nil
end

local function new_files_finder(lines, entry_opts)
  return finders.new_table({
    results = lines,
    entry_maker = make_entry.gen_from_file(entry_opts),
  })
end

-- Обновить все живые пикеры, ожидающие результат для root
local function refresh_pending_pickers(root, lines)
  local pend = pending_pickers[root]
  if not pend then
    return
  end
  local alive = {}
  for _, item in ipairs(pend) do
    if not item.is_closed() then
      table.insert(alive, item)
      pcall(function()
        item.picker:refresh(new_files_finder(lines, item.opts), { reset_prompt = false })
        pcall(function()
          item.picker.prompt_border:change_title(" Find Files ")
        end)
      end)
    end
  end
  pending_pickers[root] = alive
end

local function on_scan_done(root, lines)
  last_scan_done[root] = os.time()
  -- защита от пустых строк
  lines = vim.tbl_filter(function(l) return l ~= "" end, lines)
  table.sort(lines)
  write_cache(root, lines)
  refresh_pending_pickers(root, lines)
end

local function run_scan_job(root, cmd)
  Job:new({
    command = cmd[1],
    args = vim.list_slice(cmd, 2, #cmd),
    cwd = root,
    enable_recording = true,
    on_exit = vim.schedule_wrap(function(j, code)
      local lines = code == 0 and j:result() or nil
      if not lines or #lines == 0 then
        -- git мог упасть (битый репозиторий и т.п.) — пробуем rg
        if cmd[1] == "git" and vim.fn.executable("rg") == 1 then
          run_scan_job(root, rg_files_args())
          return
        end
        scan_in_progress[root] = nil
        return
      end
      scan_in_progress[root] = nil
      on_scan_done(root, lines)
    end),
  }):start()
end

local function start_scan(root, force)
  if scan_in_progress[root] then
    return
  end
  if not force
      and last_scan_done[root]
      and (os.time() - last_scan_done[root]) < CACHE_TTL then
    return
  end
  local cmd = build_scan_command(root)
  if not cmd then
    return
  end
  scan_in_progress[root] = true
  run_scan_job(root, cmd)
end

--- Быстрый аналог builtin.find_files: мгновенный кеш + фоновое обновление.
function M.find_files_fast(opts)
  opts = opts or {}
  local cwd = vim.fn.getcwd()
  local root = normalize_root(cwd)
  local entry_opts = { cwd = cwd, path_display = conf.path_display }

  local cached = read_cache(root)

  if not cached and not build_scan_command(root) then
    -- нет ни кеша, ни rg/git — стандартный find_files (сам подберёт fd/rg/find)
    return require("telescope.builtin").find_files(opts)
  end

  local picker = pickers.new(entry_opts, {
    prompt_title = cached and " Find Files " or " Find Files (scanning...) ",
    finder = new_files_finder(cached or {}, entry_opts),
    sorter = conf.file_sorter(entry_opts),
    previewer = conf.file_previewer(entry_opts),
    attach_mappings = function(_, map)
      -- принудительное обновление кеша
      map("i", "<C-r>", function()
        start_scan(root, true)
      end)
      return true
    end,
  })

  picker:find()

  -- отслеживаем закрытие, чтобы не обновлять мёртвый пикер
  local closed = false
  vim.api.nvim_create_autocmd({ "BufWipeout", "BufDelete" }, {
    buffer = picker.prompt_bufnr,
    once = true,
    callback = function()
      closed = true
    end,
  })

  pending_pickers[root] = pending_pickers[root] or {}
  table.insert(pending_pickers[root], {
    picker = picker,
    is_closed = function() return closed end,
    opts = entry_opts,
  })

  start_scan(root, false)
  return picker
end

--- live_grep с --fixed-strings (для <leader>r), с теми же исключениями
function M.live_grep_fixed()
  local args = vim.deepcopy(VIMGREP_ARGS)
  table.insert(args, "--fixed-strings")
  require("telescope.builtin").live_grep({ vimgrep_arguments = args })
end

vim.api.nvim_create_user_command("FindFilesFast", function()
  M.find_files_fast()
end, { desc = "Find files (cached, background refresh)" })

-- Чистка старых файлов кеша (старше CACHE_MAX_AGE), один раз за сессию,
-- отложенно, чтобы не тормозить старт
vim.defer_fn(function()
  local uv = vim.loop
  local handle = uv.fs_scandir(CACHE_DIR)
  if not handle then
    return
  end
  local now = os.time()
  while true do
    local name, typ = uv.fs_scandir_next(handle)
    if not name then
      break
    end
    if typ == "file" then
      local full = CACHE_DIR .. "/" .. name
      local stat = uv.fs_stat(full)
      if stat and stat.mtime and (now - stat.mtime.sec) > CACHE_MAX_AGE then
        pcall(uv.fs_unlink, full)
      end
    end
  end
end, 3000)

return M
