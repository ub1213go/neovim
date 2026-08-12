return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
    -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  },
  config = function()
    -- 要用外部瀏覽器開的副檔名（想加 svg / pdf 就往這裡加）
    local BROWSER_EXT = {
      html = true,
      htm = true,
      svg = true,
      pdf = true,
      csv = true,
    }

    local function open_in_browser(path)
      local cmd
      if vim.fn.executable("google-chrome") == 1 then
        -- pod 內沒有 user namespace，需要 --no-sandbox；X11 forward 沒有 GPU
        cmd = { "google-chrome", "--no-sandbox", "--disable-gpu", path }
      elseif vim.fn.executable("xdg-open") == 1 then
        cmd = { "xdg-open", path }
      else
        vim.notify("找不到瀏覽器（google-chrome / xdg-open 都沒有）", vim.log.levels.ERROR)
        return
      end
      vim.fn.jobstart(cmd, { detach = true })
      vim.notify("瀏覽器開啟：" .. vim.fn.fnamemodify(path, ":t"))
    end

    require('neo-tree').setup({
      window = {
        mappings = {
          -- o = 智慧開啟：html 丟瀏覽器渲染，其他照舊在 nvim 開
          -- （<CR> 保持原樣，永遠是進 nvim 編輯）
          ["o"] = function(state)
            local node = state.tree:get_node()
            local ext = vim.fn.fnamemodify(node.path or "", ":e"):lower()
            if node.type == "file" and BROWSER_EXT[ext] then
              open_in_browser(node.path)
            else
              -- 目錄會展開/收合，其他檔案照原本方式在 nvim 開
              state.commands["open"](state)
            end
          end,
          ["P"] = function(state)
            local node = state.tree:get_node()
            require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
          end,
          ["J"] = function(state)
            local tree = state.tree
            local node = tree:get_node()
            local siblings = tree:get_nodes(node:get_parent_id())
            local renderer = require('neo-tree.ui.renderer')
            renderer.focus_node(state, siblings[#siblings]:get_id())
          end,
          ["K"] = function(state)
            local tree = state.tree
            local node = tree:get_node()
            local siblings = tree:get_nodes(node:get_parent_id())
            local renderer = require('neo-tree.ui.renderer')
            renderer.focus_node(state, siblings[1]:get_id())
          end,
          -- disable fuzzy finder 
          ["/"] = "noop"
        }
      }

    })

    vim.keymap.set('n', '<C-n>', ':Neotree filesystem reveal left<CR>', {})
    vim.keymap.set('n', '<leader>n', function()
          local reveal_file = vim.fn.expand('%:p')
          if (reveal_file == '') then
            reveal_file = vim.fn.getcwd()
          else
            local f = io.open(reveal_file, "r")
            if (f) then
              f.close(f)
            else
              reveal_file = vim.fn.getcwd()
            end
          end
          require('neo-tree.command').execute({
            action = "focus",          -- OPTIONAL, this is the default value
            source = "filesystem",     -- OPTIONAL, this is the default value
            position = "left",         -- OPTIONAL, this is the default value
            reveal_file = reveal_file, -- path to file or folder to reveal
            reveal_force_cwd = true,   -- change cwd without asking if needed
          })
        end,
        { desc = "Open neo-tree at current file or working directory" }
      );
  end
}
