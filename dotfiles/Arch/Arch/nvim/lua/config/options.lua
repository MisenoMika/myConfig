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

-- 让 flash 的临时高亮保持透明
for _, g in ipairs({ "FlashBackdrop", "FlashMatch", "FlashCurrent", "FlashLabel" }) do
  vim.api.nvim_set_hl(0, g, { bg = "none" })
end

-- 透明背景：把终端背景色同步成当前主题的背景色，
-- 这样透明窗口（浮窗、状态栏等）透出的颜色与主题一致。
local function set_terminal_bg(color)
  if not color then
    return
  end
  pcall(vim.fn.system, "printf '\\e]11;" .. color .. "\\e\\\\' > /dev/tty")
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    local name = vim.g.colors_name or ""
    if name:find("catppuccin") then
      set_terminal_bg("#1e1e2e") -- catppuccin mocha base
    elseif name:find("tokyonight") then
      set_terminal_bg("#1e2030") -- tokyonight moon bg
    end
  end,
})
vim.opt.tabstop = 4 -- Tab 在编辑器中显示的宽度
vim.opt.shiftwidth = 4 -- 自动缩进 (如 >>) 使用的宽度
vim.opt.softtabstop = 4 -- 退格键删除的空格数
