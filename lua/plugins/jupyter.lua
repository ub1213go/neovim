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
      -- 編輯格式用 percent：cell 以 `# %%` 分隔，副檔名隨 kernel 自動決定
      -- （Python notebook → 當成 .py 編輯，可享完整語法高亮）。
      -- 註：output_extension="auto" 解析出的 .py 不接受 "markdown"，
      --     若想用 markdown 風格，需改成 output_extension = "md"。
      style = "percent",
      output_extension = "auto",
      force_ft = nil,
    })
  end,
}
