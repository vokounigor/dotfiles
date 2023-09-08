return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
	  "nvim-lua/plenary.nvim",
	  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	  "nvim-tree/nvim-web-devicons",
	},
	config = function()
	  local telescope = require("telescope")
	  local actions = require("telescope.actions")
  
	  telescope.setup({
		defaults = {
		  path_display = { "truncate " },
		  mappings = {
			i = {
			  ["<C-k>"] = actions.move_selection_previous, -- move to prev result
			  ["<C-j>"] = actions.move_selection_next, -- move to next result
			  ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
			},
		  },
		  file_ignore_patterns = { "node_modules", "vendor" },
		},
	  })
  
	  telescope.load_extension("fzf")
  
	  -- set keymaps
	  local keymap = vim.keymap -- for conciseness
  
	  keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
	  keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
	  keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
	  keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
	  keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>") -- list open buffers in current neovim instance

	  -- telescope git commands
	  keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<cr>") -- list all git commits (use <cr> to checkout) ["gc" for git commits]
	  keymap.set("n", "<leader>gfc", "<cmd>Telescope git_bcommits<cr>") -- list git commits for current file/buffer (use <cr> to checkout) ["gfc" for git file commits]
	  keymap.set("n", "<leader>gb", "<cmd>Telescope git_branches<cr>") -- list git branches (use <cr> to checkout) ["gb" for git branch]
	  keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<cr>") -- list current changes per file with diff preview ["gs" for git status]
	end,
}
  