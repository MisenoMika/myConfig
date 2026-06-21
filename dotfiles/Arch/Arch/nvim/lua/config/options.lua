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

local groups = {
  "NormalFloat",
  "FloatBorder",
  "FloatTitle",
  "FlashBackdrop",
  "FlashMatch",
  "FlashCurrent",
  "FlashLabel",
}

for _, g in ipairs(groups) do
  vim.api.nvim_set_hl(0, g, { bg = "none" })
end
vim.opt.tabstop = 4 -- Tab 在编辑器中显示的宽度
vim.opt.shiftwidth = 4 -- 自动缩进 (如 >>) 使用的宽度
vim.opt.softtabstop = 4 -- 退格键删除的空格数
