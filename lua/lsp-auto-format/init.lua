local M = {}
M._BUFFERS_TO_OMIT_FOR_AUTO_FORMAT = {}
M._PAUSE_AUTO_FORMAT = false
M._AUGROUP = "LspFormatting"

local notify = function(message, level)
  vim.notify(message, level, { title = "lsp-auto-format" })
end

M.on_attach = function(bufnr)
  local augroup = M._AUGROUP
  local success = pcall(vim.api.nvim_clear_autocmds, { group = augroup, buffer = bufnr })
  if not success then
    notify("Creating autocmd " .. augroup .. " failed. Did you call the setup function?", vim.log.levels.ERROR)
    return
  end

  vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    buffer = bufnr,
    callback = function()
      if M._PAUSE_AUTO_FORMAT or M._BUFFERS_TO_OMIT_FOR_AUTO_FORMAT[bufnr] then
        -- vim.notify("omitting  auto format before save on bufnr: " .. bufnr)
        return
      end
      -- vim.notify("formatting on save for bufnr: " .. bufnr)
      vim.lsp.buf.format({ bufnr = bufnr })
    end,
  })
end

M.enable_auto_save = function()
  local bufnr = vim.fn.bufnr()
  -- vim.notify("enabling auto format on save for bufnr: " .. bufnr)
  M._BUFFERS_TO_OMIT_FOR_AUTO_FORMAT[bufnr] = false
  M._PAUSE_AUTO_FORMAT = false
end

M.disable_auto_save = function()
  local bufnr = vim.fn.bufnr()
  -- vim.notify("disabling auto format on save for bufnr: " .. bufnr)
  M._BUFFERS_TO_OMIT_FOR_AUTO_FORMAT[bufnr] = true
end

M.pause_auto_save = function()
  -- vim.notify("pausing auto format for all files.")
  M._PAUSE_AUTO_FORMAT = true
end

M.is_auto_save_disabled = function()
  local bufnr = vim.fn.bufnr()
  return M._BUFFERS_TO_OMIT_FOR_AUTO_FORMAT[bufnr]
end

M.is_auto_save_paused_globally = function()
  return M._PAUSE_AUTO_FORMAT
end

M.config = {
  augroup = "LspFormatting",
}

M.setup = function(config)
  M.config = vim.tbl_extend("force", M.config, config or {})
  local success, augroup = pcall(vim.api.nvim_create_augroup, M.config.augroup, {})

  if not success then
    notify("Creating augroup failed. Did you pass a valid string as the augroup in setup?", vim.log.levels.ERROR)
    return
  end

  M._AUGROUP = augroup
end

return M
