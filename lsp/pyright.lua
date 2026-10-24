-- lsp/pyright.lua - modular config for pyright (Python)
return {
  cmd = { "pyright-langserver", "--stdio" },
  root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
  filetypes = { "python" },
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
}