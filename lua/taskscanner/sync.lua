local M = {}
local util = require("taskscanner.util")

function M.sync_completed_tasks()
  local notes_config = require("configs.notes")
  local notes_dir = notes_config.notes_dir:gsub("^~", os.getenv("HOME") or "")
  local task_file = notes_dir .. "/current_tasks.md"

  -- Step 1: Read completed tasks from current_tasks.md
  local completed_tasks = {}
  local tf = io.open(task_file, "r")
  if tf then
    for line in tf:lines() do
      if line:match("^%- %[X%] ") then
        local norm = util.normalize_task_line(line)
        completed_tasks[norm] = true
      end
    end
    tf:close()
  else
    vim.notify("✘ Failed to read: " .. task_file, vim.log.levels.ERROR)
    return {}
  end

  -- Step 2: Update matching tasks in all .md files (excluding current_tasks.md)
  local grep_cmd = "grep -rl --include='*.md' '#task' " .. notes_dir .. " | grep -v 'current_tasks.md'"
  local handle = io.popen(grep_cmd)
  if not handle then
    vim.notify("✘ Failed to execute grep command", vim.log.levels.ERROR)
    return completed_tasks
  end

  for filename in handle:lines() do
    local lines = {}
    local changed = false

    local rf = io.open(filename, "r")
    if rf then
      for line in rf:lines() do
        local is_unchecked_task = line:match("^%- %[ %] .*#task")
        if is_unchecked_task then
          local norm = util.normalize_task_line(line)
          if completed_tasks[norm] then
            lines[#lines + 1] = line:gsub("^%- %[%s*%]", "- [X]")
            changed = true
          else
            lines[#lines + 1] = line
          end
        else
          lines[#lines + 1] = line
        end
      end

      rf:close()
    end

    if changed then
      local wf = io.open(filename, "w")
      if wf then
        for _, l in ipairs(lines) do
          wf:write(l .. "\n")
        end
        wf:close()
        vim.notify("✔ Updated: " .. filename, vim.log.levels.INFO)
      else
        vim.notify("✘ Failed to write: " .. filename, vim.log.levels.ERROR)
      end
    end
  end

  handle:close()
  require("taskscanner.write").write_tasks()
end

return M
