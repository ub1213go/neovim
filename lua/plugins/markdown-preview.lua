-- 2026-10-18: 加自訂 browserfunc，因為 nvim 啟動時就把 DISPLAY 凍住了 ——
--   ~/.bashrc 會先丟掉還沒驗過的 DISPLAY（見 _refresh_tmux_env），nvim 若開得比判活早、
--   或開的時候 VcXsrv 還沒開，就永遠拿不到 DISPLAY，:MarkdownPreview 安靜地不跳視窗。
--   改成「按預覽那一刻」才向 tmux 問目前的號碼、判活、再開瀏覽器。

-- 候選順序：tmux session → tmux global → bashrc 收的口袋號碼 → nvim 自己的
local function display_candidates()
  local seen, out = {}, {}
  local function add(v)
    if v and v ~= "" and not seen[v] then
      seen[v] = true
      table.insert(out, v)
    end
  end
  for _, args in ipairs({
    { "tmux", "showenv", "DISPLAY" },
    { "tmux", "showenv", "-g", "DISPLAY" },
    { "tmux", "showenv", "-g", "_DISPLAY_STASH" },
  }) do
    local r = vim.system(args, { text = true }):wait()
    if r.code == 0 then
      add((r.stdout or ""):match("^[%w_]+=(%S+)"))
    end
  end
  add(vim.env.DISPLAY)
  return out
end

-- 逐個判活（死的 DISPLAY 會吃滿逾時，所以用非同步，不卡編輯器）
local function open_with_live_display(url, cands, i)
  local d = cands[i]
  if not d then
    vim.notify(
      "Markdown 預覽：找不到可用的 X 畫面，請先開 VcXsrv 再預覽一次。\n網址：" .. url,
      vim.log.levels.WARN
    )
    return
  end
  vim.system({ "timeout", "3", "xdpyinfo" }, { env = { DISPLAY = d } }, function(r)
    vim.schedule(function()
      if r.code ~= 0 then
        return open_with_live_display(url, cands, i + 1)
      end
      vim.env.DISPLAY = d
      vim.fn.jobstart({ "xdg-open", url }, { env = { DISPLAY = d }, detach = true })
    end)
  end)
end

function _G.MkdpOpenBrowser(url)
  open_with_live_display(url, display_candidates(), 1)
end

return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = "cd app && npm install",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
    -- server.js 用 nvim.call(名字) 呼叫，要給 Vimscript 函式名，所以包一層
    vim.cmd([[
      function! MkdpOpenBrowser(url) abort
        call v:lua.MkdpOpenBrowser(a:url)
      endfunction
    ]])
    vim.g.mkdp_browserfunc = "MkdpOpenBrowser"
  end,
  ft = { "markdown" },
}
