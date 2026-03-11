return {
  -- 強大且直觀的全域取代
  {
    "MagicDuck/grug-far.nvim",
    config = function()
      require('grug-far').setup({})
      -- 快捷鍵：按下 <leader>sr 開啟全域取代視窗
      vim.keymap.set('n', '<leader>sr', "<cmd>GrugFar<cr>", { desc = "全域搜尋與取代" })
    end
  },
  -- 視窗佈局管理 (穩定 UI)
  {
    "folke/edgy.nvim",
    event = "VeryLazy",
    opts = {
      left = {
        { ft = "neo-tree", title = "Neo-Tree", size = { width = 30 } },
      },
    }
  }
}
