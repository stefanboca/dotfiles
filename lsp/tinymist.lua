local lspconfig = require("my.utils.lsp").lspconfig("tinymist")

---@type boolean
local scroll_enabled = true
local open_previews = {}

local function preview_start_or_open(client, bufnr)
  if open_previews[bufnr] then
    vim.notify("Opening preview", vim.log.levels.INFO)
    vim.ui.open(open_previews[bufnr].uri)
    return
  end

  local file = vim.api.nvim_buf_get_name(bufnr)

  client:exec_cmd({
    command = "tinymist.doStartPreview",
    title = "Start Preview",
    arguments = {
      {
        "--partial-rendering",
        "--data-plane-host",
        "127.0.0.1:0",
        "--control-plane-host",
        "127.0.0.1:0",
        "--static-file-host",
        "127.0.0.1:0",
        "--task-id",
        tostring(bufnr),
        "--",
        file,
      },
    },
  }, { bufnr = bufnr }, function(err, result)
    if err then return end

    vim.notify("Preview started", vim.log.levels.INFO)
    local uri = "http://" .. result.staticServerAddr
    vim.ui.open(uri)
    open_previews[bufnr] = {
      uri = uri,
      client_id = client.id,
    }
  end)
end

local function preview_scrollSource(err, result, ctx)
  if err then return end

  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if not client then return end

  vim.lsp.util.show_document({
    uri = vim.uri_from_fname(result.filepath),
    range = {
      start = { line = result.start[1], character = result.start[2] },
      ["end"] = { line = result["end"][1], character = result["end"][2] },
    },
  }, client.offset_encoding, { reuse_win = true })
end

---@param client vim.lsp.Client
---@param bufnr integer
---@param notify_not_started boolean
local function preview_stop(client, bufnr, notify_not_started)
  if not open_previews[bufnr] then
    if notify_not_started then vim.notify("Preview not started", vim.log.levels.ERROR) end
    return
  end

  client:exec_cmd({
    command = "tinymist.doKillPreview",
    title = "Stop Preview",
    arguments = { tostring(bufnr) },
  }, { bufnr = bufnr })

  open_previews[bufnr] = nil
  vim.notify("Stopped preview")
end

local function preview_dispose(err, result)
  if err then return end
  local bufnr = tonumber(result.taskId)
  if bufnr then open_previews[bufnr] = nil end
end

---@type vim.lsp.Config
return {
  handlers = {
    ["tinymist/preview/scrollSource"] = preview_scrollSource,
    ["tinymist/preview/dispose"] = preview_dispose,
  },
  on_attach = {
    function(client, bufnr)
      local group = vim.api.nvim_create_augroup("tinymist_preview." .. tostring(bufnr), { clear = true })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = group,
        buffer = bufnr,
        callback = function()
          if not open_previews[bufnr] or not scroll_enabled then return end
          if not client.attached_buffers[bufnr] or client:is_stopped() then return true end

          local cursor = vim.api.nvim_win_get_cursor(0)
          local filepath = vim.api.nvim_buf_get_name(bufnr)
          vim.schedule(
            function()
              client:exec_cmd({
                command = "tinymist.scrollPreview",
                title = "Scroll Preview",
                arguments = {
                  tostring(bufnr),
                  { event = "panelScrollTo", filepath = filepath, line = cursor[1] - 1, character = cursor[2] },
                },
              }, { bufnr = bufnr })
            end
          )
        end,
      })
      vim.api.nvim_create_autocmd("BufDelete", {
        group = group,
        buffer = bufnr,
        callback = function() preview_stop(client, bufnr, false) end,
      })

      vim.keymap.set(
        "n",
        "<localleader>p",
        function() preview_start_or_open(client, bufnr) end,
        { buffer = bufnr, desc = "Start/Open Typst Preview" }
      )

      vim.keymap.set(
        "n",
        "<localleader>s",
        function() preview_stop(client, bufnr, true) end,
        { buffer = bufnr, desc = "Stop Typst Preview" }
      )

      vim.keymap.set("n", "<localleader>S", function()
        scroll_enabled = not scroll_enabled
        if scroll_enabled then
          vim.notify("Autoscroll enabled", vim.log.levels.INFO)
        else
          vim.notify("Autoscroll disabled", vim.log.levels.INFO)
        end
      end, { buffer = bufnr, desc = "Toggle Autoscroll" })
    end,
    lspconfig and lspconfig.on_attach,
  },
  on_exit = function(_, _, client_id)
    for bufnr, data in pairs(open_previews) do
      if data.client_id == client_id then
        vim.keymap.del("n", "<localleader>p", { buffer = bufnr })
        vim.keymap.del("n", "<localleader>s", { buffer = bufnr })
        vim.keymap.del("n", "<localleader>S", { buffer = bufnr })
        open_previews[bufnr] = nil
      end
    end
  end,
}
