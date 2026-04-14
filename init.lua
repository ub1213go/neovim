-- 修改「當前分頁」的名稱
vim.api.nvim_create_user_command('TabRename', function(opts)
    -- 將名稱儲存在 Tab 的變數中
    vim.api.nvim_tabpage_set_var(0, 'tab_title', opts.args)
    -- 通知介面更新 (某些插件需要)
    vim.cmd('redrawtabline')
end, { nargs = 1 })

-- 設定 <leader>cp 複製當前檔案的絕對路徑 (Copy Path)
vim.keymap.set('n', '<leader>cp', function()
  local path = vim.fn.expand('%:p') -- 取得絕對路徑
  vim.fn.setreg('+', path)          -- 寫入系統剪貼簿寄存器 (+)
  vim.notify('已複製絕對路徑: ' .. path) -- 顯示通知（選配）
end, { desc = 'Copy current file absolute path' })

local config_path = vim.fn.stdpath("config")

-- 專案環境部屬
local custom_project_setup = config_path .. "\\custom\\project_setup.lua"
if vim.fn.filereadable(custom_project_setup) == 1 then
    local custom = dofile(custom_project_setup)

    vim.api.nvim_create_user_command('SetupProject', function()
        custom.deploy('web_dev')
        custom.deploy_editor('web_dev')
        custom.deploy_doc()
        --custom.deploy_sub('web_dev1')
        --custom.deploy('web_dev2')
        --custom.deploy_sub('web_dev3')
        --custom.deploy('apsv2')
        --custom.deploy_simple('cli2')
    end, { desc = "部屬開發專案" })

    vim.api.nvim_create_user_command('SetupProject1', function()
        custom.deploy('web_dev1')
        custom.deploy_editor('web_dev1')
        custom.deploy_doc()
    end, { desc = "部屬開發專案1" })

    vim.api.nvim_create_user_command('SetupProject2', function()
        custom.deploy('web_dev2')
        custom.deploy_editor('web_dev2')
        custom.deploy_doc()
    end, { desc = "部屬開發專案2" })

    vim.api.nvim_create_user_command('SetupProject3', function()
        custom.deploy('web_dev3')
        custom.deploy_editor('web_dev3')
        custom.deploy_doc()
    end, { desc = "部屬開發專案3" })

    vim.api.nvim_create_user_command('SetupProjectYew', function()
        custom.deploy_yew('yew')
    end, { desc = "部屬開發專案後台" })
end

-- 建立一個名為 "Title" 的指令
vim.api.nvim_create_user_command('Title', function(opts)
    -- 獲取使用者輸入的參數 (xxxxx)
    local new_title = opts.args
    
    -- 如果使用者有輸入內容才進行設定
    if new_title ~= "" then
        vim.opt.title = true
        vim.opt.titlestring = new_title
        print("標題已設定為: " .. new_title)
    else
        print("請輸入標題內容，例如: :Title MyProject")
    end
end, {
    nargs = 1, -- 設定只需要一個參數
    desc = "快速設定 Neovim 視窗標題",
})

-- 剪貼簿暫存函式
local custom_clip_temp = config_path .. "\\custom\\clip_temp.lua"

if vim.fn.filereadable(custom_clip_temp) == 1 then
    local custom = dofile(custom_clip_temp)

    vim.api.nvim_create_user_command('Run', function(opts)
        custom.execute_command('run', opts.args)
    end, { desc = "主檔位置建立剪貼簿暫存", nargs = '?' })

    vim.api.nvim_create_user_command('Run1', function(opts)
        custom.execute_command('run1', opts.args)
    end, { desc = "Clone 1 位置建立剪貼簿暫存", nargs = '?' })

    vim.api.nvim_create_user_command('Run2', function(opts)
        custom.execute_command('run2', opts.args)
    end, { desc = "Clone 2 位置建立剪貼簿暫存", nargs = '?' })

    vim.api.nvim_create_user_command('Run3', function(opts)
        custom.execute_command('run3', opts.args)
    end, { desc = "Clone 3 位置建立剪貼簿暫存", nargs = '?' })

    vim.api.nvim_create_user_command("Cpt", function(opts)
        -- 將 opts.args 分割成 {path, file_name}
        local args = vim.split(opts.args, "%s+")

        -- 驗證 1 或 2 個參數
        if #args < 1 or #args > 2 then
            vim.notify("Cpt 必須提供 1 或 2 個參數：path [file_name]", vim.log.levels.ERROR)
            return
        end

        local path = args[0] ~= nil and args[1] or args[1]  -- 實際上 args[1] 就是第一個
        local file_name = args[2]                          -- 可能不存在

        -- 呼叫你的原本 function
        custom.execute_clip_to("clipTo", path, file_name)
    end, {
        desc = "指定位置建立剪貼簿暫存",
        nargs = "*",
    })
end

-- 全域函式，顯示 buffer 的 label
function _G.MyWinbar()
  local ok, label = pcall(vim.api.nvim_buf_get_var, 0, "label")
  if ok and label ~= "" then
    return "[" .. label .. "]"
  else
    return ""
  end
