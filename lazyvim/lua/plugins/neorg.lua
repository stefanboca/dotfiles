return {
  {
    "benlubas/neorg-conceal-wrap",
    ft = { "norg" },
    cmd = { "Neorg" },
  },
  {
    "benlubas/neorg-interim-ls",
    ft = { "norg" },
    cmd = { "Neorg" },
  },
  {
    "benlubas/neorg-se",
    ft = { "norg" },
    cmd = { "Neorg" },
  },
  {
    "nvim-neorg/neorg",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-neorg/neorg-telescope" },
      { "benlubas/neorg-conceal-wrap" },
      { "benlubas/neorg-interim-ls" },
      { "benlubas/neorg-se" },
    },
    ft = { "norg" },
    cmd = { "Neorg" },
    opts = {
      load = {
        ["core.defaults"] = {},
        ["core.concealer"] = {},
        ["core.completion"] = { config = { engine = { module_name = "external.lsp-completion" } } },
        ["core.dirman"] = {
          config = {
            workspaces = {
              notes = "~/data/notes",
            },
          },
        },
        ["core.integrations.nvim-cmp"] = {},
        ["core.integrations.otter"] = {},
        ["core.integrations.telescope"] = {},
        ["external.conceal-wrap"] = {},
        ["external.interim-ls"] = {
          config = {
            completion_provider = {
              enable = true,
              categories = true,
            },
          },
        },
        ["external.search"] = { config = { index_on_start = true } },
      },
    },
  },
  {
    "nvim-cmp",
    opts = function(_, opts)
      table.insert(opts.sources, { name = "neorg" })
    end,
  },
}
