-- ── # %% cell 工具 ──────────────────────────────────────────────
-- molten 本身不認 # %%，只記得「跑過的範圍」。所以：
--   MoltenReevaluateCell 只能重跑跑過的 cell，沒跑過／游標在 # %% 行上 → "Not in a cell"
-- 這裡自己切 # %% 範圍，再丟給 MoltenEvaluateRange，第一次跑、重跑都能用。
local function is_mark(l)
  return l:match("^# %%%%") ~= nil -- Lua pattern 的 %% = 字面 %，即比對 "# %%"
end

-- 回傳整份檔案每個 cell 的 { 起始行, 結束行 }（不含 # %% 標記行本身）
local function cell_ranges()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local ranges, start = {}, 1
  for i, l in ipairs(lines) do
    if is_mark(l) then
      if i - 1 >= start then table.insert(ranges, { start, i - 1 }) end
      start = i + 1
    end
  end
  if #lines >= start then table.insert(ranges, { start, #lines }) end
  return ranges
end

-- cell 裡有沒有真正的程式（全是空行或 # 註解就不送）
local function has_code(r)
  for _, l in ipairs(vim.api.nvim_buf_get_lines(0, r[1] - 1, r[2], false)) do
    if l:match("%S") and not l:match("^%s*#") then return true end
  end
  return false
end

-- 執行游標所在的 cell；游標在 # %% 行上時算它底下那格
local function run_current_cell()
  local cur = vim.fn.line(".")
  if is_mark(vim.fn.getline(cur)) then cur = cur + 1 end
  for _, r in ipairs(cell_ranges()) do
    if cur >= r[1] and cur <= r[2] then
      if has_code(r) then
        vim.fn.MoltenEvaluateRange(r[1], r[2])
      else
        vim.notify("Molten: 這個 # %% cell 沒有可執行的程式", vim.log.levels.WARN)
      end
      return
    end
  end
  vim.notify("Molten: 這個 # %% cell 沒有可執行的程式", vim.log.levels.WARN)
end

-- 從上到下逐格執行整份檔案（每格各自保留輸出；只有註解的格子跳過）
local function run_all_cells()
  local n = 0
  for _, r in ipairs(cell_ranges()) do
    if has_code(r) then
      vim.fn.MoltenEvaluateRange(r[1], r[2])
      n = n + 1
    end
  end
  vim.notify(("Molten: 已送出 %d 個 cell"):format(n), vim.log.levels.INFO)
end

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
    -- 2026-06-14: true → false。我們用 <leader>jc 自算 # %% 範圍餵 MoltenEvaluateRange,
    -- endln 已經停在「下一個 # %% 的前一行」;off_by_1 會再 +1 把輸出推過 markdown marker,
    -- 導致輸出顯示到 # %% [markdown] block 下方。自算範圍時不需要這個偏移。
    vim.g.molten_virt_lines_off_by_1 = false
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
    -- 2026-11-02: jr 原本是 MoltenReevaluateCell（只能重跑跑過的 cell，沒跑過或游標在 # %% 行
    -- 上就 "Not in a cell"），改成跟 jc 一樣自己算 # %% 範圍，第一次跑、重跑都能用。
    { "<leader>jr", run_current_cell, desc = "Molten: 執行游標所在 # %% cell" },
    { "<leader>jr", ":<C-u>MoltenEvaluateVisual<cr>gv", mode = "v", desc = "Molten: 執行選取" },
    { "<leader>jc", run_current_cell, desc = "Molten: 執行游標所在 # %% cell" },
    -- 2026-11-02: 原本是整檔當「一個 cell」跑（會把各格輸出清掉、合成一坨），
    -- 改成從上到下逐格執行，每格各自保留輸出。
    { "<leader>ja", run_all_cells, desc = "Molten: 逐格執行整個檔案" },
    -- 逐一重跑「已執行過」的每個 cell（各自保留各自輸出）
    { "<leader>jR", "<cmd>MoltenReevaluateAll<cr>", desc = "Molten: 重跑所有 cell" },
    { "<leader>js", "<cmd>MoltenShowOutput<cr>", desc = "Molten: 顯示輸出" },
    { "<leader>jh", "<cmd>MoltenHideOutput<cr>", desc = "Molten: 隱藏輸出" },
    -- 進輸出浮動視窗，可用 v/y 選取複製、q/<esc> 離開（虛擬文字本身選不到）
    -- noautocmd 必加：否則進視窗會觸發 autocmd 立刻關掉
    { "<leader>je", "<cmd>noautocmd MoltenEnterOutput<cr>", desc = "Molten: 進輸出視窗(可複製)" },
    { "<leader>jd", "<cmd>MoltenDelete<cr>", desc = "Molten: 刪除此 cell 輸出" },
    -- 中斷 / 重啟 kernel（Jupyter 沒有「暫停→繼續」，只有中斷或整個重來）
    -- jx：送 KeyboardInterrupt 停掉當前 cell（kernel 不死，變數保留）
    -- jX：殺掉 kernel 重開 + 清舊輸出（卡死、pyodbc blocking 中斷不掉時用）
    { "<leader>jx", "<cmd>MoltenInterrupt<cr>", desc = "Molten: 中斷執行(保留變數)" },
    { "<leader>jX", "<cmd>MoltenRestart!<cr>", desc = "Molten: 重啟 kernel + 清輸出" },
    -- jD：卸載當前 buffer 的 molten 並關掉它綁的 kernel（真正「關閉」，不是重開）
    { "<leader>jD", "<cmd>MoltenDeinit<cr>", desc = "Molten: 關閉 kernel(MoltenDeinit)" },
    -- jK：關閉「所有」kernel。molten 沒有原生一鍵全關，且 MoltenDeinit 只作用當前 buffer、
    -- 不能指定 kernel id；故掃過每個 buffer，用 MoltenRunningKernels(true) 判斷該 buffer
    -- 有無 kernel，有才 MoltenDeinit。用 nvim_buf_call 在不真正切窗下逐 buffer 執行
    -- （molten 內部讀 current buffer，buf_call 會把它暫設成目標 buffer）。
    {
      "<leader>jK",
      function()
        -- molten 未載入 / 未初始化時 MoltenRunningKernels 不存在或回 []，pcall 擋掉
        local ok, all = pcall(vim.fn.MoltenRunningKernels, false)
        if not ok or vim.tbl_isempty(all) then
          vim.notify("Molten: 目前沒有執行中的 kernel", vim.log.levels.INFO)
          return
        end
        local n = 0
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(buf) then
            vim.api.nvim_buf_call(buf, function()
              if not vim.tbl_isempty(vim.fn.MoltenRunningKernels(true)) then
                vim.cmd("MoltenDeinit")
                n = n + 1
              end
            end)
          end
        end
        vim.notify(("Molten: 已關閉 %d 個 buffer 的 kernel"):format(n), vim.log.levels.INFO)
      end,
      desc = "Molten: 關閉所有 kernel",
    },
  },
}
