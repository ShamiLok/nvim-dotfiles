vim.api.nvim_create_user_command('Gdt', function()
  local ok, neo_tree = pcall(require, "neo-tree")
  if ok and neo_tree.close_all then
    neo_tree.close_all()
  end
  vim.cmd('only')
  vim.cmd('Git difftool')
end, { desc = "Git difftool in 2 panes" })

