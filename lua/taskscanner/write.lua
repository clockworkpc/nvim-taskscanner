local M = {}
local util = require("taskscanner.util")

function M.write_tasks()
  local notes_config = require("configs.notes")
  local notes_dir = notes_config.notes_dir:gsub("^~", os.getenv("HOME") or "")

  local function is_dir(path)
    local stat = vim.loop.fs_stat(path)
    return stat and stat.type == "directory"
  end

  if not is_dir(notes_dir) then
    vim.notify("taskscanner: notes_dir does not exist: " .. notes_dir, vim.log.levels.ERROR)
    return {}
  end

  local output_file = notes_dir .. "/current_tasks.md"

  local urgent_tasks = {}
  local normal_tasks = {}
  local seen = {}
  local completed = {}
  local task_sources = {}

  local grep_cmd = "grep -r --include='*.md' '#task' " .. notes_dir .. " | grep -v 'current_tasks.md'"

  local handle = io.popen(grep_cmd)

  if handle then
    for line in handle:lines() do
      local filename, content = line:match("^(.-):(.*)$")
      if content and filename then
        content = vim.trim(content)

        local is_task = content:match("#task")
        if is_task then
          local norm = util.normalize_task_line(content)
          if content:match("^%- %[X%]") then
            completed[norm] = true
          elseif content:match("^%- %[ %]") then
            if not completed[norm] and not seen[norm] then
              seen[norm] = true
              task_sources[norm] = filename
              if content:match("#urgent") then
                table.insert(urgent_tasks, content)
              else
                table.insert(normal_tasks, content)
              end
            end
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
  else
    vim.notify("Failed to open " .. output_file, vim.log.levels.ERROR)
  end
  return task_sources
end

return M
