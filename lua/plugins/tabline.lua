require('tabby.tabline').set(function(line)
  return {
    line.tabs().foreach(function(tab)
      local name = tab.name() -- 取得 Tab 名稱
      local hl = tab.is_current() and 'TabLineSel' or 'TabLine'
      return {
        line.sep(' ', hl, hl),
        tab.number(),
        name, -- 這裡會顯示你設定的固定名稱
        line.sep(' ', hl, hl),
      }
    end),
  }
end)
