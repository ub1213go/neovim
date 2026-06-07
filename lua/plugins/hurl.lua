return {
  "jellydn/hurl.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  ft = "hurl",
  opts = {
    -- 這裡可以放置你的自定義設定
    debug = false,
    show_headers = true,
    floating = true, -- 使用浮動視窗顯示結果
    formatters = {
      json = { 'jq' }, -- 如果你有安裝 jq，結果會自動格式化
      html = { 'prettier', '--parser', 'html' },
    },
  },
  keys = {
    -- 設定快捷鍵 (可以依據喜好修改)
    { "<leader>hr", "<cmd>HurlRunner<cr>", desc = "Run Hurl" },
    { "<leader>hA", "<cmd>HurlRunnerAt<cr>", desc = "Run Api at current line" },
    { "<leader>te", "<cmd>HurlRunnerToEntry<cr>", desc = "Run Api to entry" },
    { "<leader>tm", "<cmd>HurlToggleMode<cr>", desc = "Toggle Hurl Mode" },
    -- 逐則確認：在 split 視窗列出每個 entry 的 request/response
    { "<leader>hv", "<cmd>HurlVeryVerbose<cr>", desc = "Run Hurl (very verbose, 全部 entry)" },
    { "<leader>hV", "<cmd>HurlVerbose<cr>", desc = "Run Hurl (verbose 摘要)" },
    { "<leader>hj", "<cmd>HurlJson<cr>", desc = "Run Hurl (JSON 結構化結果)" },
    -- 視覺模式下執行選中的請求
    { "<leader>hr", ":HurlRunner<cr>", mode = "v", desc = "Run Hurl Selection" },
  },
}
