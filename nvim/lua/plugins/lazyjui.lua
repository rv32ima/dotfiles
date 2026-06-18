return {
  {
    "mrdwarf7/lazyjui.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim"
    },
    keys = {
      {
        "<Leader>jj",
        function()
          require("lazyjui").open()
        end,
      },
    },
    opts = {},
  }
}
