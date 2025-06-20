-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
<<<<<<< HEAD
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '\\', ':Neotree reveal<CR>', { desc = 'NeoTree reveal' } },
  },
  opts = {
    filesystem = {
      window = {
        mappings = {
          ['\\'] = 'close_window',
        },
      },
    },
  },
=======
  'stevearc/oil.nvim',
  opts = {},                                        -- You can put oil.nvim options here
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- Optional: for icons
  config = function()
    require("oil").setup()

    -- Set your leader key if not already set globally
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "

    -- Keybinding to open Oil
    vim.keymap.set("n", "<leader>e", function()
      require("oil").open()
    end, { desc = "Open Oil" })

    -- Optional: Keybinding to toggle floating Oil
    -- vim.keymap.set("n", "<leader>E", function()
    --   require("oil").toggle_float()
    -- end, { desc = "Toggle Oil float" })
  end,
>>>>>>> 4e07d05 (neovim updated)
}
