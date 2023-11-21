local M = {}

function M.setup()
  local coq = require('coq')
  local lsp_status = require('lsp-status')
  local lspconfig = require('lspconfig')
  local keybinds = require('keybinds')
  local servers = {
    'angularls',
    'clangd',
    'eslint',
    'graphql',
    'jsonls',
    'pyright',
    'rust_analyzer',
    'serve_d',
    'lua_ls',
    'tailwindcss',
    'taplo',
    'terraformls',
    'tsserver',
  }

  require('mason').setup()
  require('mason-lspconfig').setup({
    ensure_installed = servers
  })

  -- Required initialization step
  lsp_status.register_progress()

  -- Basic on_attach that will automatically create our LSP bindings
  -- and whatnot when we attach to a buffer with an LSP.
  local on_attach = function(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    keybinds.setup_lsp_keybinds(bufnr)
    lsp_status.on_attach(client)
  end

  local server_config = {
    clangd = {
      handlers = lsp_status.extensions.clangd.setup(),
      init_options = {
        clangdFileStatus = true
      }
    },
    eslint = {
      settings = {
        codeAction = {
          disableRuleComment = {
            enable = true,
            location = 'separateLine',
          },
          showDocumentation = {
            enable = true
          },
        },
        codeActionOnSave = {
          enable = false,
          mode = 'all',
        },
        format = true,
        nodePath = '',
        onIgnoredFiles = 'off',
        packageManager = 'yarn',
        quiet = false,
        rulesCustomizations = {},
        run = 'onType',
        useESLintClass = false,
        validate = 'on',
        workingDirectory = {
          mode = 'location'
        },
      },
    },
    lua_ls = {
      settings = {
        Lua = {
          runtime = {
            version = 'LuaJIT',
          },
          diagnostics = {
            globals = { 'vim' },
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
          },
          telemetry = {
            enable = false,
          },
        },
      },
    },
  }


  for _, name in pairs(servers) do
    ---@diagnostic disable-next-line: undefined-field
    local config = server_config[name] or {}
    config.capabilities = lsp_status.capabilities
    config.on_attach = on_attach
    lspconfig[name].setup(coq.lsp_ensure_capabilities(config))
  end

  -- Setup the status bar
  vim.cmd [[
  function! LspStatus() abort
    if luaeval('#vim.lsp.buf_get_clients() > 0')
      return luaeval("require('lsp-status').status()")
    endif

    return ''
  endfunction ]]

  -- Setup Coq third-party things
  require('coq_3p') {
    { src = 'nvimlua', short_name = 'nLUA', conf_only = true },
    { src = 'cow', trigger = '!cow' },
    { src = 'figlet', trigger = '!big' },
  }

  -- Start COQ
  vim.cmd 'COQnow --shut-up'
end

function M.enable_format_on_save()
  vim.cmd [[
    augroup format_on_save
      au!
      au BufWritePre *.js,*.jsx,*.ts,*.tsx EslintFixAll
      au BufWritePre *.lua vim.lsp.buf.formatting_sync(nil, 2000)
    augroup end
  ]]
end

function M.toggle_format_on_save()
  if vim.fn.exists '#format_on_save#BufWritePre' == 0 then
    M.enable_format_on_save()
    vim.notify 'Enabled format on save'
  else
    vim.cmd 'au! format_on_save'
    vim.notify 'Disabled format on save'
  end
end

vim.cmd [[command! LspToggleAutoFormat execute 'lua require("lsp_config").toggle_format_on_save()']]

return M

