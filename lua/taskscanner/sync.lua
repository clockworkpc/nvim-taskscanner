local M = {}

function M.sync_completed_tasks(completed_tasks)
  local notes_config = require("configs.notes")
  local notes_dir = notes_config.notes_dir

  if not completed_tasks then
    completed_tasks = {}
    local f = io.open(notes_dir .. "/current_tasks.md", "r")
    if f then
      for line in f:lines() do
        local body = line:match("^%- %[X%] (.*)")
        if body then
          completed_tasks[body] = true
        end
      end
      f:close()
    else
      vim.notify("Failed to open current_tasks.md", vim.log.levels.ERROR)
      return
    end
  end

  local grep_cmd = "grep -rl --include='*.md' '#task' " .. notes_dir
  local handle = io.popen(grep_cmd)
  if not handle then
    vim.notify("Failed to run grep", vim.log.levels.ERROR)
    return
  end

  for filename in handle:lines() do
    local updated_lines, changed = {}, false

    local rf = io.open(filename, "r")
    if rf then
      for line in rf:lines() do
        local match = line:match("^%- %[ %] (.*#task.*)")
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
end

return M
