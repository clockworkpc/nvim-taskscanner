vim.api.nvim_create_user_command("WriteTasks", function()
  require("taskscanner").write_tasks()
end, {})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "current_tasks.md",
  callback = function()
    vim.defer_fn(function()
      local ts = require("taskscanner")
      local completed = ts.sync_completed_tasks() -- update origin
      ts.write_tasks(completed)                   -- regenerate from origin
    end, 100)
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.md",
  callback = function(args)
    if not args.file:match("current_tasks.md$") then
      require("taskscanner").write_tasks()
    end
  end,
})
