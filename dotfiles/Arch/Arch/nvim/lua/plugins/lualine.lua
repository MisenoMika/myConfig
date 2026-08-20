return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local cp = require("catppuccin.palettes").get_palette("mocha")
      opts.options.theme = {
        normal = {
          a = { bg = cp.blue, fg = cp.base, gui = "bold" },
          b = { bg = "none", fg = cp.text },
          c = { bg = "none", fg = cp.subtext1 },
        },
        insert = {
          a = { bg = cp.green, fg = cp.base, gui = "bold" },
          b = { bg = "none", fg = cp.text },
          c = { bg = "none", fg = cp.subtext1 },
        },
        visual = {
          a = { bg = cp.mauve, fg = cp.base, gui = "bold" },
          b = { bg = "none", fg = cp.text },
          c = { bg = "none", fg = cp.subtext1 },
        },
        replace = {
          a = { bg = cp.red, fg = cp.base, gui = "bold" },
          b = { bg = "none", fg = cp.text },
          c = { bg = "none", fg = cp.subtext1 },
        },
        command = {
          a = { bg = cp.peach, fg = cp.base, gui = "bold" },
          b = { bg = "none", fg = cp.text },
          c = { bg = "none", fg = cp.subtext1 },
        },
        terminal = {
          a = { bg = cp.sky, fg = cp.base, gui = "bold" },
          b = { bg = "none", fg = cp.text },
          c = { bg = "none", fg = cp.subtext1 },
        },
        inactive = {
          a = { bg = "none", fg = cp.overlay0, gui = "bold" },
          b = { bg = "none", fg = cp.overlay1 },
          c = { bg = "none", fg = cp.overlay0 },
        },
      }
      return opts
    end,
  },
}
