return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		current_line_blame = true,
	},
	keys = {
		{ "<leader>gb", "<cmd>Gitsigns blame<cr>", desc = "Open git blame panel" },
	},
}

