vim.api.nvim_create_user_command("WriteTasks", function()
  require("taskscanner").write_tasks()
end, {})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "current_tasks.md",
  callback = function()
    require("taskscanner").sync_completed_tasks()
  end,
})

-- When saving any other markdown file: refresh the task list
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.md",
  callback = function(args)
    if not args.file:match("current_tasks.md$") then
      require("taskscanner").write_tasks()
    end
  end,
})
