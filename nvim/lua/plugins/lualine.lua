return {
  "nvim-lualine/lualine.nvim",
  opts = function()
    local opts = {
      sections = {
        lualine_x = {
          function()
            return require('direnv').statusline()
          end,
        },
      },
    }

    return opts
  end
}
