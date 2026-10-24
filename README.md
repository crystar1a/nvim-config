# nvim-config

My personal Neovim configuration, built around Neovim's built-in
[`vim.pack`](https://neovim.io/doc/user/pack.html) plugin manager.

> **Note:** this config is currently developed and used **mainly on Windows**.
> It should work on Linux/macOS as well, but those platforms get less testing,
> so expect to tweak a few things (e.g. the `pwsh` shell setup below only
> applies on Windows and is simply skipped elsewhere).

## Requirements

- **Neovim ≥ 0.12** (required for `vim.pack` and modular LSP config)
- [`git`](https://git-scm.com/) — used by `vim.pack` to clone/update plugins
- [Nerd Font](https://www.nerdfonts.com/) — for file icons and statusline glyphs
- A C compiler / `make` — needed to build `telescope-fzf-native.nvim`
- [`ripgrep`](https://github.com/BurntSushi/ripgrep) — used by Telescope's live grep
- LSP servers / formatters are installed automatically via `mason.nvim` on first launch
- **Windows (C/C++):** MSYS2 UCRT64 with `clang-tools-extra` for `clangd`, or install via `scoop install clangd`

> **Windows users:** the config sets the built-in terminal (`:terminal`) and shell
> commands (`:!`) to use `pwsh` (PowerShell 7) instead of `cmd.exe`. Make sure `pwsh`
> is available on your `PATH`, or edit the `vim.o.shell` block in `init.lua`.

## Installation

Clone this repo directly into your Neovim config directory.

**Linux / macOS**

```sh
git clone https://github.com/crystar1a/nvim-config.git ~/.config/nvim
```

**Windows**

```powershell
git clone https://github.com/crystar1a/nvim-config.git $env:LOCALAPPDATA\nvim
```

Then just launch `nvim`. On first start, `vim.pack` reads `nvim-pack-lock.json` and
clones every plugin at the exact pinned revision. Run `:restart` if prompted, and
`mason-tool-installer.nvim` will install the configured LSP servers and `stylua`
in the background.

## Structure

Everything lives in `init.lua` plus modular LSP configs in `lsp/`, organized into numbered sections:

| # | Section | Description |
|---|---|---|
| 0 | Bootstrap | Leader key, nerd font flag, module loader cache |
| 1 | Options | Editor behavior (indentation, search, UI, clipboard, shell, folding) |
| 2 | Keymaps | Window/buffer navigation, formatting, quickfix, terminal toggle |
| 3 | Autocmds | Yank highlight, cursor restore, terminal setup, content-based filetype detection for unsaved buffers |
| 4 | Plugin manager | `vim.pack` build hooks (`PackChanged`) for plugins needing compilation |
| 5 | UI plugins | Colorscheme, statusline, bufferline, indent guides, etc. |
| 6 | Treesitter | Syntax highlighting, indentation, folding, textobjects |
| 7 | Telescope | Fuzzy finder for files, grep, buffers, diagnostics, etc. |
| 8 | LSP | `nvim-lspconfig` + `mason.nvim` server management (modular configs in `lsp/`) |
| 9 | Completion | `nvim-cmp` (LSP, buffer, path, cmdline sources) |
| 10 | Formatting | `conform.nvim` (format-on-save for Lua/Python) |

**Modular LSP configs** (`lsp/` directory):
- `lsp/clangd.lua` C/C++ with MSYS2 UCRT64 paths
- `lsp/pyright.lua` Python type checking
- `lsp/lua_ls.lua` Lua/Neovim runtime API

## Plugin manager & lockfile

Plugins are declared inline via `vim.pack.add()` next to the config that uses them
— no separate plugin spec file. `nvim-pack-lock.json` pins every plugin to an exact
commit and is tracked in this repo so the setup is reproducible across machines.

```lua
-- Update all plugins and refresh the lockfile
vim.pack.update()

-- Roll back to what's pinned in the lockfile
vim.pack.update(nil, { target = "lockfile", force = true })
```

## Key plugins

- **UI:** `dracula.nvim`, `lualine.nvim`, `bufferline.nvim`, `indent-blankline.nvim`,
  `which-key.nvim`, `nvim-web-devicons`, `neoscroll.nvim`, `nvim-scrollview`, `todo-comments.nvim`
- **Navigation:** `telescope.nvim` (+ `telescope-fzf-native.nvim`, `telescope-ui-select.nvim`)
- **Syntax:** `nvim-treesitter` (+ `nvim-treesitter-textobjects`)
- **LSP/Completion:** `nvim-lspconfig`, `mason.nvim`, `mason-lspconfig.nvim`,
  `mason-tool-installer.nvim`, `fidget.nvim`, `nvim-cmp` (+ `cmp-nvim-lsp`,
  `cmp-buffer`, `cmp-path`, `cmp-cmdline`)
- **Formatting:** `conform.nvim` (`stylua` for Lua, `clang-format` for C/C++)

The full pinned list with exact commits is in `nvim-pack-lock.json`.

## LSP servers

Configured via modular configs in `lsp/` (enabled in `init.lua`):

- `lua_ls` tuned to recognize the Neovim runtime API when editing this config
  itself, but defers to a project's own `.luarc.json`/`.luarc.jsonc` if present
- `clangd` C/C++ with MSYS2 UCRT64 include paths (`C:/msys64/ucrt64`)
- `pyright` Python type checking (basic mode)

Add more servers by creating `lsp/<name>.lua` and adding to `vim.lsp.enable()` in `init.lua`.

`mason-tool-installer.nvim` automatically installs LSP servers listed in its `ensure_installed`.

## Keymaps

Leader key is `<Space>`. Press `<leader>` and wait to see all available mappings
via `which-key.nvim`.

### General

| Keymap | Mode | Action |
|---|---|---|
| `<C-h/j/k/l>` | Normal | Move between windows |
| `<C-Up/Down/Left/Right>` | Normal | Resize current window |
| `<S-h>` / `<S-l>` | Normal | Previous / next buffer |
| `<leader>bd` | Normal | Delete buffer |
| `J` / `K` | Visual | Move selected lines down / up |
| `<leader>p` | Visual | Paste without overwriting the unnamed register |
| `<leader>d` | Normal/Visual | Delete into the void register |
| `<Esc>` | Normal | Clear search highlight |
| `<leader>f` | Normal/Visual | Format buffer/selection (`conform.nvim`) |
| `<leader>qo` / `<leader>qc` | Normal | Open / close quickfix list |
| `]q` / `[q` | Normal | Next / previous quickfix entry |
| `<leader>tt` | Normal | Toggle terminal split |
| `<Esc><Esc>` | Terminal | Close terminal window |

### Search (Telescope)

| Keymap | Action |
|---|---|
| `<leader>sf` | Find files |
| `<leader>sg` | Live grep |
| `<leader>sb` | Search open buffers |
| `<leader>sh` | Search help tags |
| `<leader>sk` | Search keymaps |
| `<leader>sd` | Search diagnostics |
| `<leader>sr` | Search LSP references |
| `<leader>sw` | Search word under cursor |
| `<leader><leader>` | Switch buffer |
| `<leader>/` | Fuzzy search current buffer |

### LSP (buffer-local, on attach)

| Keymap | Action |
|---|---|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Go to references |
| `gi` | Go to implementation |
| `gy` | Go to type definition |
| `K` | Hover docs |
| `<C-s>` | Signature help (Insert/Normal) |
| `grn` | Rename |
| `gra` | Code action (Normal/Visual) |
| `<leader>th` | Toggle inlay hints |

### Treesitter textobjects

| Keymap | Selects |
|---|---|
| `af` / `if` | Function (outer/inner) |
| `ac` / `ic` | Class (outer/inner) |
| `aa` / `ia` | Parameter (outer/inner) |
| `]f` / `[f` | Next/previous function start |
| `]c` / `[c` | Next/previous class start |

## C/C++ setup (Windows + MSYS2)

For `clangd` to work with MSYS2 UCRT64:

1. Install: `pacman -S mingw-w64-ucrt-x86_64-clang-tools-extra`
2. Add `C:/msys64/ucrt64/bin` to system PATH
3. In CMake projects, generate compile commands:
   ```bash
   cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B build
   cmd /c mklink compile_commands.json build\compile_commands.json  # Admin
   ```
4. Or create `.clangd` in project root (see `lsp/clangd.lua` for fallback flags)

## Notes

- Search highlighting (`hlsearch`) is enabled; press `<Esc>` in Normal mode to
  clear it after a search.
- Unsaved (`[No Name]`) buffers get a best-effort filetype guess from their
  content (currently covers Lua, Python, JSON, C, C++) so pasted code gets
  syntax highlighting and LSP attachment without saving first. See the
  `guesses` table in the Autocmds section to extend it to more languages.
- Format-on-save is enabled only for Lua and Python; other filetypes format
  on demand via `<leader>f`.
- This config uses **modular LSP** (Neovim 0.11+): each server config lives in `lsp/<name>.lua`.

## License

[MIT](LICENSE) — feel free to fork and adapt.
