-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- vim.api.nvim_create_autocmd({ "ExitPre" }, {
--   callback = function()
--     vim.set.guicursor = "a:ver30-blinkon0"
--   end,
-- })
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20"
