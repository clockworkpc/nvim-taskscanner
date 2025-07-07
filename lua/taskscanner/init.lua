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

local function escape_lua_pattern(s)
  return s:gsub("([^%w])", "%%%1")
end

function M.sync_completed_tasks()
  local project_root = vim.fn.getcwd()
  local task_file = project_root .. "/current_tasks.md"

  -- Step 1: Read completed tasks from current_tasks.md
  local completed_tasks = {}
  local file = io.open(task_file, "r")
  if file then
    for line in file:lines() do
      local task_text = line:match("^%- %[Xx%] (.*)")
      if task_text then
        completed_tasks[task_text] = true
      end
    end
    file:close()
  end

  -- Step 2: Search and update matching tasks in other files
  for task_text, _ in pairs(completed_tasks) do
    local grep_cmd = "grep -rl --include='*.md' " ..
        vim.fn.shellescape(task_text) .. " " .. project_root .. " | grep -v 'current_tasks.md'"
    local handle = io.popen(grep_cmd)
    if handle then
      for filename in handle:lines() do
        local modified = false
        local lines = {}
        local f = io.open(filename, "r")
        if f then
          for line in f:lines() do
            local pattern = "^%- %[ %] " .. escape_lua_pattern(task_text)
            if line:match(pattern) then
              table.insert(lines, "- [X] " .. task_text)
              modified = true
            else
              table.insert(lines, line)
            end
          end
          f:close()
        end

        if modified then
          local wf = io.open(filename, "w")
          if wf then
            for _, l in ipairs(lines) do
              wf:write(l .. "\n")
            end
            wf:close()
            vim.notify("Updated completed task in: " .. filename, vim.log.levels.INFO)
          end
        end
      end
      handle:close()
    end
  end

  -- Step 3: Rebuild the current task list
  M.write_tasks()
end

return M
