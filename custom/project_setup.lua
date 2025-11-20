local M = {}

local deploy_configs = {
    web_dev = {
        name = "前端主檔",
        frontend_path = "C:\\project\\SAGWebVue\\MainPlatform",
        backend_path = "C:\\project\\SAGCore\\SAGCoreMIS",
        entry = "C:\\project\\SAGWebVue\\MainPlatform",
        runner = "run",
    },
    web_dev1 = {
        name = "Clone 1",
        frontend_path = "C:\\project\\SAGWebVue1\\MainPlatform",
        backend_path = "C:\\project\\SAGCore1\\SAGCoreMIS",
        entry = "C:\\project\\SAGWebVue1\\MainPlatform",
        runner = "run 1",
    },
    web_dev2 = {
        name = "Clone 2",
        frontend_path = "C:\\project\\SAGWebVue2\\MainPlatform",
        backend_path = "C:\\project\\SAGCore2\\SAGCoreMIS",
        entry = "C:\\project\\SAGWebVue2\\MainPlatform",
        runner = "run 2",
    },
    web_dev3 = {
        name = "Clone 3",
        frontend_path = "C:\\project\\SAGWebVue3\\MainPlatform",
        backend_path = "C:\\project\\SAGCore3\\SAGCoreMIS",
        entry = "C:\\project\\SAGWebVue3\\MainPlatform",
        runner = "run 3",
    },
    cli2 = {
        name = "Cli2",
        path = "C:\\project\\RustTool\\cli2",
        entry = "src\\main.rs",
    },
}

function M.deploy_temp()
    print("開始建置 temp")

    vim.cmd("tab new")
    vim.cmd("Neotree C:\\project\\temp")
end

function M.deploy_editor(env)
    local config = deploy_configs[env]
    if not config then
        print("錯誤: 未知的環境 " .. env)
        return
    end

    print("開始建置 " .. config.name .. " 專案編輯...")

   vim.schedule(function()
        vim.cmd("tab new")
        vim.cmd("Label 前端 " .. config.runner)
        vim.cmd("Neotree " .. config.frontend_path)
        
        vim.schedule(function()
            vim.cmd("tab new")
            vim.cmd("Label 後端 " .. config.runner)
            vim.cmd("Neotree " .. config.backend_path)
        end)
    end)
end

function M.deploy(env)
    local config = deploy_configs[env]
    if not config then
        print("錯誤: 未知的環境 " .. env)
        return
    end

    print("開始建置 " .. config.name .. "...")

    vim.cmd("tab terminal")
    local job_id_1 = vim.b.terminal_job_id
    vim.cmd("Label " .. config.runner)
    
    vim.cmd("vsplit")
    vim.cmd("wincmd l")
    vim.cmd("terminal")
    local job_id_3 = vim.b.terminal_job_id
    vim.cmd("Label " .. config.runner)
    
    vim.fn.chansend(job_id_1, "cd " .. config.frontend_path .. "\r\n")
    vim.fn.chansend(job_id_1, config.runner .. "\r\n")
    vim.fn.chansend(job_id_3, "cd " .. config.backend_path .. "\r\n")
    vim.fn.chansend(job_id_3, config.runner .. "\r\n")
    
   vim.schedule(function()
        vim.cmd("tab terminal")
        local job_id_2 = vim.b.terminal_job_id
        vim.cmd("Label " .. config.runner)
        
        vim.fn.chansend(job_id_2, "cd " .. config.entry .. "\r\n")
        vim.fn.chansend(job_id_2, "claude --dangerously-skip-permissions" .. "\r\n")
    end)
end

function M.deploy_sub(env)
    -- 棄用
    local config = deploy_configs[env]
    if not config then
        print("錯誤: 未知的環境 " .. env)
        return
    end

    print("開始建置 " .. config.name .. "...")

    vim.cmd("1wincmd w")
    vim.cmd("split")
    vim.cmd("wincmd j")
    vim.cmd("terminal")
    local job_id_1 = vim.b.terminal_job_id
    vim.cmd("Label " .. config.runner)
    vim.cmd("wincmd k")

    vim.cmd("wincmd l")
    vim.cmd("split")
    vim.cmd("wincmd j")
    vim.cmd("terminal")
    local job_id_2 = vim.b.terminal_job_id
    vim.cmd("Label " .. config.runner)
    vim.cmd("wincmd k")

    vim.cmd("3wincmd l")
    vim.cmd("split")
    vim.cmd("wincmd j")
    vim.cmd("terminal")
    local job_id_3 = vim.b.terminal_job_id
    vim.cmd("Label " .. config.runner)

    vim.fn.chansend(job_id_1, "cd " .. config.frontend_path .. "\r\n")
    vim.fn.chansend(job_id_1, config.runner .. "\r\n")
    vim.fn.chansend(job_id_2, "cd " .. config.entry .. "\r\n")
    vim.fn.chansend(job_id_2, "claude --dangerously-skip-permissions" .. "\r\n")
    vim.fn.chansend(job_id_3, "cd " .. config.backend_path .. "\r\n")
    vim.fn.chansend(job_id_3, config.runner .. "\r\n")
end

function M.deploy_simple(env)
    local config = deploy_configs[env]
    if not config then
        print("錯誤: 未知的環境 " .. env)
        return
    end

    print("開始建置 " .. config.name .. "...")

    vim.cmd("tab new")
    local job_id_1 = vim.b.terminal_job_id
    vim.cmd("Neotree " .. config.path)
    vim.cmd("e " .. config.path .. "\\" .. config.entry)
end

return M
