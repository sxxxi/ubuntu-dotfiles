vim.api.nvim_clear_autocmds({ event = { "VimEnter", "FileType", } })

-- Open file explorer on startup
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Open only if current buffer is an empty file
    if vim.fn.bufname("%") == "" then
      require "telescope".extensions.file_browser.file_browser()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true) -- Simulate pressing ESC
    end
  end
})

-- File specific configs
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "jsonc",
    "json",
    "lua",
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
    "css",
    "scss",
    "html",
  },
  callback = function()
    vim.opt.tabstop = 2
    vim.opt.shiftwidth = 2
    vim.opt.softtabstop = 2
  end
})
