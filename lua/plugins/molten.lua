return {
  "benlubas/molten-nvim",
  version = "^1.0.0",
  build = ":UpdateRemotePlugins",
  -- jupytext 會把 .ipynb 轉成 filetype=python；markdown 也支援
  ft = { "python", "markdown" },
  init = function()
    -- 指向專用 venv 的 python（內含 pynvim），避免動到系統 Python
    vim.g.python3_host_prog = vim.fn.expand("~/.venvs/neovim/bin/python")

    -- tmux 終端無法 inline 顯示圖片 → 關掉圖片需求（文字/表格/錯誤照常顯示）
    vim.g.molten_image_provider = "none"

    -- 輸出以虛擬文字顯示在 cell 下方（不另開浮動視窗，tmux 友善）
    vim.g.molten_virt_text_output = true
    vim.g.molten_virt_lines_off_by_1 = true
    vim.g.molten_auto_open_output = true
    vim.g.molten_wrap_output = true
    vim.g.molten_output_win_max_height = 20
  end,
  keys = {
    { "<leader>mi", "<cmd>MoltenInit<cr>", desc = "Molten: 啟動 kernel" },
    { "<leader>mo", "<cmd>MoltenEvaluateOperator<cr>", desc = "Molten: 執行 (operator)" },
    { "<leader>ml", "<cmd>MoltenEvaluateLine<cr>", desc = "Molten: 執行當前行" },
    { "<leader>mr", "<cmd>MoltenReevaluateCell<cr>", desc = "Molten: 重跑當前 cell" },
    { "<leader>mr", ":<C-u>MoltenEvaluateVisual<cr>gv", mode = "v", desc = "Molten: 執行選取" },
    { "<leader>ms", "<cmd>MoltenShowOutput<cr>", desc = "Molten: 顯示輸出" },
    { "<leader>mh", "<cmd>MoltenHideOutput<cr>", desc = "Molten: 隱藏輸出" },
    { "<leader>md", "<cmd>MoltenDelete<cr>", desc = "Molten: 刪除此 cell 輸出" },
  },
}
