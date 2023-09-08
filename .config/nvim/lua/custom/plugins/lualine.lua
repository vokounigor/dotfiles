return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local lualine = require("lualine")
		lualine.setup()
	end,
	settings = {
		options = {
			icons_enabled = false,
			theme = 'onedark',
			component_separators = '|',
			section_separators = '',
		}
	}
}