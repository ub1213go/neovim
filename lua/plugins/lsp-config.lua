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
          "cssls",
          "css_variables",
          "dockerls",
          "html",
          "eslint",
          "jsonls",
          -- "remark_ls",
          -- "pylsp",
          -- "sqlls",
          "volar",
          "rust_analyzer"
        }
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      lspconfig.lua_ls.setup({})
      lspconfig.csharp_ls.setup({})
      lspconfig.cssls.setup({})
      lspconfig.css_variables.setup({})
      lspconfig.dockerls.setup({})
      lspconfig.html.setup({})
      lspconfig.eslint.setup({})
      lspconfig.jsonls.setup({})
      -- lspconfig.remark_ls.setup({})
      lspconfig.pylsp.setup({})
      -- lspconfig.sqlls.setup({})
      lspconfig.volar.setup({})
      -- lspconfig.cssls.setup({})
      lspconfig.rust_analyzer.setup({})

      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
      vim.keymap.set({ 'n' }, '<leader>ca', vim.lsp.buf.code_action, {})
    end
  }
}
