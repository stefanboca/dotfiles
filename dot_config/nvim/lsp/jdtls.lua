local cache_dir = (vim.env.XDG_CACHE_HOME or (vim.env.HOME .. "/.cache")) .. "/jdtls"
local config_dir = cache_dir .. "/config"
local workspace_dir = cache_dir .. "/workspace"

local function get_jdtls_jvm_args()
  if not vim.env.JDTLS_JVM_ARGS then return end

  local args = {}
  for a in string.gmatch(vim.env.JDTLS_JVM_ARGS, "%S+") do
    local arg = string.format("--jvm-arg=%s", a)
    table.insert(args, arg)
  end

  return unpack(args)
end

---@type vim.lsp.Config
return {
  cmd = {
    "jdtls",
    "-configuration",
    config_dir,
    "-data",
    workspace_dir,
    get_jdtls_jvm_args(),
  },
  filetypes = { "java" },
  root_markers = {
    "build.gradle",
    "build.gradle.kts",
    -- Single-module projects
    "build.xml", -- Ant
    "pom.xml", -- Maven
    "settings.gradle", -- Gradle
    "settings.gradle.kts", -- Gradle
  },
  settings = {
    java = {
      configurations = {},
    },
  },
  init_options = {
    workspace = workspace_dir,
    jvm_args = {},
    os_args = nil,
  },
}
