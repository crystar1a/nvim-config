-- ====================================
-- init.lua - crystaria's neovim config
-- ====================================

--@diagnostic disable: missing-fields

-- ===========
-- 0. BOOTSRAP
-- ===========

vim.loader.enable() -- enable the Lua module loader cache for faster startup

-- Set `space` as the key leader
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.g.have_nerd_font = true -- flag used later to conditionally enable icon plugins

-- ==========
-- 1. OPTIONS
-- ==========

vim.o.number = true -- show absolute line numbers
-- vim.o.relativenumber = true
vim.o.cursorline = true --show which line cursor is on
vim.o.signcolumn = "yes" -- always reserve a column for signs (git, diagnostics) to avoid text shifting
vim.o.scrolloff = 8 -- keep 8 lines visible above/below cursor when scrolling
vim.o.sidescrolloff = 8 -- keep 8 columns visible left/right of cursor when scrolling horizontally

vim.o.tabstop = 4 -- width of a tab character in spaces
vim.o.shiftwidth = 4 -- width used for indent operations (>>, <<)
vim.o.softtabstop = 4 -- number of spaces inserted/removed when pressing Tab/Backspace
vim.o.expandtab = true -- convert tabs to spaces
vim.o.smartindent = true -- auto-indent new lines based on syntax
vim.o.breakindent = true -- preserve indentation when a long line wraps visually

vim.o.ignorecase = true -- case-insensitive search by default
vim.o.smartcase = true -- become case-sensitive if the search pattern contains uppercase letters
vim.o.hlsearch = false -- don't keep all matches highlighted after a search
vim.o.incsearch = true -- show search matches incrementally as you type

vim.o.termguicolors = true -- enable 24-bit RGB colors in the terminal
vim.o.showmode = false -- don't show mode (e.g. -- INSERT --) in the command line (handled by statusline)
vim.o.laststatus = 3 -- use a single global statusline instead of one per window
vim.o.cmdheight = 1 -- height of the command line area
vim.o.showtabline = 2 -- always show tabline

vim.o.updatetime = 200 -- shorter delay (ms) before triggering CursorHold and swap writes
vim.o.timeoutlen = 300 -- time (ms) to wait for a mapped key sequence to complete
vim.o.undofile = true -- persist undo history to disk between sessions
vim.o.confirm = true -- prompt to save changes instead of failing when closing unsaved buffers
vim.o.splitright = true -- open new vertical splits to the right
vim.o.splitbelow = true -- open new horizontal splits below

vim.o.mouse = "a" -- enable mouse support in all modes

-- Use pwsh (PowerShell 7) as the shell for :terminal and :! commands instead of cmd.exe
if vim.fn.has("win32") == 1 then
	vim.o.shell = "pwsh"
	vim.o.shellcmdflag =
		"-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
	vim.o.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
	vim.o.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
	vim.o.shellquote = ""
	vim.o.shellxquote = ""
end

-- Sync clipboard after UiEnter so it doesn't slow down startup
vim.schedule(function()
	vim.o.clipboard = "unnamedplus" -- use the system clipboard as the default register
end)

-- Basic folding for now; switched to treesitter folding later in the config
vim.o.foldmethod = "indent"
vim.o.foldlevel = 99 -- open all folds by default

-- ==========
-- 2. KEYMAPS
-- ==========

-- Helper to define keymaps with silent=true by default
local map = function(mode, lsh, rhs, opts)
	opts = vim.tbl_extend("force", { silent = true }, opts or {})
	vim.keymap.set(mode, lsh, rhs, opts)
end

