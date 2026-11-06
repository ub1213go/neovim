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
    -- 搜尋 Buffer 內容
    vim.keymap.set("n", "<leader>pl", fzf.lines, { desc = "Fzf 搜尋所有已開啟 Buffer 的內容" })
    vim.keymap.set("n", "<leader>p/", fzf.blines, { desc = "Fzf 搜尋當前 Buffer 內容 (模糊搜尋)" })
    vim.keymap.set("n", "<leader>pg", fzf.lgrep_curbuf, { desc = "Fzf 搜尋當前 Buffer 內容 (Regex live_grep)" })

    ---------------------------------------------------------------------------
    -- 【搜尋語法速查備忘】
    ---------------------------------------------------------------------------
    -- 1. 檔案與列表搜尋擴展語法 (用於 <leader>pf, <leader>pb, <leader>pl, <leader>p/)
    --    - 'wild        精確匹配子字串 (Exact match)
    --    - ^music       開頭必須為 music (Prefix exact)
    --    - .lua$        結尾必須為 .lua (Suffix exact)
    --    - !fire        排除包含 fire 的項目 (Inverse exact)
    --    - !^temp       排除以 temp 開頭的項目
    --    - !.bak$       排除以 .bak 結尾的項目
    --    - 空格         代表 AND 條件 (例: `^lua/ 'fzf !spec$` => 在 lua/ 目錄下、含 fzf、排除 spec 結尾)
    --    - |            代表 OR 條件 (例: `main | test`)
    --
    -- 2. 全域文字內容正則搜尋 (用於 <leader>ps, <leader>pg)
    --    底層由 ripgrep 驅動，原生支援 Rust Regex：
    --    - foo.*bar     匹配 foo 與 bar 之間有任意字元
    --    - \bword\b     單字邊界精確匹配 (避免搜到 subword)
    --    - (fn|def)\s+  分組與多選 (例如比對函式關鍵字)
    --    - [0-9]+ 或 \d 數字比對
    --    - 結合檔案過濾: 輸入 `pattern -- *.lua` 或 `pattern -- -g !vendor` (可限定副檔名或排除路徑)
    ---------------------------------------------------------------------------
  end,
}
