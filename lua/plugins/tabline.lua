return {
  'nanozuki/tabby.nvim',
  event = 'VimEnter',
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
          { ' NVIM ', hl = theme.head },
          '|',
        },
        line.tabs().foreach(function(tab)
          local hl = tab.is_current() and theme.current_tab or theme.tab
          
          -- 核心邏輯：優先讀取自訂變數 'tab_title'
          local success, custom_name = pcall(vim.api.nvim_tabpage_get_var, tab.id, 'tab_title')
          local name = success and custom_name or tab.name()

          -- 使用簡單的 [ ] 包裹目前的標籤
          local prefix = tab.is_current() and '[' or ' '
          local suffix = tab.is_current() and ']' or ' '

          return {
            prefix,
            tab.number(),
            name,
            suffix,
            hl = hl,
            margin = ' ',
          }
        end),
        line.spacer(),
        -- 右側顯示當前分頁內的視窗清單 (選用，若不需要可刪除這整段)
        line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
          local hl = win.is_current() and theme.current_tab or theme.win
          return {
            ' (',
            win.buf_name(),
            ') ',
            hl = hl,
          }
        end),
        {
          '|',
          { ' TAB ', hl = theme.tail },
        },
        hl = theme.fill,
      }
    end)

    -- 指令保持不變： :TabRename 你的名稱
    vim.api.nvim_create_user_command('TabRename', function(opts)
      vim.api.nvim_tabpage_set_var(0, 'tab_title', opts.args)
      vim.cmd('redrawtabline')
    end, { nargs = 1 })
  end,
}
