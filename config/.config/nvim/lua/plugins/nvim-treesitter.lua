return {
  "nvim-treesitter/nvim-treesitter",
  enabled = true,
  config = function()
    require("nvim-treesitter.configs").setup({
      auto_install = true,
      ensure_installed = {
        "kotlin",
        "python",
        "rust",
        "java",
        "c",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "markdown",
        "markdown_inline",
        "html",
        "css",
        "php",
        "javascript",
        "typescript",
      },
      highlight = { enable = true },
      indent = { enable = true },
      filetypes = {
        -- Bruh
        blade = {
          "html",
          "php",
          "css",
        },
      },
    })
  end,
}
