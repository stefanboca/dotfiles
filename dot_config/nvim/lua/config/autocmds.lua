-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local function augroup(name)
  return vim.api.nvim_create_augroup("custom_" .. name, { clear = true })
end

-- TODO: why doesn't FileType fire when opening files from the cli?

-- Typst config
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("typst"),
  pattern = { "typst" },
  callback = function(event)
    local bufnr = event.buf

    -- enable spelling
    vim.bo[bufnr].textwidth = 80
    vim.opt_local.spell = true

    -- add autopairs
    local pairs = require("mini.pairs")
    pairs.map_buf(bufnr, "i", " ", { action = "open", pair = "  ", neigh_pattern = "%$%$" })
    pairs.map_buf(bufnr, "i", "$", { action = "closeopen", pair = "$$" })
    pairs.map_buf(bufnr, "i", "`", { action = "closeopen", pair = "``" })
    -- * and _ are not autopaired because they can be used in math equations

    vim.api.nvim_buf_set_keymap(
      bufnr,
      "n",
      "<localleader>s",
      "<cmd>TypstPreviewSyncCursor<cr>",
      { desc = "Typst Preview Sync Cursor" }
    )
  end,
})

-- set fish indent width to 4 to match fish_indent
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("fish"),
  pattern = { "fish" },
  callback = function(event)
    local bufnr = event.buf
    vim.bo[bufnr].shiftwidth = 4
    vim.bo[bufnr].tabstop = 4
  end,
})

-- autoclose on write for interactuve vcs tasks
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("vcs_delete"),
  pattern = { "gitcommit", "gitrebase", "jj", "jjdescription" },
  callback = function(event)
    vim.opt_local.spell = true

    vim.api.nvim_create_autocmd("BufWritePost", {
      group = augroup("vcs_delete_buf_" .. event.buf),
      buffer = event.buf,
      once = true,
      callback = vim.schedule_wrap(function()
        Snacks.bufdelete({ buf = event.buf, wipe = true })
        if vim.g.desc_quit_on_write then
          require("persistence").stop()
          vim.cmd([[quit]])
        end
      end),
    })
  end,
})
