-- return { 
--   "catppuccin/nvim",
--   name = "catppuccin",
--   priority = 1000,
--   config = function()
--     vim.cmd.colorscheme "catppuccin"
--   end
-- }
return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "frappe", -- 你喜歡的模式
      term_colors = true,
      -- 重點：在這裡手動把「暗藍色」換成「亮青色」或「亮藍色」
      color_overrides = {
        frappe = {
          blue = "#89b4fa",   -- 調亮原本的藍色
          sky = "#91d7e3",    -- 使用更亮的青空色
          rosewater = "#f5e0dc",
        },
      },
      highlight_overrides = {
        frappe = function(cp)
          return {
            -- 讓關鍵字加粗，增加辨識度
            Comment = { fg = cp.overlay1, style = { "italic" } },
            ["@keyword"] = { fg = cp.mauve, style = { "bold" } }, 
            ["@type"] = { fg = cp.yellow, style = { "bold" } },
            -- 解決你覺得「文字黑」的問題：強制提升所有標識符的亮度
            Identifier = { fg = cp.lavender },
          }
        end,
      },
    })
    vim.cmd.colorscheme("catppuccin")
  end,
}
