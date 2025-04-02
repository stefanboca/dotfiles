vim.lsp.enable("jdtls")

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "java" } },
  },
  {
    "mason.nvim",
    opts = { ensure_installed = { "jdtls" } },
  },

  -- {
  --   "mfussenegger/nvim-jdtls",
  --   opts = {},
  -- },
}
