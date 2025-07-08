---- lua/taskscanner/init.lua
local M = {}

function M.write_tasks()
  local project_root = vim.fn.getcwd()
  local output_file = project_root .. "/current_tasks.md"
  local lines_set = {}
  local lines = {}

  local grep_cmd = "grep -r --include='*.md' '#task' " .. project_root .. " | grep -v 'current_tasks.md'"
  local handle = io.popen(grep_cmd)
  if handle then
    for line in handle:lines() do
      local content = line:match("^[^:]*:(.*)")
      if content then
        content = vim.trim(content)
        if content:match("^%- %[ %]") and content:match("#task") then
          if not lines_set[content] then
            lines_set[content] = true
            table.insert(lines, content)
          end
        end
      end
    end
    handle:close()
  end

  local file = io.open(output_file, "w")
  if file then
    for _, l in ipairs(lines) do
      file:write(l .. "\n")
    end
    file:close()
    vim.notify("Task list written to: " .. output_file, vim.log.levels.INFO)
  else
    vim.notify("Failed to open " .. output_file, vim.log.levels.ERROR)
  end
end

function M.sync_completed_tasks()
  local project_root = vim.fn.getcwd()
  local task_file = project_root .. "/current_tasks.md"

  -- Step 1: Extract completed task bodies
  local completed_tasks = {}
  local f = io.open(task_file, "r")
  if f then
    for line in f:lines() do
      local body = line:match("^%- %[X%] (.*)")
      if body then
        completed_tasks[body] = true
      end
    end
    f:close()
  else
    vim.notify("Failed to read current_tasks.md", vim.log.levels.ERROR)
    return
  end

  -- Step 2: Scan files containing '#task' except current_tasks.md
  local grep_cmd = "grep -rl --include='*.md' '#task' " .. project_root .. " | grep -v current_tasks.md"
  local handle = io.popen(grep_cmd)
  if not handle then
    vim.notify("Failed to run grep", vim.log.levels.ERROR)
    return
  end

  for filename in handle:lines() do
    local updated_lines = {}
    local changed = false

    local rf = io.open(filename, "r")
    if rf then
      for line in rf:lines() do
        local match = line:match("^%- %[ %] (.*)")
        if match and completed_tasks[match] then
          table.insert(updated_lines, "- [X] " .. match)
          changed = true
        else
          table.insert(updated_lines, line)
        end
      end
      rf:close()
    end

    if changed then
      local wf = io.open(filename, "w")
      if wf then
        for _, l in ipairs(updated_lines) do
          wf:write(l .. "\n")
        end
        wf:close()
        vim.notify("✔ Updated: " .. filename, vim.log.levels.INFO)
      else
        vim.notify("✘ Failed to write to: " .. filename, vim.log.levels.ERROR)
      end
    end
  end

  handle:close()
  M.write_tasks()
end

return M
