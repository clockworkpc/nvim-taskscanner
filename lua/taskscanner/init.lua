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

return M
