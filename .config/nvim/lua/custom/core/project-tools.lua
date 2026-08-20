local M = {}

M.eslint_config_files = {
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
}

local function buffer_dir(bufnr)
	local filename = vim.api.nvim_buf_get_name(bufnr or 0)
	return filename == "" and vim.fn.getcwd() or vim.fs.dirname(filename)
end

local function find_file(names, path)
	return vim.fs.find(names, { path = path, upward = true, type = "file" })[1]
end

function M.eslint_context(bufnr)
	local dirname = buffer_dir(bufnr)
	local config = find_file(M.eslint_config_files, dirname)
	local command = find_file("node_modules/.bin/eslint", dirname)

	if not config or not command or vim.fn.executable(command) ~= 1 then
		return nil
	end

	return {
		command = command,
		config = config,
		cwd = vim.fs.dirname(config),
	}
end

function M.eslint_root(bufnr)
	local context = M.eslint_context(bufnr)
	return context and context.cwd or nil
end

function M.eslint_args()
	return { "--fix-dry-run", "--format", "json", "--stdin", "--stdin-filename", "$FILENAME" }
end

function M.typescript_root(bufnr)
	local dirname = buffer_dir(bufnr)
	local project = find_file({ "tsconfig.json", "jsconfig.json", "package.json" }, dirname)
	if project then
		return vim.fs.dirname(project)
	end

	local git = vim.fs.find(".git", { path = dirname, upward = true, type = "directory" })[1]
	return git and vim.fs.dirname(git) or nil
end

function M.composer_include_paths(root)
	if not root then
		return {}
	end

	local git = vim.fs.find(".git", { path = root, upward = true, type = "directory" })[1]
	local workspace_root = git and vim.fs.dirname(git) or root
	local paths = { workspace_root }
	local seen = { [workspace_root] = true }
	local function add_path(value, base)
		if type(value) ~= "string" then
			return
		end

		local path = vim.fs.normalize(value:sub(1, 1) == "/" and value or vim.fs.joinpath(base or workspace_root, value))
		if vim.fn.isdirectory(path) == 1 then
			if not seen[path] then
				seen[path] = true
				table.insert(paths, path)
			end
		elseif vim.fn.filereadable(path) == 1 then
			local directory = vim.fs.dirname(path)
			if not seen[directory] then
				seen[directory] = true
				table.insert(paths, directory)
			end
		end
	end

	local composer_files = { vim.fs.joinpath(workspace_root, "composer.json") }
	for _, pattern in ipairs({ "*/composer.json", "*/*/composer.json" }) do
		vim.list_extend(composer_files, vim.fn.globpath(workspace_root, pattern, false, true))
	end
	for _, composer_path in ipairs(composer_files) do
		if not composer_path:find("/vendor/", 1, true) and not composer_path:find("/node_modules/", 1, true) then
			local composer_root = vim.fs.dirname(composer_path)
			add_path(composer_root)
			local ok, composer = pcall(vim.json.decode, table.concat(vim.fn.readfile(composer_path), "\n"))
			if ok and type(composer) == "table" and type(composer.autoload) == "table" then
				local autoload = composer.autoload
				for _, section in ipairs({ "psr-0", "psr-4" }) do
					for _, value in pairs(autoload[section] or {}) do
						add_path(vim.fs.joinpath(composer_root, value))
					end
				end
				for _, section in ipairs({ "classmap", "files" }) do
					for _, value in ipairs(autoload[section] or {}) do
						add_path(vim.fs.joinpath(composer_root, value))
					end
				end
			end
		end
	end

	return paths
end

function M.php_project_root(bufnr)
	local dirname = buffer_dir(bufnr)
	local composer = find_file("composer.json", dirname)
	if composer then
		return vim.fs.dirname(composer)
	end

	local git = vim.fs.find(".git", { path = dirname, upward = true, type = "directory" })[1]
	return git and vim.fs.dirname(git) or nil
end

function M.php_cs_fixer_context(bufnr)
	local root = M.php_project_root(bufnr)
	if not root then
		return nil
	end

	local project_command = vim.fs.joinpath(root, "vendor", "bin", "php-cs-fixer")
	if vim.fn.executable(project_command) == 1 then
		return { command = project_command, cwd = root }
	end

	local mason_command = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", "php-cs-fixer")
	if vim.fn.executable(mason_command) == 1 then
		return { command = mason_command, cwd = root }
	end

	return nil
end

return M