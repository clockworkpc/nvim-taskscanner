vim.api.nvim_create_user_command("WriteTasks", function()
  require("taskscanner").write_tasks(vim.api.nvim_buf_get_name(0))
end, {})

-- vim.api.nvim_create_user_command("WriteNewTasks", function()
--   require("taskscanner").write_tasks()
-- end, {})


vim.api.nvim_create_user_command("SyncTasks", function()
  require("taskscanner").sync_completed_tasks()
end, {})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "current_tasks.md",
  callback = function()
    vim.defer_fn(function()
      local ts = require("taskscanner")
      ts.sync_completed_tasks()
    end, 100)
  end,
})

