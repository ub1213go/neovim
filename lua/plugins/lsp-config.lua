return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { 
          "lua_ls",
          "csharp_ls",
          -- "cssls",
          -- "css_variables",
          "dockerls",
          "html",
          "eslint",
          "jsonls",
          -- "remark_ls",
          -- "pylsp",
          -- "sqlls",
          "volar",
          -- "cssls",
          "rust_analyzer"
        }
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local lspconfig = require("lspconfig")
      lspconfig.lua_ls.setup({
        capabilities = capabilities
      })
      lspconfig.csharp_ls.setup({
        capabilities = capabilities
      })
      -- lspconfig.cssls.setup({})
      -- lspconfig.css_variables.setup({})
      lspconfig.dockerls.setup({
        capabilities = capabilities
      })
      lspconfig.html.setup({
        capabilities = capabilities
      })
      lspconfig.eslint.setup({
        capabilities = capabilities
      })
      lspconfig.jsonls.setup({
        capabilities = capabilities
      })
      -- lspconfig.remark_ls.setup({})
      -- lspconfig.pylsp.setup({})
      -- lspconfig.sqlls.setup({})
      lspconfig.volar.setup({
        capabilities = capabilities
      })
      -- lspconfig.cssls.setup({})
      lspconfig.rust_analyzer.setup({
        capabilities = capabilities
      })

      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
      vim.keymap.set({ 'n' }, '<leader>ca', vim.lsp.buf.code_action, {})
    end
  }
}