-- Better window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Resize windows with arrow keys
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Buffer navigation
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- Move selected lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centered while scrolling/searching
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Paste without overwriting the unnamed register with the replaced text
map("x", "<leader>p", [["_dP]], { desc = "Paste without overwrite" })

-- Delete into the void/black-hole register (don't clobber the clipboard)
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete to void" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Format current buffer/selection with conform.nvim
map({ "n", "v" }, "<leader>f", function()
	require("conform").format({ async = true })
end, { desc = "Format buffer" })

-- Quickfix navigation
map("n", "<leader>qo", "<cmd>copen<CR>", { desc = "Open quickfix" })
map("n", "<leader>qc", "<cmd>cclose<CR>", { desc = "Close quickfix" })
map("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix" })
map("n", "[q", "<cmd>cprev<CR>", { desc = "Prev quickfix" })

-- Toggle terminal from bottom window, opened in the current file's directory
map("n", "<leader>tt", function()
	local wins = vim.api.nvim_list_wins()
	for _, win in ipairs(wins) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].buftype == "terminal" then
			vim.api.nvim_win_close(win, false)
			return
		end
	end

	-- Use the current buffer's directory, falling back to cwd for unnamed buffers
	local name = vim.api.nvim_buf_get_name(0)
	local dir = name ~= "" and vim.fn.fnamemodify(name, ":p:h") or vim.fn.getcwd()

	vim.cmd("below split")
	vim.cmd("lcd " .. vim.fn.fnameescape(dir)) -- window-local cwd, only affects this split
	vim.cmd("terminal")
end, { desc = "[T]oggle [T]erminal" })

-- ===========
-- 3. AUTOCMDS
-- ===========

-- Helper to create a namespaced augroup (prefixed with "crystaria_")
local augroup = function(name)
	return vim.api.nvim_create_augroup("crystaria_" .. name, { clear = true })
end

-- Briefly highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("yank_highlight"),
	callback = function()
		vim.hl.on_yank({ higroup = "IncSearch", timeout = 275 })
	end,
})

-- Auto-resize splits equally when the terminal window is resized
vim.api.nvim_create_autocmd("VimResized", {
	group = augroup("resize_splits"),
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
})

-- Restore cursor to the last known position when reopening a file
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup("restore_cursor"),
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Disable line numbers/signcolumn and enter insert mode in terminal buffers
vim.api.nvim_create_autocmd("TermOpen", {
	group = augroup("term_options"),
	callback = function()
		vim.o.number = false
		vim.o.relativenumber = false
		vim.o.signcolumn = "no"
		vim.cmd("startinsert")
	end,
})

-- Best-effort filetype detection for unsaved [No Name] buffers, based on content.
-- Neovim's built-in detection is filename-driven, so pasted/unsaved code with no
-- file association is never checked against any pattern - this fills that gap.
-- Add more entries to `guesses` below as needed (kept minimal: lua/py/json/c/cpp).
local function guess_filetype_from_content(bufnr)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 50, false)
	local text = table.concat(lines, "\n")
	if text:match("^%s*$") then
		return nil
	end

	local guesses = {
		{
			ft = "lua",
			pat = { "^%-%-", "^%s*local%s+%w+%s*=", "^%s*require%s*%(", "^%s*function%s+[%w_.:]+%s*%(", "^%s*vim%." },
		},
		{
			ft = "python",
			pat = {
				"^%s*def%s+%w+%s*%(",
				"^%s*import%s+%w+",
				"^%s*from%s+[%w_.]+%s+import",
				"^%s*class%s+%w+.-:%s*$",
				"^%s*if%s+__name__%s*==",
			},
		},
		{ ft = "json", pat = { '^%s*{%s*"[%w_%-]+"%s*:', "^%s*%[%s*{" } },
		{ ft = "cpp", pat = { "#include%s*<iostream>", "std::%w+", "^%s*class%s+%w+%s*{", "^%s*namespace%s+%w+" } },
		{ ft = "c", pat = { "#include%s*<[%w_.]+%.h>", "^%s*int%s+main%s*%(", "printf%s*%(" } },
		-- { ft = "javascript", pat = { "^%s*const%s+%w+%s*=", "console%.log%(", "=>%s*{" } },
		-- { ft = "typescript", pat = { "interface%s+%w+%s*{", "export%s+default", ":%s*string" } },
		-- { ft = "rust", pat = { "^%s*fn%s+%w+%s*%(", "^%s*let%s+mut%s+", "^%s*use%s+%w+::" } },
		-- { ft = "go", pat = { "^%s*package%s+%w+", "^%s*func%s+%w+%s*%(" } },
		-- { ft = "html", pat = { "^%s*<!DOCTYPE", "^%s*<html", "^%s*<div" } },
		-- { ft = "sh", pat = { "^#!/bin/", "^%s*echo%s+", "^%s*if%s*%[%[?" } },
	}

	for _, entry in ipairs(guesses) do
		for _, pat in ipairs(entry.pat) do
			if text:match(pat) then
				return entry.ft
			end
		end
	end
	return nil
