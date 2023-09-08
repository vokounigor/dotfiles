return {
	"theprimeagen/harpoon",
	dependencies = {
	  "nvim-lua/plenary.nvim",
	},
	config = function()
		local keymap = vim.keymap

		keymap.set(
			"n",
			"<leader>a",
			"<cmd>lua require('harpoon.mark').add_file()<cr>",
			{ desc = "Mark file with harpoon" }
		)
		keymap.set(
			"n",
			"<C-e>",
			"<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>",
			{ desc = "Open quick menu" }
		)
	end,
}