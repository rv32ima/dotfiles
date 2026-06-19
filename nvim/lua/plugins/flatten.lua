return {
  {
    "willothy/flatten.nvim",
    lazy = false,
    priority = 1001,
    opts = function()
      return {
        window = {
          open = "tab",
        },
        hooks = {
          post_open = function(opts)
            vim.api.nvim_set_current_win(opts.winnr)

            local ft = opts.filetype
            -- If the file is a git commit, create one-shot autocmd to delete its buffer on write
            -- If you just want the toggleable terminal integration, ignore this bit
            if ft == "gitcommit" or ft == "gitrebase" or ft == "jjdescription" then
              vim.api.nvim_create_autocmd("BufWritePost", {
                buffer = opts.bufnr,
                once = true,
                callback = vim.schedule_wrap(function()
                  vim.api.nvim_buf_delete(opts.bufnr, {})

                  if ft == "jjdescription" then
                    require("lazyjui").open()
                  end
                end),
              })
            end
          end,
        },
      }
    end,
  }
}
