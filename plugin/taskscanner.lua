vim.api.nvim_create_user_command("WriteTasks", function()
  require("taskscanner").write_tasks()
end, {})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "current_tasks.md",
  callback = function()
    require("taskscanner").sync_completed_tasks()
  end,
})
