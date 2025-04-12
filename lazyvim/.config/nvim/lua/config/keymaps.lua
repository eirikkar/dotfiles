-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.api.nvim_set_keymap("n", "<PageUp>", "<c-u>zz", { noremap = true })
vim.api.nvim_set_keymap("n", "<PageDown>", "<c-d>zz", { noremap = true })
vim.api.nvim_set_keymap(
  "n",
  "<c-n>",
  [[<cmd>lua require("oil").toggle_float()<CR>]],
  { noremap = true, silent = true, desc = "Toggle Oil float" }
)
