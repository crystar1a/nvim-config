-- lsp/clangd.lua - modular config for clangd (C/C++)
local msys = "C:/msys64/ucrt64"
local gcc_ver = "16.2.0"

return {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--query-driver=" .. msys .. "/bin/g++.exe," .. msys .. "/bin/gcc.exe",
  },
  root_markers = { "compile_commands.json", ".clangd", ".git" },
  filetypes = { "c", "cpp", "objc", "objcpp" },
  init_options = {
    fallbackFlags = {
      "-std=c++17",
      "-I" .. msys .. "/include",
      "-I" .. msys .. "/x86_64-w64-mingw32/include",
      "-I" .. msys .. "/lib/gcc/x86_64-w64-mingw32/" .. gcc_ver .. "/include",
      "-I" .. msys .. "/lib/gcc/x86_64-w64-mingw32/" .. gcc_ver .. "/include-fixed",
    }
  },
}