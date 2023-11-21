-- Some basic keybinds - this is TBD
local M = {}
local keymap_opts = { nowait = true, noremap = true, silent = true }

function M.setup_keybinds()
  vim.api.nvim_set_keymap('', '<leader>nt', ':NERDTreeToggle<CR>', keymap_opts)
  vim.api.nvim_set_keymap('n', '<leader>ff', ':Telescope find_files<CR>', keymap_opts)
  vim.api.nvim_set_keymap('n', '<leader>fg', ':Telescope live_grep<CR>', keymap_opts)
  vim.api.nvim_set_keymap('n', '<leader>fb', ':Telescope buffers<CR>', keymap_opts)
  vim.api.nvim_set_keymap('n', '<leader>fh', ':Telescope help_tags<CR>', keymap_opts)
  -- Quick escape out of the terminal
  vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', keymap_opts)

  -- LSP related keymaps
  vim.api.nvim_set_keymap('n', '<leader>df', '<cmd>lua vim.diagnostic.openfloat()<CR>', keymap_opts)
  vim.api.nvim_set_keymap('n', '<leader>dgp', '<cmd>lua vim.diagnostic.goto_prev()<CR>', keymap_opts)
  vim.api.nvim_set_keymap('n', '<leader>dgn', '<cmd>lua vim.diagnostic.goto_next()<CR>', keymap_opts)
  vim.api.nvim_set_keymap('n', '<leader>dgl', '<cmd>lua vim.diagnostic.setloclist()<CR>', keymap_opts)
end

function M.setup_lsp_keybinds(bufnr)
  local binds = {
    {
      chord = '<leader>gD',
      command = 'vim.lsp.buf.declaration()',
    },
    {
      chord = '<leader>gd',
      command = 'vim.lsp.buf.definition()'
    },
    {
      chord = '<leader>K',
      command = 'vim.lsp.buf.hover()',
    },
    {
      chord = '<leader>gi',
      command = 'vim.lsp.buf.implementation()',
    },
    {
      chord = '<leader>sh',
      command = 'vim.lsp.buf.signature_help()',
    },
    {
      chord = '<leader>wa',
      command = 'vim.lsp.buf.add_workspace_folder()',
    },
    {
      chord = '<leader>wr',
      command = 'vim.lsp.buf.remove_workspace_folder()',
    },
    {
      chord = '<leader>wl',
      command = 'print(vim.inspect(vim.lsp.buf.list_workspace_folders()))',
    },
    {
      chord = '<leader>D',
      command = 'vim.lsp.buf.type_definition()',
    },
    {
      chord = '<leader>rn',
      command = 'vim.lsp.buf.rename()',
    },
    {
      chord = '<leader>ca',
      command = 'vim.lsp.buf.code_action()',
    },
    {
      chord = '<leader>gr',
      command = 'vim.lsp.buf.references()',
    },
    {
      chord = '<leader>f',
      command = 'vim.lsp.buf.formatting()',
    }
  }

  for _, bind in pairs(binds) do
    vim.api.nvim_buf_set_keymap(bufnr, 'n', bind.chord, '<cmd>lua ' .. bind.command .. '<CR>', keymap_opts)
  end
end

return M

