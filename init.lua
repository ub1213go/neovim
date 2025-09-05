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

-- 可選：設置快捷鍵
vim.keymap.set('n', '<leader>bh', '<cmd>DeleteHidden<CR>', { desc = 'Delete hidden buffers' })

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





