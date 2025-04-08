require("nvchad.mappings")

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<leader>tc", ":tabclose<CR>", { noremap = true, silent = true })
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
map(
    "n",
    "<leader>tt",
    ":lua require('base46').toggle_transparency()<CR>",
    { noremap = true, silent = true, desc = "Toggle Background Transparency" }
)

-- add quick question to soa
map("n", "<leader>zq", function()
    -- 1. Get user input
    vim.ui.input({ prompt = "Question: " }, function(user_input)
        if not user_input or user_input == "" then
            vim.notify("No input provided.", vim.log.levels.WARN)
            return
        end

        -- 2. Get current file path
        local current_path = vim.api.nvim_buf_get_name(0)
        if current_path == "" then
            vim.notify("Current buffer has no file path.", vim.log.levels.ERROR)
            return
        end

        -- 3. Run the command
        local cmd = { "soa", "a", "q", "-f", current_path, user_input }
        local output = vim.fn.system(cmd)

        if vim.v.shell_error ~= 0 then
            vim.notify("Command failed: " .. output, vim.log.levels.ERROR)
            return
        end

        -- 4. Trim output and open resulting file
        local result_path = vim.fn.trim(output)
        if vim.fn.filereadable(result_path) == 1 then
            vim.cmd.edit(result_path)
        else
            vim.notify(
                "Resulting file doesn't exist: " .. result_path,
                vim.log.levels.ERROR
            )
        end
    end)
end, { desc = "Run mycommand with input and open output" })