end

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufEnter" }, {
	group = augroup("guess_filetype"),
	callback = function(ev)
		local buf = ev.buf
		-- Only touch unnamed buffers that don't already have a filetype set
		if vim.api.nvim_buf_get_name(buf) ~= "" or vim.bo[buf].filetype ~= "" then
			return
		end
		local ft = guess_filetype_from_content(buf)
		if ft then
			vim.bo[buf].filetype = ft
		end
	end,
})

-- ========================================
-- 4. PLUGIN MANAGER - vim.pack build hooks
-- ========================================

-- Run a build command for a plugin and notify on failure
local function run_build(name, cmd, cwd)
	local result = vim.system(cmd, { cwd = cwd }):wait()
	if result.code ~= 0 then
		local out = result.stderr ~= "" and result.stderr or result.stdout
		vim.notify(("Build failed [%s]:\n%s"):format(name, out or "no output"), vim.log.levels.ERROR)
	end
end

-- Run post-install/update build steps for plugins that need compilation
vim.api.nvim_create_autocmd("PackChanged", {
	group = augroup("pack_build"),
	callback = function(ev)
		local name = ev.data.spec.name
		if ev.data.kind ~= "install" and ev.data.kind ~= "update" then
			return
		end

		if name == "telescope-fzf-native.nvim" and vim.fn.executable("make") == 1 then
			run_build(name, { "make" }, ev.data.path)
		elseif name == "LuaSnip" and vim.fn.has("win32") ~= 1 and vim.fn.executable("make") == 1 then
			run_build(name, { "make", "install_jsregexp" }, ev.data.path)
		elseif name == "nvim-treesitter" then
			if not ev.data.active then
				vim.cmd.packadd("nvim-treesitter")
			end
			vim.cmd("TSUpdate")
		end
	end,
})

-- Helper: shorthand for building a GitHub URL from "owner/repo"
local function gh(repo)
	return "https://github.com/" .. repo
end

-- =============
-- 5. UI PLUGINS
-- =============

-- Smooth scrolling animation
vim.pack.add({ gh("karb94/neoscroll.nvim") })
require("neoscroll").setup({
	mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "zt", "zz", "zb" },
	hide_cursor = true,
	stop_eof = true,
	easing = "quadratic",
})

-- Display interactive vertical scrollbar and signs
vim.pack.add({ gh("dstein64/nvim-scrollview") })
require("scrollview").setup({
	excluded_filetypes = { "nerdtree" },
	current_only = true,
	base = "right",
	signs_on_startup = { "diagnostics" },
	diagnostic_severities = { vim.diagnostic.severity.ERROR },
})

-- File icons (requires a nerd font)
if vim.g.have_nerd_font then
	vim.pack.add({ gh("nvim-tree/nvim-web-devicons") })
end

-- Colorscheme
vim.pack.add({ gh("mofiqul/dracula.nvim") })
require("dracula").setup({
	transparent_bg = true,
	styles = {
		sidebars = "transparent",
		floats = "transparent",
		comments = { italic = false },
	},
	override = {
		BufferLineFill = { bg = "#ff0000" },
		BufferLineBackground = { bg = "#ff0000" },
	},
})
vim.cmd.colorscheme("dracula")

