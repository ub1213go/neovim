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





