vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Color schemes
  use 'morhetz/gruvbox'
  use 'dracula/vim'
  use 'rafamadriz/neon'
  use 'folke/tokyonight.nvim'

  -- Collection of configurations for the built-in LSP server
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'
  use 'neovim/nvim-lspconfig'

  -- Automatic LSP status bar
  use 'nvim-lua/lsp-status.nvim'

  -- NERDTree
  use 'scrooloose/nerdtree'

  -- Surround selection with brackets / quotes / whatnot
  use 'tpope/vim-surround'

  -- Terraform support for Vim
  use 'hashivim/vim-terraform'

  -- Markdown preview support
  use { 'iamcco/markdown-preview.nvim', run = 'cd app && yarn install', cmd = 'MarkdownPreview' }

  -- Code completion support
  use { 'ms-jpq/coq_nvim', as = 'coq' }
  use 'ms-jpq/coq.artifacts'
  use 'ms-jpq/coq.thirdparty'

  -- Fuzzy finder
  use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } }

  -- Status line
  use { 'nvim-lualine/lualine.nvim', requires = { 'kyazdani42/nvim-web-devicons', opt = true } }
end)