-- Statusline: lualine (replaces mini.statusline)
vim.pack.add({ gh("nvim-lualine/lualine.nvim") })
require("lualine").setup({
	options = {
		theme = "dracula",
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		globalstatus = true,
		disabled_filetypes = { statusline = { "neo-tree", "alpha" } },
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { { "filename", path = 1, symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" } } },
		lualine_x = {
			{
				"encoding",
				cond = function()
					return vim.o.fileencoding ~= "utf-8" -- only show encoding when it's not utf-8
				end,
			},
			"fileformat",
			"filetype",
		},
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
	inactive_sections = {
		lualine_c = { { "filename", path = 1 } },
		lualine_x = { "location" },
	},
})

-- Buffer Line
vim.pack.add({ gh("akinsho/bufferline.nvim") })
require("bufferline").setup({
	options = {
		mode = "buffers",
		separator_style = "slank", -- "thin", "padded_slant"
		show_buffer_close_icons = true,
		show_close_icon = false,
		diagnostics = "nvim_lsp", -- tab show lSP errors on tab
		diagnostics_indicator = function(_, _, diag)
			local ret = (diag.error and "" .. diag.error .. " " or "") .. (diag.warning and " " .. diag.warning or "")
			return vim.trim(ret)
		end,
		offsets = {
			{ filetype = "NvimTree", text = "File Explorer", padding = 1 },
		},
	},
})

-- Git change indicators in the sign column
vim.pack.add({ gh("lewis6991/gitsigns.nvim") })
require("gitsigns").setup({
	signs = {
		add = { text = "▎" },
		change = { text = "▎" },
		delete = { text = "" },
		topdelete = { text = "" },
		changedelete = { text = "▎" },
		untracked = { text = "▎" },
	},
	on_attach = function(bufnr)
		local gs = package.loaded.gitsigns
		-- Helper for buffer-local gitsigns keymaps
		local bmap = function(mode, l, r, desc)
			map(mode, l, r, { buffer = bufnr, desc = desc })
		end
		bmap("n", "]c", function()
			if vim.wo.diff then
				vim.cmd("normal! ]c") -- fall back to native diff navigation when in diff mode
			else
				gs.next_hunk()
			end
		end, "Next hunk")
		bmap("n", "[c", function()
			if vim.wo.diff then
				vim.cmd("normal! [c")
			else
				gs.prev_hunk()
			end
		end, "Prev hunk")
		bmap("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
		bmap("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
		bmap("n", "<leader>hb", gs.blame_line, "Blame line")
		bmap("n", "<leader>hd", gs.diffthis, "Diff this")
	end,
})

-- Indentation guide lines
vim.pack.add({ gh("lukas-reineke/indent-blankline.nvim") })
require("ibl").setup({
	indent = { char = "│", tab_char = "│" },
	scope = { enabled = true, show_start = false, show_end = false },
	exclude = {
		filetypes = { "help", "neo-tree", "lazy", "mason", "notify", "toggleterm" },
	},
})

-- Auto-close brackets/quotes
vim.pack.add({ gh("windwp/nvim-autopairs") })
require("nvim-autopairs").setup({
	check_ts = true, -- use treesitter to check context before pairing
	ts_config = { lua = { "string" }, javascript = { "template_string" } },
	fast_wrap = {
		map = "<M-e>",
		chars = { "{", "[", "(", '"', "'" },
		pattern = [=[[%'%"%>%]%)%}%,]]=],
		end_key = "$",
	},
})

-- Todo comments (highlight FIX, HACK, NOTE, TODO, WARN)
vim.pack.add({ gh("folke/todo-comments.nvim") })
require("todo-comments").setup({ signs = false })

-- Which-key: show keymap hints/popup
vim.pack.add({ gh("folke/which-key.nvim") })
require("which-key").setup({
	delay = 500,
	icons = { mappings = vim.g.have_nerd_font },
	win = {
		no_overlap = true,
		border = "rounded",
		padding = { 1, 2 },
		title = true,
		title_pos = "center",
	},
	layout = {
		width = { min = 20 },
		spacing = 3,
	},
	preset = "helix", -- "classic", "helix"
})
-- Group labels shown in the which-key popup
require("which-key").add({
	{ "<leader>b", group = "Buffer" },
	{ "<leader>h", group = "Git Hunk" },
	{ "<leader>s", group = "Search" },
	{ "<leader>t", group = "Toggle" },
	{ "<leader>q", group = "Quickfix" },
})

-- Auto-detect indentation settings per file
vim.pack.add({ gh("NMAC427/guess-indent.nvim") })
require("guess-indent").setup({})

-- Smear Cursor
vim.pack.add({ "https://github.com/sphamba/smear-cursor.nvim" })
require("smear_cursor").setup({
	cursor_color = "#ffffff",
	gradient_exponent = 0,
	particles_enabled = true,
	particle_spread = 1,
	particles_per_second = 100,
	particles_per_length = 50,
	particle_max_lifetime = 1500,
	particle_max_initial_velocity = 10,
	particle_velocity_from_cursor = 0,
	particle_random_velocity = 300,
	particle_damping = 0.1,
	particle_gravity = 50,
})

-- ===========================
-- 6. FILE EXPLORER - neo-tree
-- ===========================

vim.pack.add({ gh("nvim-lua/plenary.nvim") }) -- dependency: utility functions library
vim.pack.add({ gh("MunifTanjim/nui.nvim") }) -- dependency: UI component library
vim.pack.add({ gh("nvim-neo-tree/neo-tree.nvim") })
require("neo-tree").setup({
	close_if_last_window = true, -- close neo-tree if it's the only window left
	popup_border_style = "rounded",
	window = { position = "left", width = 30 },
	default_component_configs = {
		git_status = {
			symbols = {
				added = "",
				modified = "",
				deleted = "✖",
				renamed = "",
				untracked = "",
				ignored = "",
				unstaged = "",
				staged = "",
				conflict = "",
			},
		},
	},
	filesystem = {
		follow_current_file = { enabled = true }, -- auto-reveal the current file in the tree
		use_libuv_file_watcher = true, -- auto-refresh tree on filesystem changes
		filtered_items = {
			visible = true, -- show fileted items grayed out instead of hiding them outright
			show_hidden_count = true,
			hide_dotfiles = false, -- show dotfiles (e.g. .gitignore, .luaarc.json)
			hide_hidden = false, -- show Windows-attribute hidden items (e.g. Appdata)
			hide_gitignored = true, -- show files ignored but .gitignore
		},
	},
})
map("n", "<leader>te", "<cmd>Neotree toggle<CR>", { desc = "[T]oggle [E]xplorer" })

-- ================================================
-- 7. TREESITTER - syntax highlight + indent + fold
-- ================================================

vim.pack.add({ gh("nvim-treesitter/nvim-treesitter") })
vim.pack.add({ gh("nvim-treesitter/nvim-treesitter-textobjects") })

local ok, configs = pcall(require, "nvim-treesitter.configs")
if ok then
	configs.setup({
		ensure_installed = { -- parsers to make sure are installed
			"lua",
			"python",
			"javascript",
			"typescript",
			"tsx",
			"html",
			"css",
			"json",
			"jsonc",
			"yaml",
			"toml",
			"markdown",
			"markdown_inline",
			"bash",
			"fish",
			"c",
			"cpp",
			"rust",
			"vim",
			"vimdoc",
			"query",
		},
		auto_install = true, -- automatically install missing parsers when opening a new filetype
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false, -- avoid double-highlighting with old regex-based syntax
		},
		indent = {
			enable = true, -- treesitter-based indentation
		},
		textobjects = {
			select = {
				enable = true,
				lookahead = true, -- automatically jump forward to textobjects on the current line
				keymaps = {
					["af"] = "@function.outer",
					["if"] = "@function.inner",
					["ac"] = "@class.outer",
					["ic"] = "@class.inner",
					["aa"] = "@parameter.outer",
					["ia"] = "@parameter.inner",
				},
			},
			move = {
				enable = true,
				set_jumps = true, -- add movements to the jumplist
				goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
				goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
				goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
				goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
			},
		},
	})
end

-- Switch folding to use treesitter
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- ===========================
-- 8. TELESCOPE - fuzzy finder
-- ===========================

vim.pack.add({ gh("nvim-telescope/telescope.nvim") })
vim.pack.add({ gh("nvim-telescope/telescope-fzf-native.nvim") }) -- native FZF sorter for faster matching
vim.pack.add({ gh("nvim-telescope/telescope-ui-select.nvim") }) -- use telescope for vim.ui.select prompts

local telescope = require("telescope")
local builtin = require("telescope.builtin")

telescope.setup({
	defaults = {
		prompt_prefix = "  ",
		selection_caret = " ",
		path_display = { "smart" },
		layout_strategy = "horizontal",
		layout_config = { preview_width = 0.55 },
		mappings = {
			i = {
				["<C-j>"] = require("telescope.actions").move_selection_next,
				["<C-k>"] = require("telescope.actions").move_selection_previous,
				["<C-u>"] = false, -- disable default scroll-up-in-preview mapping
				["<C-d>"] = require("telescope.actions").delete_buffer,
			},
		},
	},
	extensions = {
		["ui-select"] = { require("telescope.themes").get_dropdown() },
		fzf = {
			fuzzy = true,
			override_generic_sorter = true,
			override_file_sorter = true,
			case_mode = "smart_case",
		},
	},
})

pcall(telescope.load_extension, "fzf")
pcall(telescope.load_extension, "ui-select")

map("n", "<leader>sf", builtin.find_files, { desc = "Search Files" })
map("n", "<leader>sg", builtin.live_grep, { desc = "Search Grep" })
map("n", "<leader>sb", builtin.buffers, { desc = "Search Buffers" })
map("n", "<leader>sh", builtin.help_tags, { desc = "Search Help" })
map("n", "<leader>sk", builtin.keymaps, { desc = "Search Keymaps" })
map("n", "<leader>sd", builtin.diagnostics, { desc = "Search Diagnostics" })
map("n", "<leader>sr", builtin.lsp_references, { desc = "Search References" })
map("n", "<leader>sw", builtin.grep_string, { desc = "Search Word under cursor" })
map("n", "<leader><leader>", builtin.buffers, { desc = "Switch Buffer" })
map("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "Fuzzy search current buffer" })

-- ======
-- 9. LSP
-- ======

vim.pack.add({ gh("j-hui/fidget.nvim") }) -- show LSP progress notifications
require("fidget").setup({ notification = { window = { winblend = 0 } } })

vim.pack.add({
	gh("neovim/nvim-lspconfig"),
	gh("mason-org/mason.nvim"), -- LSP/DAP/linter/formatter installer
	gh("mason-org/mason-lspconfig.nvim"), -- bridges mason with lspconfig
	gh("WhoIsSethDaniel/mason-tool-installer.nvim"), -- auto-install tools on startup
})

-- Base capabilities, merged with nvim-cmp's capabilities once cmp loads
local capabilities = vim.lsp.protocol.make_client_capabilities()
-- nvim-cmp will extend these capabilities automatically once it loads (see section 10)

local servers = {
	lua_ls = {
		on_init = function(client)
			client.server_capabilities.documentFormattingProvider = false -- formatting handled by conform/stylua instead
			if client.workspace_folders then
				local path = client.workspace_folders[1].name
				if
					path ~= vim.fn.stdpath("config")
					and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
				then
					return -- respect the project's own .luarc.json if present
				end
			end
			-- Otherwise, apply settings tuned for editing this Neovim config itself
			client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua or {}, {
				runtime = { version = "LuaJIT" },
				workspace = {
					checkThirdParty = false,
					library = vim.list_extend(vim.api.nvim_get_runtime_file("", true), {
						"${3rd}/luv/library",
						"${3rd}/busted/library",
					}),
				},
			})
		end,
		settings = {
			Lua = { format = { enable = true } },
		},
	},
	-- Add more LSP servers here:
	-- pyright = {},
	-- ts_ls = {},
	-- rust_analyzer = {},
}

-- Set up keymaps and highlighting whenever an LSP client attaches to a buffer
vim.api.nvim_create_autocmd("LspAttach", {
	group = augroup("lsp_attach"),
	callback = function(event)
		local lmap = function(keys, func, desc, mode)
			map(mode or "n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		lmap("gd", vim.lsp.buf.definition, "Go to Definition")
		lmap("gD", vim.lsp.buf.declaration, "Go to Declaration")
		lmap("gr", vim.lsp.buf.references, "Go to References")
		lmap("gi", vim.lsp.buf.implementation, "Go to Implementation")
		lmap("gy", vim.lsp.buf.type_definition, "Go to Type Definition")
		lmap("K", vim.lsp.buf.hover, "Hover Docs")
		lmap("<C-s>", vim.lsp.buf.signature_help, "Signature Help", { "i", "n" })
		lmap("grn", vim.lsp.buf.rename, "Rename")
		lmap("gra", vim.lsp.buf.code_action, "Code Action", { "n", "x" })
		lmap("<leader>th", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
		end, "Toggle Inlay Hints")

		-- Auto-highlight other occurrences of the word under the cursor
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and client:supports_method("textDocument/documentHighlight", event.buf) then
			local hl_group = augroup("lsp_highlight")
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = event.buf,
				group = hl_group,
				callback = vim.lsp.buf.document_highlight,
			})
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = event.buf,
				group = hl_group,
				callback = vim.lsp.buf.clear_references,
			})
			vim.api.nvim_create_autocmd("LspDetach", {
				group = augroup("lsp_detach"),
				callback = function(ev2)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds({ group = "crystaria_lsp_highlight", buffer = ev2.buf })
				end,
			})
		end
	end,
})

require("mason").setup({ ui = { border = "rounded" } })

-- Make sure all configured LSP servers (plus stylua) are installed
local ensure_installed = vim.tbl_keys(servers)
vim.list_extend(ensure_installed, { "stylua" })
require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

-- Register and enable each configured LSP server
for name, server in pairs(servers) do
	server.capabilities = capabilities
	vim.lsp.config(name, server)
	vim.lsp.enable(name)
end

-- ===================================
-- 10. COMPLETION - nvim.cpm + LuaSnip
-- ===================================

vim.pack.add({
	gh("hrsh7th/nvim-cmp"),
	gh("hrsh7th/cmp-nvim-lsp"), -- LSP completion source
	gh("hrsh7th/cmp-buffer"), -- buffer words completion source
	gh("hrsh7th/cmp-path"), -- filesystem path completion source
	gh("hrsh7th/cmp-cmdline"), -- command-line completion source
	gh("saadparwaiz1/cmp_luasnip"), -- snippet completion source
	gh("L3MON4D3/LuaSnip"), -- snippet engine
	gh("rafamadriz/friendly-snippets"), -- community snippet collection
})

-- Load the VSCode-style snippet collection
require("luasnip.loaders.from_vscode").lazy_load()

local cmp = require("cmp")
local luasnip = require("luasnip")

-- Merge LSP capabilities into cmp's capabilities
local cmp_lsp_caps = require("cmp_nvim_lsp").default_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp_caps)
-- Re-apply the updated capabilities to all already-registered servers
for name, server in pairs(servers) do
	server.capabilities = capabilities
	vim.lsp.config(name, server)
end

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	completion = { completeopt = "menu,menuone,noinsert" },
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		["<C-j>"] = cmp.mapping.select_next_item(),
		["<C-k>"] = cmp.mapping.select_prev_item(),
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = false }), -- only confirm when an item is explicitly selected
		-- Tab to navigate snippet placeholder fields
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_locally_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.locally_jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp", priority = 1000 },
		{ name = "luasnip", priority = 750 },
		{ name = "buffer", priority = 500, keyword_length = 3 },
		{ name = "path", priority = 250 },
	}),
	formatting = {
		format = function(entry, item)
			-- Icons shown next to each completion kind
			local kind_icons = {
				Text = "",
				Class = "",
				Function = "󰊕",
				Interface = "",
				Constructor = "",
				Module = "",
				Field = "",
				Property = "",
				Variable = "󰆧",
				Unit = "",
				Value = "󰎠",
				Enum = "",
				Keyword = "󰌋",
				Snippet = "",
				Color = "󰏘",
				File = "",
				Reference = "",
				Folder = "󰉋",
				EnumMember = "",
				Constant = "󰏿",
				Struct = "󰙅",
				Event = "",
				Operator = "󰆕",
				TypeParameter = "󰅲",
				Method = "󰆧",
			}
			item.kind = string.format("%s %s", kind_icons[item.kind] or "", item.kind)
			-- Label showing which source the completion came from
			item.menu = ({
				nvim_lsp = "[LSP]",
				luasnip = "[Snip]",
				buffer = "[Buf]",
				path = "[Path]",
			})[entry.source.name]
			return item
		end,
	},
})

-- Completion while searching with / or ?
cmp.setup.cmdline({ "/", "?" }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = { { name = "buffer" } },
})
-- Completion for ex commands (:)
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
})

-- Integrate autopairs with cmp so confirming a completion closes pairs correctly
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

-- ===========================
-- 11. FORTTING - conform.nvim
-- ===========================

vim.pack.add({ gh("stevearc/conform.nvim") })
require("conform").setup({
	notify_on_error = false, -- stay quiet when no formatter is configured for a filetype
	format_on_save = function(bufnr)
		local enabled = { lua = true, python = true } -- filetypes to auto-format on save
		if enabled[vim.bo[bufnr].filetype] then
			return { timeout_ms = 500, lsp_format = "fallback" }
		end
	end,
	formatters_by_ft = {
		lua = { "stylua" },
		-- python  = { "isort", "black" },
		-- javascript = { "prettierd", stop_after_first = true },
	},
})
