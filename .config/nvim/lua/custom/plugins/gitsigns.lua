return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = true,
  setup = {
    current_line_blame = true,
  }
}
