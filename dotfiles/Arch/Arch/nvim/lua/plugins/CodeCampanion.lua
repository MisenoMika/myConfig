return {
  {
    "olimorris/codecompanion.nvim",
    version = "^19.17.0",
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" },
      { "nvim-treesitter/nvim-treesitter" },
    },
    opts = {
      adapters = {
        acp = {
          codex = function()
            return require("codecompanion.adapters").extend("codex", {
              defaults = {
                auth_method = "openai-api-key",
                timeout = 30000,
              },
              env = {
                OPENAI_API_KEY = os.getenv("OPENAI_API_KEY"),
              },
            })
          end,
        },
      },

      interactions = {
        chat = {
          adapter = "codex",
        },
      },
    },
  },
}
