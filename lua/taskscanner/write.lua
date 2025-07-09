local M = {}

function M.write_tasks()
  local notes_config = require("configs.notes")
  local notes_dir = notes_config.notes_dir
  local output_file = notes_dir .. "/current_tasks.md"

  local urgent_tasks, normal_tasks, seen, completed_tasks = {}, {}, {}, {}

  local grep_cmd = "grep -r --include='*.md' '#task' " .. notes_dir
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
        elseif content:match("^%- %[X%]") then
          local body = content:match("^%- %[X%] (.*)")
          if body then
            completed_tasks[body] = true
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
    table.insert(lines, "")
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
      local body = l:match("^%- %[X%] (.*)")
      if body then
        completed_tasks[body] = true
      end
    end
    file:close()
    vim.notify("Task list written to: " .. output_file, vim.log.levels.INFO)
  else
    vim.notify("Failed to open " .. output_file, vim.log.levels.ERROR)
  end

  return completed_tasks
end

return M
