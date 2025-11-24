local M = {}

function M.copy_file_lines()
  -- 獲取當前文件的完整路徑
  local filepath = vim.fn.expand('%:p')
  
  -- 獲取選取範圍的起始和結束行號
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  
  -- 格式化輸出
  local result = string.format("%s#%d-%d", filepath, start_line, end_line)
  
  -- 複製到系統剪貼板
  vim.fn.setreg('+', result)
  
  -- 顯示提示訊息
  print("已複製: " .. result)
end

return M
