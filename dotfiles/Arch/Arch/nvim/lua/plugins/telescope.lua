return {
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        -- 允许搜索被 gitignore 忽略的文件
        no_ignore = true,
        -- 同时允许搜索隐藏文件（如 .env 等）
        hidden = true,
      },
    },
  },
}
