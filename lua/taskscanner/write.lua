local M = {}

function M.write_tasks()
  local notes_config = require("configs.notes")
  local notes_dir = notes_config.notes_dir:gsub("^~", os.getenv("HOME"))
  local output_file = notes_dir .. "/current_tasks.md"

  local urgent_tasks = {}
  local normal_tasks = {}
  local seen = {}

  local grep_cmd = "grep -r --include='*.md' '#task' " .. notes_dir
  local handle = io.popen(grep_cmd)

  if handle then
    for line in handle:lines() do
      local content = line:match("^[^:]*:(.*)")
      if content then
        content = vim.trim(content)

        local is_unchecked = content:match("^%- %[ %]")
        local is_task = content:match("#task")
        local is_urgent = content:match("#urgent")

        if is_unchecked and is_task and not seen[content] then
          seen[content] = true
          if is_urgent then
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
    table.insert(lines, "")
  end

  if #normal_tasks > 0 then
    table.insert(lines, "## Tasks")
    vim.list_extend(lines, normal_tasks)
    table.insert(lines, "")
  end

  local file = io.open(output_file, "w")
  if file then
    for _, line in ipairs(lines) do
      file:write(line .. "\n")
    end
    file:close()
    vim.notify("Task list written to: " .. output_file, vim.log.levels.INFO)
  else
    vim.notify("Failed to open " .. output_file, vim.log.levels.ERROR)
  end
end

return M
