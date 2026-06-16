-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
vim.filetype.add({
  extension = {
    v = "verilog",
    vh = "verilog",
    sv = "systemverilog",
    svh = "systemverilog",
    svi = "systemverilog",
  },
})

vim.lsp.config("vide", {
  cmd = { "vide" },
  filetypes = { "verilog", "systemverilog" },
  root_markers = { "vide.toml", ".git" },
})

vim.lsp.enable("vide")
