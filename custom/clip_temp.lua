local M = {}
local config_path = vim.fn.stdpath("config")
local commands = {
    run = {
        exe = config_path .. "\\custom\\cli2.exe",
        args = "-t C:\\project\\SAGWebVue\\MainPlatform\\",
        description = "剪貼簿暫存程式 SAGWebVue"
    },
    run1 = {
        exe = config_path .. "\\custom\\cli2.exe",
        args = "-t C:\\project\\SAGWebVue1\\MainPlatform\\",
        description = "剪貼簿暫存程式 SAGWebVue1"
    },
    run2 = {
        exe = config_path .. "\\custom\\cli2.exe",
        args = "-t C:\\project\\SAGWebVue2\\MainPlatform\\",
        description = "剪貼簿暫存程式 SAGWebVue2"
    },
    run3 = {
        exe = config_path .. "\\custom\\cli2.exe",
        args = "-t C:\\project\\SAGWebVue3\\MainPlatform\\",
        description = "剪貼簿暫存程式 SAGWebVue3"
    },
    clipTo = {
        exe = config_path .. "\\custom\\cli2.exe",
        args = "-t",
        description = "剪貼簿暫存程式"
    },
}

function M.execute_command(cmd_key, file_name)
    local cmd = commands[cmd_key]
    if not cmd then
        vim.notify("未知指令: " .. cmd_key, vim.log.levels.ERROR)
        return
    end

    if not file_name or file_name == "" then
        file_name = "temp.md"
    end

    local command
    if cmd.args and cmd.args ~= "" then
        command = string.format('"%s" %s', cmd.exe, cmd.args .. file_name)
    else
        command = string.format('"%s"', cmd.exe)
    end

    vim.notify("執行: " .. cmd.description)

    vim.fn.jobstart(command, {
        on_exit = function(_, exit_code)
            if exit_code == 0 then
                vim.notify("指令執行完成", vim.log.levels.INFO)
            else
                vim.notify("指令執行失敗 (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
            end
        end
    })
end

function M.execute_clip_to(cmd_key, path, file_name)
    local cmd = commands[cmd_key]
    if not cmd then
        vim.notify("未知指令: " .. cmd_key, vim.log.levels.ERROR)
        return
    end

    if not file_name or file_name == "" then
        file_name = "temp.md"
    end

    -- 把參數拆成 list（重點在這裡！）
    local args = {}

    if cmd.args and cmd.args ~= "" then
        -- 假設 cmd.args = "-t"
        table.insert(args, cmd.args)
        table.insert(args, path .. "\\" .. file_name)
    end

    --vim.notify("執行指令: " .. vim.inspect({ cmd.exe, unpack(args) }))

    vim.fn.jobstart(
        vim.list_extend({ cmd.exe }, args),
        {
            --on_stdout = function(_, data) 
            --    if data then print("STDOUT:", table.concat(data, "\n")) end
            --end,
            on_stderr = function(_, data) 
                if data then print("STDERR:", table.concat(data, "\n")) end
            end,
            on_exit = function(_, exit_code)
                if exit_code == 0 then
                    vim.notify("指令執行完成", vim.log.levels.INFO)
                else
                    vim.notify("指令執行失敗 (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
                end
            end
        }
    )
end

return M
