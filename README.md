# nvim-config

My personal Neovim configuration, built around Neovim's built-in
[`vim.pack`](https://neovim.io/doc/user/pack.html) plugin manager — no third-party
package manager required.

## Requirements

- **Neovim ≥ 0.12** (required for `vim.pack`)
- [`git`](https://git-scm.com/) — used by `vim.pack` to clone/update plugins
- [Nerd Font](https://www.nerdfonts.com/) — for file icons and statusline glyphs
- A C compiler / `make` — needed to build `telescope-fzf-native.nvim` (and `LuaSnip`'s
  optional `jsregexp` on non-Windows)
- [`ripgrep`](https://github.com/BurntSushi/ripgrep) — used by Telescope's live grep
- LSP servers / formatters are installed automatically via `mason.nvim` on first launch

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

Everything lives in a single `init.lua`, organized into numbered sections:

| # | Section | Description |
|---|---|---|
| 0 | Bootstrap | Leader key, nerd font flag, module loader cache |
| 1 | Options | Editor behavior (indentation, search, UI, clipboard, shell, folding) |
| 2 | Keymaps | Window/buffer navigation, formatting, quickfix, terminal toggle |
| 3 | Autocmds | Yank highlight, cursor restore, terminal setup, content-based filetype detection for unsaved buffers |
| 4 | Plugin manager | `vim.pack` build hooks (`PackChanged`) for plugins needing compilation |
| 5 | UI plugins | Colorscheme, statusline, bufferline, git signs, indent guides, etc. |
| 6 | File explorer | `neo-tree.nvim` |
| 7 | Treesitter | Syntax highlighting, indentation, folding, textobjects |
| 8 | Telescope | Fuzzy finder for files, grep, buffers, diagnostics, etc. |
| 9 | LSP | `nvim-lspconfig` + `mason.nvim` server management |
| 10 | Completion | `nvim-cmp` + `LuaSnip` |
| 11 | Formatting | `conform.nvim` (format-on-save for Lua/Python) |

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
  `which-key.nvim`, `nvim-web-devicons`, `smear-cursor.nvim`, `neoscroll.nvim`,
  `nvim-scrollview`, `todo-comments.nvim`, `guess-indent.nvim`
- **Editing:** `nvim-autopairs`, `gitsigns.nvim`
- **Navigation:** `telescope.nvim` (+ `telescope-fzf-native.nvim`,
  `telescope-ui-select.nvim`), `neo-tree.nvim` (+ `plenary.nvim`, `nui.nvim`)
- **Syntax:** `nvim-treesitter` (+ `nvim-treesitter-textobjects`)
- **LSP/Completion:** `nvim-lspconfig`, `mason.nvim`, `mason-lspconfig.nvim`,
  `mason-tool-installer.nvim`, `fidget.nvim`, `nvim-cmp` (+ `cmp-nvim-lsp`,
  `cmp-buffer`, `cmp-path`, `cmp-cmdline`, `cmp_luasnip`), `LuaSnip` (+
  `friendly-snippets`)
- **Formatting:** `conform.nvim` (`stylua` for Lua)

The full pinned list with exact commits is in `nvim-pack-lock.json`.

## LSP servers

Currently configured (see the `servers` table in `init.lua`):

- `lua_ls` — tuned to recognize the Neovim runtime API when editing this config
  itself, but defers to a project's own `.luarc.json`/`.luarc.jsonc` if present

Add more servers by appending to the `servers` table, e.g.:

```lua
local servers = {
  lua_ls = { ... },
  pyright = {},
  ts_ls = {},
}
```

`mason-tool-installer.nvim` automatically installs whatever is added to that table.

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

### File explorer & search

| Keymap | Action |
|---|---|
| `<leader>te` | Toggle file explorer (`neo-tree.nvim`) |
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

### Git (`gitsigns.nvim`, buffer-local)

| Keymap | Action |
|---|---|
| `]c` / `[c` | Next / previous hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hb` | Blame line |
| `<leader>hd` | Diff this |

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

## Notes

- Search highlighting (`hlsearch`) is enabled; press `<Esc>` in Normal mode to
  clear it after a search.
- Unsaved (`[No Name]`) buffers get a best-effort filetype guess from their
  content (currently covers Lua, Python, JSON, C, C++) so pasted code gets
  syntax highlighting and LSP attachment without saving first. See the
  `guesses` table in the Autocmds section to extend it to more languages.
- Format-on-save is enabled only for Lua and Python; other filetypes format
  on demand via `<leader>f`.

## License

[MIT](LICENSE) — feel free to fork and adapt.
