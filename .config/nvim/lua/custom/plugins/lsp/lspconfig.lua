return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "mason-org/mason.nvim", opts = {} },
		"mason-org/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		{ "j-hui/fidget.nvim", opts = {} },
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
			callback = function(event)
				local map = function(keys, func, desc, mode)
					mode = mode or "n"
					vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				local telescope = require("telescope.builtin")

				map("gR", telescope.lsp_references, "[G]oto [R]eferences")
				map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
				map("gd", telescope.lsp_definitions, "[G]oto [D]efinition")
				map("gi", telescope.lsp_implementations, "[G]oto [I]mplementation")
				map("<leader>fd", telescope.lsp_document_symbols, "Show document symbols")
				map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
				map("gt", telescope.lsp_type_definitions, "[G]oto [T]ype Definition")
				map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
				map("<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", "Buffer [D]iagnostics")
				map("[d", vim.diagnostic.goto_prev, "Go to previous diagnostic")
				map("]d", vim.diagnostic.goto_next, "Go to next diagnostic")
				map("K", vim.lsp.buf.hover, "Show documentation under cursor")
				map("<leader>rs", ":lsp restart<CR><CR>", "Restart LSP")
				-- map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")

				local function client_supports_method(client, method, bufnr)
					return client:supports_method(method, bufnr)
				end

				local client = vim.lsp.get_client_by_id(event.data.client_id)
				-- The following code creates a keymap to toggle inlay hints in your
				-- code, if the language server you are using supports them
				--
				-- This may be unwanted, since they displace some of your code
				if
					client
					and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf)
				then
					map("<leader>th", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
					end, "[T]oggle Inlay [H]ints")
				end
			end,
		})

		-- Diagnostic Config
		-- See :help vim.diagnostic.Opts
		vim.diagnostic.config({
			severity_sort = true,
			float = { border = "rounded", source = "if_many" },
			underline = { severity = vim.diagnostic.severity.ERROR },
			signs = vim.g.have_nerd_font and {
				text = {
					[vim.diagnostic.severity.ERROR] = "󰅚 ",
					[vim.diagnostic.severity.WARN] = "󰀪 ",
					[vim.diagnostic.severity.INFO] = "󰋽 ",
					[vim.diagnostic.severity.HINT] = "󰌶 ",
				},
			} or {},
			virtual_text = {
				source = "if_many",
				spacing = 2,
				format = function(diagnostic)
					local diagnostic_message = {
						[vim.diagnostic.severity.ERROR] = diagnostic.message,
						[vim.diagnostic.severity.WARN] = diagnostic.message,
						[vim.diagnostic.severity.INFO] = diagnostic.message,
						[vim.diagnostic.severity.HINT] = diagnostic.message,
					}
					return diagnostic_message[diagnostic.severity]
				end,
			},
		})

		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

		--  Add any additional override configuration in the following tables. Available keys are:
		--  - cmd (table): Override the default command used to start the server
		--  - filetypes (table): Override the default list of associated filetypes for the server
		--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
		--  - settings (table): Override the default settings passed when initializing the server.
		local license_path = vim.fn.expand("~/intelephense/licence.txt")
		local license_key
		if vim.fn.filereadable(license_path) == 1 then
			for _, line in ipairs(vim.fn.readfile(license_path)) do
				local value = line:match("^%s*(.-)%s*$")
				if value ~= "" then
					license_key = value
					break
				end
			end
		end

		local intelephense_settings = {}
		if license_key then
			intelephense_settings.intelephense = { licenceKey = license_key }
		end

		-- To enable Tailwind for a project, add tailwindcss = {} here and tailwindcss-language-server to ensure_installed.
		local servers = {
			-- clangd = {},
			-- gopls = {},
			-- pyright = {},
			-- rust_analyzer = {},
			-- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
			--
			-- Some languages (like typescript) have entire language plugins that can be useful:
			--    https://github.com/pmizio/typescript-tools.nvim
			--
			-- But for many setups, the LSP (`ts_ls`) will work just fine
			-- ts_ls = {},
			--

			lua_ls = {
				root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
				settings = {
					Lua = {
						completion = {
							callSnippet = "Replace",
						},
					},
				},
			},

			intelephense = {
				root_markers = { "composer.json", ".git" },
				filetypes = { "php" },
				settings = intelephense_settings,
				root_dir = function(bufnr, on_dir)
					local filename = vim.api.nvim_buf_get_name(bufnr)
					local dirname = filename == "" and vim.fn.getcwd() or vim.fs.dirname(filename)
					local git = vim.fs.find(".git", { path = dirname, upward = true, type = "directory" })[1]
					if git then
						on_dir(vim.fs.dirname(git))
						return
					end

					local composer = vim.fs.find("composer.json", { path = dirname, upward = true, type = "file" })[1]
					on_dir(composer and vim.fs.dirname(composer) or dirname)
				end,
				before_init = function(params, config)
					local include_paths = require("custom.core.project-tools").composer_include_paths(config.root_dir)
					local settings = vim.tbl_deep_extend("force", config.settings or params.settings or {}, {
						intelephense = {
							environment = { includePaths = include_paths },
						},
					})
					params.settings = settings
					config.settings = settings
				end,
			},

			eslint = {
				filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
				root_markers = {
					"eslint.config.js",
					"eslint.config.mjs",
					"eslint.config.cjs",
					"eslint.config.ts",
					"eslint.config.mts",
					"eslint.config.cts",
					".eslintrc",
					".eslintrc.js",
					".eslintrc.cjs",
					".eslintrc.json",
					".eslintrc.yaml",
					".eslintrc.yml",
				},
				root_dir = function(bufnr, on_dir)
					local root = require("custom.core.project-tools").eslint_root(bufnr)
					if root then
						on_dir(root)
					end
				end,
				settings = {
					workingDirectory = { mode = "location" },
					format = { enable = true },
				},
			},
		}

		local ensure_installed = {
			"lua-language-server",
			"intelephense",
			"eslint-lsp",
			"php-cs-fixer",
			"stylua",
		}
		require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

		require("mason-lspconfig").setup({
			ensure_installed = {},
			automatic_enable = false,
		})

		for server_name, server in pairs(servers) do
			server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
			vim.lsp.config(server_name, server)
			vim.lsp.enable(server_name)
		end
	end,
}
