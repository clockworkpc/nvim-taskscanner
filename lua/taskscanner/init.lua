local config = require("taskscanner.config")
local M = {}

function M.setup(opts)
  require("taskscanner.config").setup(opts or {})
end

function M.write_tasks()
  local notes_dir = require("taskscanner.config").notes_dir
  local output_file = notes_dir .. "/current_tasks.md"

  local urgent_tasks = {}
  local normal_tasks = {}
  local seen = {}

  local grep_cmd = "grep -r --include='*.md' '#task' " .. notes_dir .. " | grep -v 'current_tasks.md'"
  local handle = io.popen(grep_cmd)
  if handle then
    for line in handle:lines() do
      local content = line:match("^[^:]*:(.*)")
      if content then
        content = vim.trim(content)
        if content:match("^%- %[ %]") and content:match("#task") and not seen[content] then
          seen[content] = true
          if content:match("#urgent") then
            table.insert(urgent_tasks, content)
          else
            table.insert(normal_tasks, content)
          end
        end
      end
    end
    handle:close()
  end

  table.sort(urgent_tasks)
  table.sort(normal_tasks)

  local lines = {}
  if #urgent_tasks > 0 then
    table.insert(lines, "## Urgent Tasks")
    vim.list_extend(lines, urgent_tasks)
    table.insert(lines, "") -- blank line
  end

  if #normal_tasks > 0 then
    table.insert(lines, "## Tasks")
    vim.list_extend(lines, normal_tasks)
    table.insert(lines, "")
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
  local notes_config = require("configs.notes")
  local notes_dir = notes_config.notes_dir
  local task_file = notes_dir .. "/current_tasks.md"

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
  local grep_cmd = "grep -rl --include='*.md' '#task' " .. notes_dir .. " | grep -v 'current_tasks.md'"
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
