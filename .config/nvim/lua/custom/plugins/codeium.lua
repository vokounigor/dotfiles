return {
  'Exafunction/codeium.vim',
  event = 'BufEnter',
  config = function ()
    vim.g.codeium_enabled = false -- enabled by default
    vim.keymap.set('i', '<C-g>', function () return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
    vim.keymap.set('i', '<c-f>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true, silent = true })
    vim.keymap.set('i', '<c-d>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true, silent = true })
    vim.keymap.set('i', '<c-x>', function() return vim.fn['codeium#Clear']() end, { expr = true, silent = true })
    vim.keymap.set('n', '<leader>cd', function() vim.g.codeium_enabled = not vim.g.codeium_enabled end, { expr = true, silent = true })
  end
}
