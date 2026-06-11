return {
  "benlubas/molten-nvim",
  version = "^1.0.0",
  build = ":UpdateRemotePlugins",
  -- jupytext 會把 .ipynb 轉成 filetype=python；markdown 也支援
  ft = { "python", "markdown" },
  init = function()
    -- python3 host：指向含 pynvim 的 venv，避免動到系統 Python。
    -- 依序嘗試候選路徑，讓本機與 devlab container 共用同一份設定：
    --   本機         → ~/.venvs/neovim
    --   devlab 容器  → ~/.venvs/dev（Dockerfile §6 的 uv venv）
    for _, p in ipairs({
      "~/.venvs/neovim/bin/python",
      "~/.venvs/dev/bin/python",
    }) do
      local py = vim.fn.expand(p)
      if vim.fn.executable(py) == 1 then
        vim.g.python3_host_prog = py
        break
      end
    end

    -- tmux 終端無法 inline 顯示圖片 → 關掉圖片需求（文字/表格/錯誤照常顯示）
    vim.g.molten_image_provider = "none"

    -- 輸出以虛擬文字顯示在 cell 下方（不另開浮動視窗，tmux 友善）
    vim.g.molten_virt_text_output = true
    vim.g.molten_virt_lines_off_by_1 = true
    vim.g.molten_auto_open_output = true
    vim.g.molten_wrap_output = true
    vim.g.molten_output_win_max_height = 20
  end,
  -- 鍵位前綴用 <leader>j（Jupyter 助記）。
  -- 不可用 <leader>m：mssql.nvim 的 keymap_prefix 也是 <leader>m，會撞到
  -- ml(Cancel)/mr(Refresh)/md(NewDefault)；且 lazy 的 keys 是「全域」觸發、
  -- 不受 ft 限制，故在 SQL buffer 按 mssql 鍵會誤載 Molten 而報未初始化。
  --   2026-06-11: m → j，解 mssql.nvim 前綴衝突。
  keys = {
    { "<leader>ji", "<cmd>MoltenInit<cr>", desc = "Molten: 啟動 kernel" },
    { "<leader>jo", "<cmd>MoltenEvaluateOperator<cr>", desc = "Molten: 執行 (operator)" },
    { "<leader>jl", "<cmd>MoltenEvaluateLine<cr>", desc = "Molten: 執行當前行" },
    { "<leader>jr", "<cmd>MoltenReevaluateCell<cr>", desc = "Molten: 重跑當前 cell" },
    { "<leader>jr", ":<C-u>MoltenEvaluateVisual<cr>gv", mode = "v", desc = "Molten: 執行選取" },
    { "<leader>js", "<cmd>MoltenShowOutput<cr>", desc = "Molten: 顯示輸出" },
    { "<leader>jh", "<cmd>MoltenHideOutput<cr>", desc = "Molten: 隱藏輸出" },
    { "<leader>jd", "<cmd>MoltenDelete<cr>", desc = "Molten: 刪除此 cell 輸出" },
  },
}
