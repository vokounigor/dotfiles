return {
	"mfussenegger/nvim-lint",
	event = {
		"BufReadPre",
		"BufNewFile",
	},
	config = function()
		local function refresh_eslint(bufnr)
			bufnr = bufnr or vim.api.nvim_get_current_buf()
			if not vim.api.nvim_buf_is_valid(bufnr) then
				return
			end

			local uri = vim.uri_from_bufnr(bufnr)
			for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "eslint" })) do
				client:notify("textDocument/didSave", { textDocument = { uri = uri } })
			end
		end

		vim.keymap.set("n", "<leader>l", function()
			refresh_eslint()
		end, { desc = "Trigger linting for current file" })
	end,
}
