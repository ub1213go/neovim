return {
  "nvim-lualine/lualine.nvim",
  config = function()
    require('lualine').setup({
      options = {
        theme = 'dracula'
      },
      sections = {
        lualine_c = {
          {
            'filename',
            path = 2, -- 0: 只顯示檔名, 1: 相對路徑, 2: 絕對路徑
          }
        }
      }
    })
  end
}
