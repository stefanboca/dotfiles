return {
  -- buffer paths in top right of window
  {
    "b0o/incline.nvim",
    event = "VeryLazy",
    opts = {
      window = {
        padding = 0,
        margin = { horizontal = 0, vertical = 0 },
      },
      render = function(props)
        local buf_path = vim.api.nvim_buf_get_name(props.buf)
        local filename = vim.fn.fnamemodify(buf_path, ":t")
        if filename == "" then return end
        local dirname = vim.fn.fnamemodify(buf_path, ":~:.:h")

        local ft_icon, ft_hl, is_default = require("mini.icons").get("file", filename)
        if is_default then ft_icon = nil end
        local modified = vim.bo[props.buf].modified
        return {
          ft_icon and { " ", ft_icon, " ", group = ft_hl } or "",
          modified and { " ● ", group = "BufferLineModified" } or " ",
          dirname ~= "." and { dirname, "/", group = "Comment" } or "",
          { filename, gui = "bold" },
          " ",
        }
      end,
    },
  },

  -- statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "auto",
        component_separators = "|",
        section_separators = " ",
        globalstatus = true,
        disabled_filetypes = { statusline = { "snacks_dashboard" } },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {
          -- function() return Snacks.profiler.status() end,
            -- stylua: ignore
          {
            function() return "  " .. require("dap").status() end,
            cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
            color = function() return { fg = Snacks.util.color("Debug") } end,
          },
          {
            function()
              local venv = require("python.venv").current_venv()
              if venv then return venv.name end
            end,
            cond = function() return package.loaded["python"] and require("python.venv").current_venv ~= nil end,
          },
        },
        lualine_y = {},
        lualine_z = {
          { "progress" },
          { "location" },
        },
      },
      tabline = {
        lualine_b = {
          { "buffers", use_mode_colors = true, symbols = { alternate_file = "" }, padding = { left = 0, right = 1 } },
        },
        lualine_y = {
          {
            "tabs",
            use_mode_colors = true,
            show_modified_status = false,
            padding = { left = 1, right = 0 },
            cond = function() return vim.fn.tabpagenr("$") > 1 end,
          },
        },
        lualine_z = {
          { function() return os.date("%H:%M") end },
        },
      },
    },
  },

  -- scrollbar minimap
  {
    "lewis6991/satellite.nvim",
    event = "VeryLazy",
    opts = {},
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = { signature = { enabled = false } },
      presets = {
        bottom_search = true,
        command_palette = true,
      },
    },
  },

  {
    "echasnovski/mini.icons",
    lazy = true,
    opts = {},
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },

  {
    "snacks.nvim",
    keys = {
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
    },
    opts = {
      indent = { enabled = true },
      input = { enabled = true },
      image = { enabled = true },
      notifier = { enabled = true },
      scope = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
  },

  {
    "snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          -- stylua: ignore
          ---@type snacks.dashboard.Item[]
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "p", desc = "Projects", action = ":lua Snacks.picker.projects()" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.picker.live_grep()" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
            { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.picker.files({ cwd = vim.fn.stdpath('config') })" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
    },
  },

  {
    "echasnovski/mini.files",
    lazy = vim.fn.argc(-1) == 0, -- load early when opening a directory from cmdline
    opts = {
      options = {
        use_as_default_explorer = true,
      },
      windows = {
        preview = true,
        width_preview = 30,
      },
    },
    keys = {
      {
        "<leader>fe",
        function()
          local file = vim.api.nvim_buf_get_name(0)
          ---@diagnostic disable-next-line: cast-local-type
          if not vim.uv.fs_stat(file) then file = nil end
          MiniFiles.open(file, true)
        end,
        desc = "File Explorer",
      },
      { "<leader>e", "<leader>fe", remap = true, desc = "File Explorer" },
    },
    config = function(_, opts)
      local show_dotfiles = false
      local filter_show = function() return true end
      local filter_hide = function(fs_entry) return not vim.startswith(fs_entry.name, ".") end

      opts.content = opts.content or {}
      opts.content.filter = filter_hide
      require("mini.files").setup(opts)

      local toggle_dotfiles = function()
        show_dotfiles = not show_dotfiles
        MiniFiles.refresh({ content = { filter = show_dotfiles and filter_show or filter_hide } })
      end

      local files_set_cwd = function()
        local cur_entry_path = MiniFiles.get_fs_entry().path
        local cur_directory = vim.fs.dirname(cur_entry_path)
        if cur_directory ~= nil then vim.fn.chdir(cur_directory) end
      end

      local map_split = function(buf_id, lhs, direction, close_on_file)
        local rhs = function()
          local new_target_window
          local cur_target_window = require("mini.files").get_explorer_state().target_window
          if cur_target_window ~= nil then
            vim.api.nvim_win_call(cur_target_window, function()
              vim.cmd("belowright " .. direction .. " split")
              new_target_window = vim.api.nvim_get_current_win()
            end)

            require("mini.files").set_target_window(new_target_window)
            require("mini.files").go_in({ close_on_file = close_on_file })
          end
        end

        local desc = "Open in " .. direction .. " split"
        if close_on_file then desc = desc .. " and close" end
        vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local buf_id = args.data.buf_id

          vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id, desc = "Toggle hidden files" })
          vim.keymap.set("n", "gc", files_set_cwd, { buffer = buf_id, desc = "Set CWD" })

          map_split(buf_id, "<C-w>s", "horizontal", false)
          map_split(buf_id, "<C-w>v", "vertical", false)
          map_split(buf_id, "<C-w>S", "horizontal", true)
          map_split(buf_id, "<C-w>V", "vertical", true)
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesActionRename",
        callback = function(event) Snacks.rename.on_rename_file(event.data.from, event.data.to) end,
      })
    end,
  },
}
