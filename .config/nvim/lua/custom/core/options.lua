local opt = vim.opt

vim.cmd.colorscheme("unokai")

-- line numbers
opt.relativenumber = true -- show relative line numbers
opt.number = true -- shows absolute line number on cursor line (when relative number is on)

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one
opt.smartindent = true
opt.scrolloff = 8

-- line wrapping
opt.wrap = false -- disable line wrapping

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive
opt.hlsearch = false -- turn off search highlight

-- Appearance
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift
opt.showmatch = true
opt.cursorline = true -- highlight the current cursor line

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- File handling
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true -- Persistent undo
opt.undodir = vim.fn.expand("~/.vim/undodir") -- undo directory
opt.autoread = true -- auto reload files changed outside vim

-- Behavior settings
opt.autochdir = false
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position
opt.clipboard:append("unnamedplus") -- use system clipboard as default register
opt.iskeyword:append("-") -- consider string-string as whole word
opt.path:append("**") -- include subdirectories in search
opt.mouse = "a" -- enable mouse support
opt.modifiable = true
opt.encoding = "UTF-8"

-- CLI completion
opt.wildmenu = true
opt.wildmode = "longest:full,full"
