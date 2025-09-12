local M = {}

local deploy_configs = {
    web_dev = {
        name = "前端主檔",
        frontend_path = "D:\\project\\SAGWebVue\\MainPlatform",
        backend_path = "D:\\project\\SAGCore\\SAGCoreMIS",
        entry = "D:\\project\\SAGWebVue\\MainPlatform",
        runner = "run",
    },
    web_dev1 = {
        name = "Clone 1",
        frontend_path = "D:\\project\\SAGWebVue1\\MainPlatform",
        backend_path = "D:\\project\\SAGCore1\\SAGCoreMIS",
        entry = "D:\\project\\SAGWebVue1\\MainPlatform",
        runner = "run 1",
    },
    web_dev2 = {
        name = "Clone 2",
        frontend_path = "D:\\project\\SAGWebVue2\\MainPlatform",
        backend_path = "D:\\project\\SAGCore2\\SAGCoreMIS",
        entry = "D:\\project\\SAGWebVue2\\MainPlatform",
        runner = "run 2",
    },
    web_dev3 = {
        name = "Clone 3",
        frontend_path = "D:\\project\\SAGWebVue3\\MainPlatform",
        backend_path = "D:\\project\\SAGCore3\\SAGCoreMIS",
        entry = "D:\\project\\SAGWebVue3\\MainPlatform",
        runner = "run 3",
    },
    apsv2 = {
        name = "Apsv2",
        frontend_path = "D:\\project\\APSv2\\frontend",
        backend_path = "D:\\project\\APSv2",
        entry = "D:\\project\\APSv2",
        runner = "run 9",
    },
    cli2 = {
        name = "Cli2",
        path = "D:\\project\\RustTool\\cli2",
        entry = "src\\main.rs",
    },
}

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
    local job_id_2 = vim.b.terminal_job_id
    vim.cmd("Label " .. config.runner)
    
    vim.cmd("vsplit")
    vim.cmd("wincmd l")
    vim.cmd("terminal")
    local job_id_3 = vim.b.terminal_job_id
    vim.cmd("Label " .. config.runner)
    
    vim.fn.chansend(job_id_1, "D: && cd " .. config.frontend_path .. "\r\n")
    vim.fn.chansend(job_id_1, config.runner .. "\r\n")
    vim.fn.chansend(job_id_2, "D: && cd " .. config.entry .. "\r\n")
    vim.fn.chansend(job_id_2, "claude --dangerously-skip-permissions" .. "\r\n")
    vim.fn.chansend(job_id_3, "D: && cd " .. config.backend_path .. "\r\n")
    vim.fn.chansend(job_id_3, config.runner .. "\r\n")
end

function M.deploy_sub(env)
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

    vim.fn.chansend(job_id_1, "D: && cd " .. config.frontend_path .. "\r\n")
    vim.fn.chansend(job_id_1, config.runner .. "\r\n")
    vim.fn.chansend(job_id_2, "D: && cd " .. config.entry .. "\r\n")
    vim.fn.chansend(job_id_2, "claude --dangerously-skip-permissions" .. "\r\n")
    vim.fn.chansend(job_id_3, "D: && cd " .. config.backend_path .. "\r\n")
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
