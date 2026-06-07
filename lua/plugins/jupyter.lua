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
