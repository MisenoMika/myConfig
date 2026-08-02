-- return {
--   {
--     "folke/snacks.nvim",
--     opts = {
--       picker = {
--         hidden = true, -- for hidden files
--         ignored = true, -- for .gitignore files
--         sources = {
--           explorer = {
--             layout = {
--               layout = {
--                 width = 35,
--               },
--             },
--           },
--         },
--       },
--     },
--   },
-- }
return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        -- 全局修改所有选择器的默认行为
        win = {
          input = {
            keys = {
              ["<c-g>"] = { "toggle_ignored", mode = { "i", "n" } },
            },
          },
        },
        -- 针对具体搜索命令的配置
        sources = {
          files = {
            ignored = true, -- 显示被 .gitignore 忽略的文件
            hidden = true, -- 同时显示隐藏文件（如 .env, .git 等）
          },
          explorer = {
            layout = {
              layout = {
                width = 35,
              },
            },
          },
        },
      },
    },
  },
}
