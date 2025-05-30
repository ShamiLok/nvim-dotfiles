
local has_win = vim.fn.has('win32') == 1
local telescope = require('telescope')
local previewers = require('telescope.previewers')
local actions   = require('telescope.actions')
local action_state = require('telescope.actions.state')
local Job = require('plenary.job')

-- конвертер WSL->Windows
local function to_win_path(wsl_path)
  local ok, out = pcall(vim.fn.systemlist, 'wsl wslpath -w "' .. wsl_path .. '"')
  if not ok or out[1] == nil or out[1] == "" then
    return wsl_path
  end
  return out[1]:gsub('\r','')
end

-- твой previewer для Windows
local function wsl_previewer_maker(filepath, bufnr, opts)
  local winpath = to_win_path(filepath)
  Job:new({
    command = "cmd.exe",
    args = {"/c", "type", winpath},
    on_stdout = function(_, line)
      vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, {line})
    end,
  }):sync()
end

telescope.setup{
  defaults = {
    prompt_prefix    = "🔍 ",
    selection_caret  = "➤ ",
    path_display     = { "shorten" },

    vimgrep_arguments = has_win and {
      'rgwsl.cmd', '--vimgrep',
    } or {
      'rg','--vimgrep','--no-heading','--color=never','--smart-case',
    },

    buffer_previewer_maker = has_win
      and wsl_previewer_maker
      or previewers.buffer_previewer_maker,

    mappings = {
      i = {
        -- Enter в insert-режиме
        ["<CR>"] = function(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          local path = entry.path or entry.filename or entry.value
          local real = has_win and to_win_path(path) or path
          vim.cmd("edit " .. vim.fn.fnameescape(real))
        end,
      },
      n = {
        -- Enter в normal-режиме
        ["<CR>"] = function(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          local path = entry.path or entry.filename or entry.value
          local real = has_win and to_win_path(path) or path
          vim.cmd("edit " .. vim.fn.fnameescape(real))
        end,
      },
    },
  },
  pickers = {
    find_files = {
      find_command = has_win and {
        'rgwsl.cmd','--files','--hidden','--follow','--glob','!.git/*'
      } or nil,
    },
    live_grep = {
      -- опционально можно задать какие-то picker-specific настройки
    },
  },
}
