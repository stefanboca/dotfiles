return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "dockerfile" } },
  },

  {
    "neovim/nvim-lspconfig",
    opts = { enabled = { "docker-language-server" } },
  },

  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = { dockerfile = { "hadolint" } },
    },
  },
}
