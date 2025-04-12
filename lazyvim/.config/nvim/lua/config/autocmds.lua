-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Create an autocommand group for transparency
vim.api.nvim_create_augroup("Transparency", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  group = "Transparency",
  pattern = "*",
  callback = function()
    vim.cmd("hi Normal guibg=none ctermbg=none")
    vim.cmd("hi NormalFloat guibg=none ctermbg=none")
    vim.cmd("hi SignColumn guibg=none ctermbg=none")
    vim.cmd("hi EndOfBuffer guibg=none ctermbg=none")
  end,
})
