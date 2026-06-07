return {
  "nvim-treesitter/nvim-treesitter",
  -- 明確鎖在 main 分支（官方重寫版，需 nvim 0.11+）
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup()

    -- Windows 特定：編譯器優先順序。main 分支結構不同，用 pcall 保險。
    pcall(function()
      require("nvim-treesitter.install").compilers = { "zig", "clang", "gcc" }
    end)

    -- 要安裝的 parser（取代舊版 ensure_installed）
    local ensure = {
      "lua",
      "vim",
      "vimdoc",
      "javascript",
      "typescript",
      "rust",
      "markdown",
      "toml",
      "vue",
      "hurl",
      "json",
    }

    -- 只安裝尚未安裝的，避免每次啟動都重跑
    local installed = require("nvim-treesitter").get_installed()
    local missing = vim.tbl_filter(function(lang)
      return not vim.tbl_contains(installed, lang)
    end, ensure)
    if #missing > 0 then
      require("nvim-treesitter").install(missing)
    end

    -- 開檔時啟用高亮 + 縮排（取代舊版 highlight.enable / indent.enable）。
    -- 直接 pcall start：parser 存在（內建或已安裝）就啟用，否則安靜略過。
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        local buf = args.buf
        if pcall(vim.treesitter.start, buf) then
          -- 縮排（main 分支為實驗性功能）
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })

    -- 註：舊版的 incremental_selection 已不在 main 分支核心內，
    -- 如需此功能可改用 nvim-treesitter-textobjects 或自訂 keymap。
  end,
}
