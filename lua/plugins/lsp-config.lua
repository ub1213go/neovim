return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
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
          "vue_ls", -- 舊名 volar 在新版已改名為 vue_ls
          "rust_analyzer",
        },
        -- 安裝好的 server 會自動呼叫 vim.lsp.enable（mason-lspconfig 2.0 預設行為）
        automatic_enable = true,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- nvim 0.11：個別 server 的覆寫改用 vim.lsp.config（沿用 lspconfig 提供的預設值）。
      -- 不需要覆寫就不用寫；需要時範例如下：
      -- vim.lsp.config("lua_ls", {
      --   settings = { Lua = { diagnostics = { globals = { "vim" } } } },
      -- })

      -- 鍵位改在 LSP attach 到該 buffer 時才綁定（buffer-local，較乾淨）
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
      })
    end,
  },
}
