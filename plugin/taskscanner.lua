vim.api.nvim_create_user_command("WriteTasks", function()
  require("taskscanner").write_tasks()
end, {})

vim.api.nvim_create_user_command("SyncTasks", function()
  require("taskscanner").sync_completed_tasks()
end, {})

-- vim.api.nvim_create_autocmd("BufWritePost", {
--   pattern = "current_tasks.md",
--   callback = function()
--     vim.defer_fn(function()
--       local ts = require("taskscanner")
--       local sources = ts.write_tasks()                   -- step 1: get map
--       local completed = ts.sync_completed_tasks(sources) -- step 2: update sources
--       ts.write_tasks(completed)                          -- step 3: rebuild view
--     end, 100)
--   end,
-- })

-- vim.api.nvim_create_autocmd("BufWritePost", {
--   pattern = "*.md",
--   callback = function(args)
--     if not args.file:match("current_tasks.md$") then
--       require("taskscanner").write_tasks()
--     end
--   end,
-- })
