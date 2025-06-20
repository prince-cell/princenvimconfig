return {
  { 'williamboman/mason.nvim', config = function() require("mason").setup() end },
  {
    'williamboman/mason-lspconfig.nvim',
    config = function()
      require('mason-lspconfig').setup({
        -- List of LSP servers to install automatically by Mason
        ensure_installed = {
        },
      })
    end,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'saghen/blink.cmp', 'j-hui/fidget.nvim' },

    config = function()
      local lspconfig = require('lspconfig')
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Define a table of servers and their configurations
      local servers = {
        lua_ls = {},
        rust_analyzer = {},
        pyright = {},
        cssls = {},
        rescriptls = {},
        fsautocomplete = {},
        intelephense = {},
        html = {},
        ocamllsp = {},
        solargraph = {},
        elmls = {},
        hls = {},
        ts_ls = {},
      }

      -- Loop through the servers and set them up
      for server_name, server_opts in pairs(servers) do
        lspconfig[server_name].setup(vim.tbl_deep_extend("force", {
          capabilities = capabilities,
        }, server_opts))
      end

      -- You can also attach custom configurations for specific servers here
      -- Example for luals:
      -- lspconfig.luals.setup({
      --   capabilities = capabilities,
      --   settings = {
      --     Lua = {
      --       diagnostics = {
      --         globals = { 'vim' },
      --       },
      --       workspace = {
      --         library = vim.api.nvim_get_runtime_file("", true),
      --       },
      --     },
      --   },
      -- })

      -- Example for rust_analyzer:
      -- lspconfig.rust_analyzer.setup({
      --   capabilities = capabilities,
      --   settings = {
      --     ['rust-analyzer'] = {
      --       -- Your rust-analyzer specific settings
      --     },
      --   },
      -- })
    end
  },
  {
    'saghen/blink.cmp',
    dependencies = { 'rafamadriz/friendly-snippets' },

    version = '1.*',
    opts = {
      keymap = {
        preset = 'none',
        ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-e>'] = { 'hide', 'fallback' },

        ['<Tab>'] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.accept()
            else
              return cmp.select_and_accept()
            end
          end,
          'snippet_forward',
          'fallback'
        },
        ['<S-Tab>'] = { 'snippet_backward', 'fallback' },

        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
        ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },

        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

        ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
      },
      appearance = {
        nerd_font_variant = 'mono',
      },
      cmdline = { completion = { ghost_text = { enabled = true } } },
      completion = {
        documentation = { auto_show = false },
        ghost_text = {
          enabled = true,
          -- Show the ghost text when an item has been selected
          show_with_selection = true,
          -- Show the ghost text when no item has been selected, defaulting to the first item
          show_without_selection = false,
          -- Show the ghost text when the menu is open
          show_with_menu = true,
          -- Show the ghost text when the menu is closed
          show_without_menu = true,
        },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" }
    },
    -- 'super-tab' for mappings similar to vscode (tab to accept)
    -- 'enter' for enter to accept
    -- 'none' for no mappings
    --
    -- All presets have the following mappings:
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    --
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = { preset = 'default' },
    -- Displays a preview of the selected item on the current line

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono'
    },

    -- (Default) Only show the documentation popup when manually triggered
    completion = { documentation = { auto_show = true } },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
    -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
    -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
    --
    -- See the fuzzy documentation for more information
    fuzzy = { implementation = "prefer_rust_with_warning" }
  },
}
