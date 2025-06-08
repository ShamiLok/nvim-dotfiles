-- Настройки для корректного меню
vim.o.completeopt = "menu,menuone,noselect"
vim.o.pumheight = 10

-- Конфигурация nvim-cmp
local cmp_ok, cmp = pcall(require, 'cmp')
if not cmp_ok then return end

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn['vsnip#anonymous'](args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip'   },
  }, {
    { name = 'buffer'  },
  }),
  completion = {
    autocomplete = { cmp.TriggerEvent.TextChanged },
  },
})
