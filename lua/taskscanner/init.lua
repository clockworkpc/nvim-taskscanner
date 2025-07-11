local M = {}

M.setup = function(opts)
  require("taskscanner.config").setup(opts or {})
end

M.write_tasks = require("taskscanner.write").write_tasks
M.write_new_tasks = require("taskscanner.write_new").write_new_tasks
M.sync_completed_tasks = require("taskscanner.sync").sync_completed_tasks

return M
