-- ~/.config/nvim/lua/plugins/dap.lua
-- 最小化配置，完全避免任何可能引用 tmux 的地方
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
    "nvim-neotest/nvim-nio",
  },
  config = function()
    -- 只進行最基本的設定，不配置任何 adapter
    local dap = require("dap")
    local dapui = require("dapui")

    -- 基本 UI 設定
    dapui.setup({
      icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
      layouts = {
        {
          elements = { "scopes", "breakpoints", "stacks", "watches" },
          size = 40,
          position = "left",
        },
        {
          elements = { "repl", "console" },
          size = 0.25,
          position = "bottom",
        },
      },
    })

    -- 虛擬文字設定
    require("nvim-dap-virtual-text").setup({
      enabled = true,
      enabled_commands = true,
    })

    -- UI 自動開關
    dap.listeners.after.event_initialized["dapui_config"] = dapui.open
    dap.listeners.before.event_terminated["dapui_config"] = dapui.close
    dap.listeners.before.event_exited["dapui_config"] = dapui.close

    -- 僅基本按鍵映射
    vim.keymap.set("n", "<leader>dt", dapui.toggle, { desc = "調試: 切換介面" })
    vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "調試: 切換中斷點" })
    vim.keymap.set("n", "<F5>", dap.continue, { desc = "調試: 繼續" })
    vim.keymap.set("n", "<F10>", dap.step_over, { desc = "調試: 單步跳過" })
    
    -- 顯示成功載入訊息
    vim.notify("DAP 基本配置已載入（無 adapter 配置）", vim.log.levels.INFO)
  end,
}
