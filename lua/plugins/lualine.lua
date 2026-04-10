return {
  'nanozuki/tabby.nvim',
  event = 'VimEnter', -- 啟動時載入
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    local theme = {
      fill = 'TabLineFill',
      head = 'TabLine',
      current_tab = 'TabLineSel',
      tab = 'TabLine',
      win = 'TabLine',
      tail = 'TabLine',
    }

    require('tabby.tabline').set(function(line)
      return {
        {
          { '  ', hl = theme.head },
          line.sep('', theme.head, theme.fill),
        },
        line.tabs().foreach(function(tab)
          local hl = tab.is_current() and theme.current_tab or theme.tab
          -- 核心邏輯：優先讀取我們自訂的變數 'tab_title'，若無則顯示預設名稱
          local success, custom_name = pcall(vim.api.nvim_tabpage_get_var, tab.id, 'tab_title')
          local name = success and custom_name or tab.name()

          return {
            line.sep('', hl, theme.fill),
            tab.is_current() and '' or '󰆣',
            tab.number(),
            name,
            tab.close_btn('󰅖'),
            line.sep('', hl, theme.fill),
          }
        end),
        line.spacer(),
        line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
          return {
            line.sep('', theme.win, theme.fill),
            win.is_current() and '' or '',
            win.buf_name(),
            line.sep('', theme.win, theme.fill),
          }
        end),
        {
          line.sep('', theme.tail, theme.fill),
          { '  ', hl = theme.tail },
        },
        hl = theme.fill,
      }
    end)

    -- 建立自訂指令來固定 Tab 名稱
    -- 使用方式: :TabRename 專案A
    vim.api.nvim_create_user_command('TabRename', function(opts)
      vim.api.nvim_tabpage_set_var(0, 'tab_title', opts.args)
      vim.cmd('redrawtabline')
    end, { nargs = 1 })
  end,
}
