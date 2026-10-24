-- lsp/lua_ls.lua - modular config for lua_ls (Lua)
return {
  cmd = { "lua-language-server" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
  filetypes = { "lua" },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = {
        checkThirdParty = false,
        library = vim.list_extend(vim.api.nvim_get_runtime_file("", true), {
          "${3rd}/luv/library",
          "${3rd}/busted/library",
        }),
      },
      format = { enable = true },
    },
  },
}