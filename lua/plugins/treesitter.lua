return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    -- Windows 特定：設定編譯器優先順序
    require('nvim-treesitter.install').compilers = { "zig", "clang", "gcc" } 

    local config = require("nvim-treesitter.configs")
    config.setup({
      -- 明確指定要安裝的語言（避免安裝不必要的 parser）
      ensure_installed = { 
        "lua", 
        "vim", 
        "vimdoc",
        "javascript",
        "typescript",
        "rust",
        "markdown",
        "toml",
        "vue",
      },
      
      -- 啟用自動安裝（當打開對應文件類型時）
      auto_install = true,
      
      -- 語法高亮
      highlight = { 
        enable = true,
        -- 如果遇到問題可以針對特定語言禁用
        -- disable = { "rust" },  -- 例如：禁用 rust 的高亮
      },
      
      -- 自動縮排
      indent = { 
        enable = true,
        -- 某些語言的縮排可能有問題，可以選擇性禁用
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
  end
}
