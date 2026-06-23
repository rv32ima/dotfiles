local keymap = vim.keymap.set

-- Better window navigation
keymap("n", "<C-Left>", "<C-w>h", { silent = true })
keymap("n", "<C-Down>", "<C-w>j", { silent = true })
keymap("n", "<C-Up>", "<C-w>k", { silent = true })
keymap("n", "<C-Right>", "<C-w>l", { silent = true })

-- Terminal mode goodies
-- This keymap sucks, especially for visual JJ usage. I wish I could special-case it,
-- and only have it apply to floating terminals and not the visual JJ window that opens.
-- For now, it's disabled until I think of something better.
-- keymap("t", "<esc>", "<C-\\><C-n>", { desc = "Escape from Terminal Mode", silent = true })
keymap("t", "<C-Left>", "<C-\\><C-N><C-w>h", { silent = true })
keymap("t", "<C-Down>", "<C-\\><C-N><C-w>j", { silent = true })
keymap("t", "<C-Up>", "<C-\\><C-N><C-w>k", { silent = true })
keymap("t", "<C-Right>", "<C-\\><C-N><C-w>l", { silent = true })
