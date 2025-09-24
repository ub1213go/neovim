-- ~/.config/nvim/lua/plugins/dap.lua
-- 完整的 DAP 調試配置，支援 Python, Node.js, C#/.NET, Rust, Vue.js

return {
  -- DAP 核心插件
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- DAP UI - 提供友好的調試界面
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        config = function()
          local dap = require("dap")
          local dapui = require("dapui")
          
          dapui.setup({
            -- 可以自定義 UI 布局
            layouts = {
              {
                elements = {
                  { id = "scopes", size = 0.25 },
                  { id = "breakpoints", size = 0.25 },
                  { id = "stacks", size = 0.25 },
                  { id = "watches", size = 0.25 },
                },
                size = 40,
                position = "left",
              },
              {
                elements = {
                  { id = "repl", size = 0.5 },
                  { id = "console", size = 0.5 },
                },
                size = 10,
                position = "bottom",
              },
            },
          })
          
          -- 自動打開/關閉 DAP UI
          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
          end
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
          end
        end,
      },
      
      -- 虛擬文本顯示變量值
      {
        "theHamsta/nvim-dap-virtual-text",
        config = function()
          require("nvim-dap-virtual-text").setup({
            enabled = true,
            enabled_commands = true,
            highlight_changed_variables = true,
            highlight_new_as_changed = false,
            show_stop_reason = true,
            commented = false,
            only_first_definition = true,
            all_references = false,
            clear_on_continue = false,
            display_callback = function(variable, buf, stackframe, node, options)
              if options.virt_text_pos == 'inline' then
                return ' = ' .. variable.value
              else
                return variable.name .. ' = ' .. variable.value
              end
            end,
            virt_text_pos = vim.fn.has('nvim-0.10') == 1 and 'inline' or 'eol',
          })
        end,
      },
    },
    
    config = function()
      local dap = require("dap")
      
      -- 設置斷點圖標
      vim.fn.sign_define("DapBreakpoint", { 
        text = "🔴", 
        texthl = "DiagnosticSignError", 
        linehl = "", 
        numhl = "" 
      })
      vim.fn.sign_define("DapStopped", { 
        text = "➡️", 
        texthl = "DiagnosticSignWarn", 
        linehl = "Visual", 
        numhl = "" 
      })
      vim.fn.sign_define("DapBreakpointCondition", { 
        text = "🟡", 
        texthl = "DiagnosticSignHint", 
        linehl = "", 
        numhl = "" 
      })
      vim.fn.sign_define("DapBreakpointRejected", { 
        text = "⚫", 
        texthl = "DiagnosticSignError", 
        linehl = "", 
        numhl = "" 
      })
      
      -- ===================
      -- Python 配置
      -- ===================
      dap.adapters.python = function(cb, config)
        if config.request == 'attach' then
          local port = (config.connect or config).port
          local host = (config.connect or config).host or '127.0.0.1'
          cb({
            type = 'server',
            port = assert(port, '`connect.port` is required for a python `attach` configuration'),
            host = host,
            options = {
              source_filetype = 'python',
            },
          })
        else
          cb({
            type = 'executable',
            command = 'python',
            args = { '-m', 'debugpy.adapter' },
            options = {
              source_filetype = 'python',
            },
          })
        end
      end

      dap.configurations.python = {
        {
          type = 'python',
          request = 'launch',
          name = "Launch file",
          program = "${file}",
          pythonPath = function()
            local cwd = vim.fn.getcwd()
            if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
              return cwd .. '/venv/bin/python'
            elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
              return cwd .. '/.venv/bin/python'
            else
              return '/usr/bin/python3'
            end
          end,
        },
        {
          type = 'python',
          request = 'launch',
          name = "Launch file with arguments",
          program = "${file}",
          args = function()
            local args_string = vim.fn.input('Arguments: ')
            return vim.split(args_string, " +")
          end,
          pythonPath = function()
            local cwd = vim.fn.getcwd()
            if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
              return cwd .. '/venv/bin/python'
            elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
              return cwd .. '/.venv/bin/python'
            else
              return '/usr/bin/python3'
            end
          end,
        },
        {
          type = 'python',
          request = 'launch',
          name = "Launch Django",
          program = "${workspaceFolder}/manage.py",
          args = {
            'runserver',
            '--noreload'
          },
          pythonPath = function()
            local cwd = vim.fn.getcwd()
            if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
              return cwd .. '/venv/bin/python'
            elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
              return cwd .. '/.venv/bin/python'
            else
              return '/usr/bin/python3'
            end
          end,
          django = true,
        },
        {
          type = 'python',
          request = 'launch',
          name = "Launch Flask",
          module = 'flask',
          env = {
            FLASK_APP = 'app.py'
          },
          args = {
            'run',
            '--no-debugger',
            '--no-reload',
          },
          jinja = true,
        },
      }

      -- ===================
      -- Node.js/JavaScript/TypeScript 配置
      -- ===================
      dap.adapters["node2"] = {
        type = "executable",
        command = "node",
        args = {
          os.getenv("HOME") .. "/.local/share/nvim/mason/packages/node-debug2-adapter/out/src/nodeDebug.js"
        },
      }

      dap.configurations.javascript = {
        {
          name = "Launch",
          type = "node2",
          request = "launch",
          program = "${file}",
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
          protocol = "inspector",
          console = "integratedTerminal",
        },
        {
          name = "Attach to process",
          type = "node2",
          request = "attach",
          processId = require("dap.utils").pick_process,
        },
        {
          name = "Launch Express Server",
          type = "node2",
          request = "launch",
          program = "${workspaceFolder}/bin/www",
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
          protocol = "inspector",
          console = "integratedTerminal",
        },
        {
          name = "Launch NestJS",
          type = "node2",
          request = "launch",
          program = "${workspaceFolder}/dist/main.js",
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
          protocol = "inspector",
          console = "integratedTerminal",
        },
      }

      dap.configurations.typescript = dap.configurations.javascript

      -- ===================
      -- Vue.js 配置
      -- ===================
      dap.adapters.chrome = {
        type = "executable",
        command = "node",
        args = {
          os.getenv("HOME") .. "/.local/share/nvim/mason/packages/chrome-debug-adapter/out/src/chromeDebug.js"
        }
      }

      dap.adapters.msedge = {
        type = "executable",
        command = "node",
        args = {
          os.getenv("HOME") .. "/.local/share/nvim/mason/packages/chrome-debug-adapter/out/src/chromeDebug.js"
        }
      }

      dap.configurations.vue = {
        {
          name = "Launch Vue.js (Chrome)",
          type = "chrome",
          request = "launch",
          url = "http://localhost:3000",
          webRoot = "${workspaceFolder}/src",
          sourceMaps = true,
          userDataDir = false,
        },
        {
          name = "Launch Vue.js (Edge)",
          type = "msedge",
          request = "launch",
          url = "http://localhost:3000",
          webRoot = "${workspaceFolder}/src",
          sourceMaps = true,
          userDataDir = false,
        },
        {
          name = "Attach to Vue.js (Chrome)",
          type = "chrome",
          request = "attach",
          port = 9222,
          webRoot = "${workspaceFolder}/src",
          sourceMaps = true,
        },
        {
          name = "Launch Vite Dev Server",
          type = "chrome",
          request = "launch",
          url = "http://localhost:5173",
          webRoot = "${workspaceFolder}/src",
          sourceMaps = true,
          userDataDir = false,
        },
        {
          name = "Launch Nuxt.js",
          type = "chrome",
          request = "launch",
          url = "http://localhost:3000",
          webRoot = "${workspaceFolder}",
          sourceMaps = true,
          userDataDir = false,
        },
        {
          name = "Launch Vue CLI",
          type = "chrome",
          request = "launch",
          url = "http://localhost:8080",
          webRoot = "${workspaceFolder}/src",
          sourceMaps = true,
          userDataDir = false,
        },
      }

      -- ===================
      -- C# / .NET 配置
      -- ===================
      dap.adapters.coreclr = {
        type = 'executable',
        command = os.getenv("HOME") .. '/.local/share/nvim/mason/packages/netcoredbg/netcoredbg',
        args = {'--interpreter=vscode'}
      }

      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "launch - netcoredbg",
          request = "launch",
          program = function()
            return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
          end,
        },
        {
          type = "coreclr",
          name = "attach - netcoredbg",
          request = "attach",
          processId = require("dap.utils").pick_process,
        },
        {
          type = "coreclr",
          name = "launch - netcoredbg (with build)",
          request = "launch",
          program = function()
            os.execute('dotnet build')
            return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
          end,
        },
      }

      -- F# 也使用相同配置
      dap.configurations.fsharp = dap.configurations.cs

      -- ===================
      -- Rust 配置
      -- ===================
      dap.adapters.codelldb = {
        type = 'server',
        port = "${port}",
        executable = {
          command = os.getenv("HOME") .. '/.local/share/nvim/mason/packages/codelldb/extension/adapter/codelldb',
          args = {"--port", "${port}"},
        }
      }

      dap.configurations.rust = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
        },
        {
          name = "Launch file with args",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
          end,
          args = function()
            local args_string = vim.fn.input('Arguments: ')
            return vim.split(args_string, " +")
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
        },
        {
          name = "Launch with cargo",
          type = "codelldb",
          request = "launch",
          program = function()
            os.execute('cargo build')
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
        },
      }

      -- C/C++ 也可以使用 codelldb
      dap.configurations.c = dap.configurations.rust
      dap.configurations.cpp = dap.configurations.rust

      -- ===================
      -- 基本快捷鍵設置
      -- ===================
      vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
      vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "Debug: Set Conditional Breakpoint" })
      
      -- 調試 UI 控制
      vim.keymap.set("n", "<leader>dt", require("dapui").toggle, { desc = "Debug: Toggle UI" })
      vim.keymap.set("n", "<leader>do", function()
        require("dapui").open()
      end, { desc = "Debug: Open UI" })
      vim.keymap.set("n", "<leader>dc", function()
        require("dapui").close()
      end, { desc = "Debug: Close UI" })
      
      -- 調試會話控制
      vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Debug: Open REPL" })
      vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Debug: Run Last" })
      vim.keymap.set("n", "<leader>dx", dap.terminate, { desc = "Debug: Terminate" })
      
      -- Telescope 整合
      vim.keymap.set("n", "<leader>dC", function()
        require("telescope").extensions.dap.configurations({})
      end, { desc = "Debug: Configurations" })
      vim.keymap.set("n", "<leader>dv", function()
        require("telescope").extensions.dap.variables({})
      end, { desc = "Debug: Variables" })
      vim.keymap.set("n", "<leader>df", function()
        require("telescope").extensions.dap.frames({})
      end, { desc = "Debug: Frames" })
      
      -- 額外的實用快捷鍵
      vim.keymap.set("n", "<leader>dh", function()
        require("dap.ui.widgets").hover()
      end, { desc = "Debug: Hover Variables" })
      vim.keymap.set("v", "<leader>dh", function()
        require("dap.ui.widgets").visual_hover()
      end, { desc = "Debug: Hover Variables (Visual)" })
      vim.keymap.set("n", "<leader>dp", function()
        require("dap.ui.widgets").preview()
      end, { desc = "Debug: Preview" })
      vim.keymap.set("n", "<leader>ds", function()
        local widgets = require("dap.ui.widgets")
        widgets.centered_float(widgets.scopes)
      end, { desc = "Debug: Scopes" })
    end,
  },

  -- 加載 Telescope DAP 擴展
  {
    "nvim-telescope/telescope.nvim",
    optional = true,
    dependencies = {
      "nvim-telescope/telescope-dap.nvim",
    },
    config = function()
      require("telescope").load_extension("dap")
    end,
  },
}
