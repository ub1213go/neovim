-- lua/plugins/fzf-lua.lua
return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local fzf = require("fzf-lua")
    fzf.setup({
      -- 採用 VS Code 風格的經典佈局，這對搜尋檔案最直觀
      winopts = {
        height = 0.85,
        width = 0.80,
        preview = {
          layout = "vertical", -- 垂直佈局在縮放畫面時更穩定
          vertical = "down:45%",
        },
      },
      files = {
        formatter = "path.filename_first", -- 檔名在前，路徑在後
      },
    })

    -- 綁定快捷鍵 (建議先用不同的 leader key 測試)
    vim.keymap.set("n", "<leader>pf", fzf.files, { desc = "Fzf 搜尋檔案" })
    vim.keymap.set("n", "<leader>ps", fzf.live_grep, { desc = "Fzf 全域搜尋" })
    vim.keymap.set("n", "<leader>pb", fzf.buffers, { desc = "Fzf 開啟中的暫存區" })
  end,
}
