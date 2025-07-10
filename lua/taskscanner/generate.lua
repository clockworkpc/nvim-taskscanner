local M = {}

local function trim(s)
  return s:match("^%s*(.-)%s*$")
end

--- Generate markdown task list, optionally filtering by tag
-- @param notes_dir string - directory to search
-- @param tag string|nil - optional tag filter (e.g., "#urgent")
-- @return table - markdown lines
function M.generate_tasks(notes_dir, tag)
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
        if line:match("^%- %[ %] #task") then
          local clean = trim(line)
          if not tag or clean:find(tag, 1, true) then
            table.insert(tasks, clean)
          end
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
