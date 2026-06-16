-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

-- Ctrl+s 保存
-- map("n", "<C-s>", "<cmd>w<cr>", { desc = "Save File" }) --会被终端捕获，当作是中断软件流信号

-- Insert 模式 jj 退出
map("i", "jj", "<Esc>", { desc = "Exit Insert Mode" })

-- Ctrl+h/j/k/l 切窗口
map("n", "<C-h>", "<C-w>h", { desc = "Left Window" })
map("n", "<C-j>", "<C-w>j", { desc = "Down Window" })
map("n", "<C-k>", "<C-w>k", { desc = "Up Window" })
map("n", "<C-l>", "<C-w>l", { desc = "Right Window" })
map("n", "<C-a>", "ggvG", { desc = "Select All" })
