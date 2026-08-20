local eslint_filetypes = {
	javascript = true,
	typescript = true,
	javascriptreact = true,
	typescriptreact = true,
}

local function lsp_format_options(bufnr)
	if not eslint_filetypes[vim.bo[bufnr].filetype] then
		return { lsp_format = "never" }
	end

	return {
		lsp_format = "prefer",
		filter = function(client)
			return client.name == "eslint"
		end,
	}
end

return {
	-- Autoformat
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>p",
			function()
				local opts = lsp_format_options(0)
				opts.async = true
				require("conform").format(opts)
			end,
			mode = "",
			desc = "Format buffer",
		},
	},
	opts = {
		formatters = {
			php_cs_fixer = {
				command = function(_, context)
					local formatter = require("custom.core.project-tools").php_cs_fixer_context(context.buf)
					return formatter and formatter.command or "php-cs-fixer"
				end,
				args = { "fix", "--using-cache=no", "--stdin-path=$FILENAME", "-" },
				stdin = true,
				cwd = function(_, context)
					local formatter = require("custom.core.project-tools").php_cs_fixer_context(context.buf)
					return formatter and formatter.cwd
				end,
				require_cwd = true,
				condition = function(_, context)
					return require("custom.core.project-tools").php_cs_fixer_context(context.buf) ~= nil
				end,
			},
		},
		notify_on_error = false,
		format_after_save = function(bufnr)
			-- Disable "format_after_save lsp_fallback" for languages that don't
			-- have a well standardized coding style. You can add additional
			-- languages here or re-enable it for the disabled ones.
			local disable_filetypes = { c = true, cpp = true, php = true }
			if disable_filetypes[vim.bo[bufnr].filetype] then
				return nil
			else
				return {
					timeout_ms = 5000,
									lsp_format = lsp_format_options(bufnr).lsp_format,
									filter = lsp_format_options(bufnr).filter,
				}, function()
					vim.api.nvim_exec_autocmds("User", {
						pattern = "ConformFormatDone",
						data = { buf = bufnr },
					})
				end
			end
		end,
		formatters_by_ft = {
			lua = { "stylua" },
			php = { "php_cs_fixer" },
			-- Conform can also run multiple formatters sequentially
			-- python = { "isort", "black" },
			--
			-- You can use 'stop_after_first' to run the first available formatter from the list
		},
	},
}
