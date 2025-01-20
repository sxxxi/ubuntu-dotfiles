return {
  "nvim-treesitter/nvim-treesitter",
  enabled = true,
  config = function()

    vim.treesitter.language.register('html', 'blade')
    vim.treesitter.language.register('css', 'blade')
    vim.treesitter.language.register('php', 'blade')

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
    })
  end,
}
