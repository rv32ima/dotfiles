-- Load our plugins file
require('plugins')

-- Enable Lua syntax highlighting in the initialization files
vim.api.nvim_set_var('vimsyn_embed', 'l')

-- Color scheme
vim.cmd 'colorscheme tokyonight-night'

-- Some basic defaults that I like
vim.g.mapleader = ';'
vim.o.softtabstop = 2
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.autoindent = true
vim.o.encoding = 'utf-8'
vim.wo.cursorline = true

-- No clue why we have to go through nvim_exec for these
vim.cmd 'syntax on'
vim.cmd 'filetype plugin on'

-- Generic keybind configuration
local keybinds = require('keybinds')
keybinds.setup_keybinds()
-- LSP configuration
local lsp_config = require('lsp_config')
lsp_config.setup()
lsp_config.enable_format_on_save()
-- LuaLine configuration
local lualine_config = require('lualine_config')
lualine_config.setup()
