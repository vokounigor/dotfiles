return {
	"pmizio/typescript-tools.nvim",
	dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
	opts = {},
	config = function()
		local api = require("typescript-tools.api")
		local project_tools = require("custom.core.project-tools")

		require("typescript-tools").setup({
			root_dir = function(bufnr, on_dir)
				local root = project_tools.typescript_root(bufnr)
				if root then
					on_dir(root)
				end
			end,
			handlers = {
				["textDocument/publishDiagnostics"] = api.filter_diagnostics({
					6133,
					6192,
					6196,
				}),
			},
			settings = {
				separate_diagnostic_server = false,
				publish_diagnostic_on = "insert_leave",
				jsx_close_tag = {
					enable = true,
					filetypes = { "javascriptreact", "typescriptreact" },
				},
			},
		})
	end,
}
