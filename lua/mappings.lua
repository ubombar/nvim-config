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

        -- 3. Run the command
        local cmd = { "soa", "add", "question", "-f", current_path, user_input }
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
end, { desc = "Create a question note for soa" })

map("n", "<leader>zl", function()
    -- 2. Get current file path
    local current_path = vim.api.nvim_buf_get_name(0)

    -- 3. Run the command
    local cmd = { "soa", "sync", "literature" }
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
end, { desc = "Sync Zotero literature note" })

local function open_file_picker_in_floating_window(dir)
    -- Expand `~` to home directory
    dir = vim.fn.expand(dir)

    -- Get all files under the directory recursively
    local scan =
        vim.fn.systemlist("find " .. vim.fn.shellescape(dir) .. " -type f")

    if vim.v.shell_error ~= 0 or #scan == 0 then
        vim.notify("No files found in " .. dir, vim.log.levels.WARN)
        return
    end

    -- Create scratch buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, scan)

    -- Set buffer options
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].modifiable = false

    -- Window dimensions
    local width = math.floor(vim.o.columns * 0.6)
    local height = math.min(#scan, math.floor(vim.o.lines * 0.6))
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    -- Create floating window
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
    })

    -- Enter opens selected file
    vim.keymap.set("n", "<CR>", function()
        local path = vim.fn.getline(".")
        vim.api.nvim_win_close(win, true)
        vim.cmd.edit(path)
    end, { buffer = buf, nowait = true })

    vim.keymap.set("n", "<Esc>", function()
        vim.api.nvim_win_close(win, true)
    end, { buffer = buf, nowait = true })
end

map("n", "<leader>zz", function()
    open_file_picker_in_floating_window("~/SOA/questions")
end, { desc = "Show questions" })
