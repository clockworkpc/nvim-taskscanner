local M = {}

-- Utility to trim whitespace
local function trim(s)
  return s:match("^%s*(.-)%s*$")
end

--- Returns a table of formatted markdown task lines
function M.generate_tasks(notes_dir)
  local handle = io.popen("find " .. notes_dir .. " -name '*.md' ! -name 'current_tasks.md'")
  if not handle then
    vim.notify("taskscanner: failed to scan notes dir", vim.log.levels.ERROR)
    return {}
  end

  local tasks = {}

  for filepath in handle:lines() do
    local file = io.open(filepath, "r")
    if file then
      for line in file:lines() do
        if line:match("^%- %[ %] #task ") then
          table.insert(tasks, trim(line))
        end
      end
      file:close()
    end
  end

  handle:close()
  table.sort(tasks)
  return tasks
end

return M
