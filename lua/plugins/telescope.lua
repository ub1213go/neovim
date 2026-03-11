return {
  enabled = false,
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    dependencies = { 
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-fzf-native.nvim'  -- 性能優化
    },
    config = function()
      local telescope = require('telescope')
      local builtin = require('telescope.builtin')
      
      -- Telescope 優化設置
      telescope.setup({
        defaults = {
          prompt_prefix = "🔍 ",
          selection_caret = "➤ ",
          path_display = {"smart"},
          file_ignore_patterns = {
            "node_modules/.*",
            "%.git/.*",
            "dist/.*",
            "build/.*"
          }
        },
        pickers = {
          find_files = {
            hidden = true  -- 顯示隱藏檔案
          },
          live_grep = {
            additional_args = function()
              return {"--hidden"}  -- 搜尋隱藏檔案
            end
          }
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          }
        }
      })
      
      -- 載入 fzf 擴展
      pcall(telescope.load_extension, 'fzf')
      
      -- 你原有的快速鍵
      vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = 'Telescope find files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
      vim.keymap.set('n', 'gd', builtin.lsp_definitions, {})
      vim.keymap.set('n', '<S-F12>', builtin.lsp_type_definitions, {})
      vim.keymap.set('n', '<C-F12>', builtin.lsp_implementations, {})
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
      vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename)
      
      -- 新增：實用的搜尋功能
      vim.keymap.set('n', '<leader>fw', function()
        builtin.grep_string({ search = vim.fn.expand("<cword>") })
      end, { desc = "搜尋當前單字" })
      
      vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = "最近開啟的檔案" })
      
      -- 類似 VSCode 的搜尋體驗
      vim.keymap.set('n', '<C-S-f>', function()
        builtin.live_grep({
          prompt_title = "🔍 Search in Project"
        })
      end, { desc = "專案內搜尋" })
      
      -- 實用的搜尋指令
      
      -- 在指定目錄搜尋
      vim.api.nvim_create_user_command('SearchDir', function(opts)
        local args = vim.split(opts.args, ' ', {trimempty = true})
        local pattern = args[1]
        local directory = args[2] or vim.fn.getcwd()
        
        if pattern and pattern ~= "" then
          builtin.grep_string({
            search = pattern,
            search_dirs = {directory},
            prompt_title = "Search '" .. pattern .. "' in " .. directory
          })
        else
          builtin.live_grep({
            search_dirs = {directory},
            prompt_title = "Live grep in " .. directory
          })
        end
      end, {
        desc = "在指定目錄搜尋：SearchDir <pattern> [directory]",
        nargs = '*'
      })
      
      -- 搜尋 TODO/FIXME 等標記
      vim.api.nvim_create_user_command('SearchTodos', function()
        builtin.grep_string({
          search = "(TODO|FIXME|NOTE|HACK|XXX|BUG):",
          use_regex = true,
          prompt_title = "Search TODOs and FIXMEs"
        })
      end, { desc = "搜尋 TODO, FIXME 等標記" })
      
    end
  },
  
  -- 新增：fzf 性能優化擴展
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
  },
  
  -- 新增：Spectre 搜尋取代工具
  {
    'nvim-pack/nvim-spectre',
    dependencies = {'nvim-lua/plenary.nvim'},
    keys = {
      {"<leader>S", function() 
        -- 正確的重置方式
        local spectre = require("spectre")
        local state = require("spectre.state")
        
        -- 強制重置狀態
        if state.is_running then
          state.is_running = false
          vim.notify("重置 Spectre 狀態", vim.log.levels.INFO)
        end
        
        -- 清理可能的殘留 buffer
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          local name = vim.api.nvim_buf_get_name(buf)
          if name:match("spectre_panel") then
            pcall(vim.api.nvim_buf_delete, buf, {force = true})
          end
        end
        
        spectre.toggle()
      end, desc = "開啟 Spectre 搜尋取代"},
      
      {"<leader>sw", function() 
        local state = require("spectre.state")
        state.is_running = false
        require("spectre").open_visual({select_word=true})
      end, desc = "搜尋當前單字"},
      
      {"<leader>sp", function() 
        local state = require("spectre.state")
        state.is_running = false
        require("spectre").open_file_search({select_word=true})
      end, desc = "在當前檔案搜尋"},
      
      -- 手動重置快捷鍵
      {"<leader>sR", function()
        pcall(function() require("spectre").close() end)
        require("spectre.state").is_running = false
        
        -- 清理 buffer
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          local name = vim.api.nvim_buf_get_name(buf)
          if name:match("spectre_panel") then
            pcall(vim.api.nvim_buf_delete, buf, {force = true})
          end
        end
        
        vim.notify("Spectre 已完全重置", vim.log.levels.INFO)
      end, desc = "重置 Spectre"},
    },
    config = function()
      local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
      
      require('spectre').setup({
        replace_engine = {
          ['sed'] = {
            cmd = "sed",
            -- 不使用 args,讓 spectre 自己組合命令
          },
        },
        default = {
          find = {
            cmd = "rg",
          },
          replace = {
            cmd = "sed"
          }
        },
        -- 關鍵:設定 sed 的命令格式
        replace_vim_cmd = "cdo",
        is_open_target_win = true,
        is_insert_mode = false,
      })
      
      -- 自動清理:當離開 spectre buffer 時重置狀態
      vim.api.nvim_create_autocmd("BufLeave", {
        pattern = "*",
        callback = function()
          local buf_name = vim.api.nvim_buf_get_name(0)
          if buf_name:match("spectre_panel") then
            vim.defer_fn(function()
              local ok, state = pcall(require, "spectre.state")
              if ok then
                state.is_running = false
              end
            end, 100)
          end
        end,
      })
    end
  },
  
  -- 你原有的 ui-select
  {
    'nvim-telescope/telescope-ui-select.nvim',
    config = function()
      require("telescope").setup {
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown {
            }
          }
        }
      }
      require("telescope").load_extension("ui-select")
    end
  }
}


-- return {
--   {
--     'nvim-telescope/telescope.nvim', tag = '0.1.8',
--   -- or                              , branch = '0.1.x',
--     dependencies = { 'nvim-lua/plenary.nvim' },
--     config = function()
--       local builtin = require('telescope.builtin')
--       vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = 'Telescope find files' })
--       vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
--       vim.keymap.set('n', 'gd', builtin.lsp_definitions, {})
--       vim.keymap.set('n', '<S-F12>', builtin.lsp_type_definitions, {})
--       vim.keymap.set('n', '<C-F12>', builtin.lsp_implementations, {})
--       vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
--       vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
--       vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename)
--     end
--   },
--   {
--     'nvim-telescope/telescope-ui-select.nvim',
--     config = function()
--       require("telescope").setup {
--         extensions = {
--           ["ui-select"] = {
--             require("telescope.themes").get_dropdown {
--             }
--           }
--         }
--       }
--       require("telescope").load_extension("ui-select")
--     end
--   }
-- }
