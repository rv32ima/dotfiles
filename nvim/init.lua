-- Enable Lua syntax highlighting in the initialization files
vim.api.nvim_set_var("vimsyn_embed", "l")

-- Some basic defaults that I like
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.o.softtabstop = 2
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.autoindent = true
vim.o.encoding = "utf-8"
vim.wo.cursorline = true

-- No clue why we have to go through nvim_exec for these
vim.cmd("syntax on")
vim.cmd("filetype plugin on")
