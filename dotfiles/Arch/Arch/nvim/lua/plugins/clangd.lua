return {
  "neovim/nvim-lspconfig",
  opts = {
    setup = {
      clangd = function(_, opts)
        opts.cmd = { "clangd", "--header-insertion=never" }
      end,
    },
  },
}
