-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.api.nvim_create_autocmd("VimLeave", {
  callback = function()
    io.write("\27[5 q")
    io.flush()
  end,
})
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.guicursor = "n-v-c:ver25," .. "i-ci-ve:ver25," .. "r-cr:ver25," .. "o:ver25"
