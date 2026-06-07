return {
  "nvim-treesitter/nvim-treesitter",
  -- 明確釘在 master 分支：官方為 Nvim 0.11 維護的穩定分支（main 需 0.12 nightly）。
  -- 不釘的話 lazy 會抓到上游已改成預設的 main 分支而壞掉。
  branch = "master",
  build = ":TSUpdate",
  config = function()
    -- Windows 特定：設定編譯器優先順序
    require("nvim-treesitter.install").compilers = { "zig", "clang", "gcc" }

    local config = require("nvim-treesitter.configs")
    config.setup({
      -- 明確指定要安裝的語言（避免安裝不必要的 parser）
      ensure_installed = {
        "lua",
        "vim",
        "vimdoc",
        "javascript",
        "typescript",
        "python", -- 編輯 .ipynb（jupytext percent 格式）內容為 Python
        "rust",
        "markdown",
        "toml",
        "vue",
        "hurl",
        "json",
      },

      -- 啟用自動安裝（當打開對應文件類型時）
      auto_install = true,

      -- 語法高亮
      highlight = {
        enable = true,
        -- 如果遇到問題可以針對特定語言禁用
        -- disable = { "rust" },
      },

      -- 自動縮排
      indent = {
        enable = true,
        -- disable = { "python" },
      },

      -- 增量選擇（可選）
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<CR>",
          node_incremental = "<CR>",
          scope_incremental = "<S-CR>",
          node_decremental = "<BS>",
        },
      },
    })
  end,
}