end

-- 設定 winbar 呼叫函式
vim.o.winbar = "%=%{v:lua.MyWinbar()}"

-- 建立 :Label 指令，幫 buffer 加 label
vim.api.nvim_create_user_command("Label", function(opts)
  vim.api.nvim_buf_set_var(0, "label", opts.args)
end, { nargs = 1 })

vim.api.nvim_create_user_command("CopyLabel", function()
  local ok, label = pcall(vim.api.nvim_buf_get_var, 0, "label")
  if ok and label ~= "" then
    -- 將標籤複製到系統剪貼簿 (通常是 '+')
    vim.fn.setreg('+', label)
    vim.notify("當前緩衝區標籤已複製到剪貼簿: " .. label, vim.log.levels.INFO)
  else
    vim.notify("當前緩衝區沒有設定標籤，無法複製。", vim.log.levels.INFO)
  end
end, {})

vim.api.nvim_create_user_command("CdVimrc", function()
      vim.cmd("Neotree " .. vim.fn.stdpath("config"))
end, { desc = "cd to Neovim config Neotree directory" })

-- CopyTab 指令，複製當前分頁的自訂名稱
vim.api.nvim_create_user_command("CopyTab", function()
    -- 嘗試從當前分頁 (0) 取得 'tab_title' 變數
    local success, title = pcall(vim.api.nvim_tabpage_get_var, 0, 'tab_title')
    
    if success and title ~= "" then
        -- 複製到系統剪貼簿
        vim.fn.setreg('+', title)
        vim.notify("分頁名稱已複製: " .. title, vim.log.levels.INFO)
    else
        -- 如果沒有自訂名稱，則取得預設的分頁名稱 (通常是檔案名或路徑)
        -- 這裡調用 tabby 的邏輯或內建方法
        local default_name = vim.fn.gettabvar(0, 'tab_title') -- 再次確認
        if default_name == "" or not success then
             -- 如果連變數都沒有，就抓取目前視窗的檔案名作為備案
             default_name = vim.fn.expand('%:t') 
        end
        vim.fn.setreg('+', default_name)
        vim.notify("複製預設分頁名稱: " .. default_name, vim.log.levels.INFO)
    end
end, { desc = "複製當前分頁的自訂標題" })

-- CopyCur 指令，複製當前 Buffer 的絕對路徑
vim.api.nvim_create_user_command('CopyCur', function()
    local path = vim.fn.expand('%:p') -- 取得絕對路徑
    if path ~= "" then
        vim.fn.setreg('+', path)
        vim.notify("已複製 Buffer 路徑: " .. path, vim.log.levels.INFO)
    else
        vim.notify("當前為空 Buffer，無路徑可複製", vim.log.levels.WARN)
    end
end, { desc = 'Copy current buffer absolute path' })

-- CopyHistory 指令，複製最後幾條訊息紀錄 (包含錯誤訊息)
vim.api.nvim_create_user_command('CopyHistory', function(opts)
    -- 取得所有訊息紀錄
    local messages = vim.fn.execute('messages')
    local lines = vim.split(messages, '\n')
    
    -- 如果有指定參數 (如 :CopyHistory 5)，則抓取最後 N 行；否則預設抓 10 行
    local count = tonumber(opts.args) or 10
    local start_idx = math.max(1, #lines - count + 1)
    local result = table.concat({unpack(lines, start_idx)}, '\n')

    if result ~= "" then
        vim.fn.setreg('+', result)
        vim.notify("已複製最後 " .. count .. " 條訊息紀錄", vim.log.levels.INFO)
    else
        vim.notify("訊息紀錄為空", vim.log.levels.WARN)
    end
end, { 
    nargs = '?', 
    desc = 'Copy last N lines of message history (errors, etc.)' 
})

-- 複製檔案路徑與行號範圍
vim.api.nvim_create_user_command('Cur', function()
  local filepath = vim.fn.expand('%:p')
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  local result = string.format("%s#%d-%d", filepath, start_line, end_line)
  vim.fn.setreg('+', result)
  vim.notify("已複製: " .. result, vim.log.levels.INFO)
end, { range = true, desc = "複製檔案路徑與選取的行號範圍" })

-- 刪除 hidden buffers 的函數
local function delete_hidden_buffers(force)
  local deleted = 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.fn.bufwinnr(buf) == -1 then
      -- 檢查是否有未保存的更改
      local modified = vim.api.nvim_buf_get_option(buf, 'modified')
      if force or not modified then
        pcall(vim.api.nvim_buf_delete, buf, { force = force })
        deleted = deleted + 1
      end
    end
  end
  print('Deleted ' .. deleted .. ' hidden buffer(s)')
end

-- 創建自定義指令
vim.api.nvim_create_user_command('DeleteHidden', function(opts)
  delete_hidden_buffers(opts.bang)
end, {
  bang = true,  -- 支援 ! 強制刪除
  desc = 'Delete hidden buffers'
})


-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("vim-options")
-- Setup lazy.nvim
require("lazy").setup("plugins")


