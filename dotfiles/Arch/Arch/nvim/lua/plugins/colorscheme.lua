return {
  {
    "LazyVim/LazyVim",
    opts = {
      -- 用函数形式加载，确保 lazy 的 catppuccin.nvim 插件被真正加载
      --（字符串形式会落到 Neovim 自带的 catppuccin.vim，丢失透明/集成等配置）
      colorscheme = function()
        require("catppuccin").load("mocha")
      end,
      -- colorscheme = "tokyonight",
    },
  },
}
