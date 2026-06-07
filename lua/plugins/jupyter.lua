-- Jupyter notebook（.ipynb）純編輯支援
-- 透過 jupytext.nvim：開啟 .ipynb 時自動轉成純文字編輯，存檔時轉回 .ipynb。
-- 僅編輯用途，不執行 cell、不需要 kernel。
--
-- 前置需求（外部）：pip install jupytext
return {
  "GCBallesteros/jupytext.nvim",
  -- .ipynb 需要在開檔當下就攔截轉換，故不延遲載入
  lazy = false,
  config = function()
    -- 確保找得到 jupytext 執行檔。jupytext 由 pip 裝在 ~/.local/bin，
    -- 但從 GUI/桌面捷徑、或沒 source ~/.profile 的終端啟動 nvim 時，
    -- 該目錄常不在 PATH 裡 → jupytext 指令失敗 → .ipynb 退回顯示原始 JSON。
    -- 本外掛無指定執行檔路徑的選項，故在此補進 PATH。
    if vim.fn.exepath("jupytext") == "" then
      local extra = vim.fn.expand("~/.local/bin")
      if vim.fn.isdirectory(extra) == 1 then
        vim.env.PATH = extra .. ":" .. vim.env.PATH
      end
    end

    require("jupytext").setup({
      -- 編輯格式用 percent：cell 以 `# %%` 分隔。
      -- output_extension 寫死 "py"（不要用 "auto"）：
      --   "auto" 會讓 jupytext 用 --to=auto:percent，需 notebook 帶 language_info
      --   metadata 才推得出副檔名；缺 metadata 的 .ipynb（手寫或某些工具產生）會
      --   報 "does not have a 'language_info' metadata" → 開檔失敗。
      --   2026-06-07: auto → py，因為缺 language_info 的 notebook 開不起來（jupytext exit=1）。
      --   註：寫死 "py" 代表把所有 notebook 當 Python 編輯；若要編非 Python notebook，
      --       需改成對應副檔名（如 R→"r"）或改回 "auto" 並確保來源檔有 kernelspec。
      style = "percent",
      output_extension = "py",
      force_ft = nil,
    })
  end,
}
