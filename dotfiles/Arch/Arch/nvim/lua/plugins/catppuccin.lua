return {
  {
    "catppuccin/nvim",
    opts = function(_, opts)
      local colors = require("catppuccin.palettes").get_palette("mocha")

      opts.custom_highlights = {
        FlashLabel = {
          fg = colors.base,
          bg = colors.red,
          bold = true,
        },

        FlashMatch = {
          fg = colors.yellow,
          bold = true,
        },

        FlashCurrent = {
          fg = colors.base,
          bg = colors.green,
          bold = true,
        },

        FlashBackdrop = {
          fg = colors.surface2,
        },
      }
    end,
    opts = {
      integrations = {
        flash = true,
      },
    },
  },
}
