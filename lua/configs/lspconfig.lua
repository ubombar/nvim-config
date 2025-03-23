local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")

-- Set the Python path
local venv_path = os.getenv("VIRTUAL_ENV")
if not venv_path then
    -- Try to detect a venv in the current workspace
    local cwd = vim.fn.getcwd()
    local paths = { cwd .. "/.venv/bin/python", cwd .. "/venv/bin/python" }
    for _, p in ipairs(paths) do
        if vim.fn.filereadable(p) == 1 then
            venv_path = p
            break
        end
    end
end
--
-- local lspconfig = require "lspconfig"
-- list of all servers configured.
lspconfig.servers = {
    "lua_ls",
    "clangd",
    "gopls",
    -- "hls",
    -- "ols",
    "pyright",
}

-- -- list of servers configured with default config.
-- local default_servers = {
--     -- "ols",
--     -- Setup the python server with defaul values
--     "pyright",
-- }

-- lsps with default config
-- for _, lsp in ipairs(default_servers) do
--     lspconfig[lsp].setup({
--         on_attach = on_attach,
--         on_init = on_init,
--         capabilities = capabilities,
--     })
-- end

lspconfig.pyright.setup({
    settings = {
        python = {
            pythonPath = venv_path or "python", -- Fallback to system Python if no venv is found
        },
    },
})
lspconfig.clangd.setup({
    on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        on_attach(client, bufnr)
    end,
    on_init = on_init,
    capabilities = capabilities,
})
lspconfig.gopls.setup({
    on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
        on_attach(client, bufnr)
    end,
    on_init = on_init,
    capabilities = capabilities,
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gotmpl", "gowork" },
    root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
            },
            completeUnimported = true,
            usePlaceholders = true,
            staticcheck = true,
        },
    },
})
-- lspconfig.hls.setup({
--     on_attach = function(client, bufnr)
--         client.server_capabilities.documentFormattingProvider = false
--         client.server_capabilities.documentRangeFormattingProvider = false
--         on_attach(client, bufnr)
--     end,
--     --     on_init = on_init,
--     capabilities = capabilities,
-- })

lspconfig.lua_ls.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,

    settings = {
        Lua = {
            diagnostics = {
                enable = false, -- Disable all diagnostics from lua_ls
                globals = { "vim" },
            },
            workspace = {
                library = {
                    vim.fn.expand("$VIMRUNTIME/lua"),
                    vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
                    vim.fn.stdpath("data") .. "/lazy/ui/nvchad_types",
                    vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy",
                    "${3rd}/love2d/library",
                },
                maxPreload = 100000,
                preloadFileSize = 10000,
            },
        },
    },
})
