return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		dependencies = {
			"windwp/nvim-ts-autotag",
		},
		config = function()
			for _, path in ipairs({ "/opt/homebrew/bin", "/usr/local/bin" }) do
				if vim.fn.isdirectory(path) == 1 and not vim.env.PATH:find(path, 1, true) then
					vim.env.PATH = path .. ":" .. vim.env.PATH
				end
			end

			local treesitter = require("nvim-treesitter")
			local parsers = {
				"php",
				"json",
				"javascript",
				"typescript",
				"tsx",
				"yaml",
				"html",
				"css",
				"markdown",
				"bash",
				"lua",
				"dockerfile",
			}
			local filetypes = {
				"php",
				"json",
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
				"yaml",
				"html",
				"css",
				"markdown",
				"markdown_inline",
				"bash",
				"lua",
				"dockerfile",
			}

			treesitter.setup({})
			treesitter.install(parsers)
			require("nvim-ts-autotag").setup()

			vim.api.nvim_create_autocmd("FileType", {
				pattern = filetypes,
				callback = function(event)
					vim.treesitter.start(event.buf)
					vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},
}
