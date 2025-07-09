local M = {}
local util = require("taskscanner.util")

function M.sync_completed_tasks(task_sources)
  local notes_config = require("configs.notes")
  local notes_dir = notes_config.notes_dir:gsub("^~", os.getenv("HOME") or "")
  local task_file = notes_dir .. "/current_tasks.md"

  local completed_tasks = {}
  local f = io.open(task_file, "r")
  if f then
    for line in f:lines() do
      if line:match("^%- %[X%] ") then
        local norm = util.normalize_task_line(line)
        completed_tasks[norm] = true

        local source = task_sources[norm]
        if source then
          local updated_lines = {}
          local changed = false

          local rf = io.open(source, "r")
          if rf then
            for orig_line in rf:lines() do
              local match = util.normalize_task_line(orig_line)
              if completed_tasks[match] then
                table.insert(updated_lines, orig_line:gsub("^%- %[ %]", "- [X]"))
                changed = true
              else
                table.insert(updated_lines, orig_line)
              end
            end
            rf:close()
          end

          if changed then
            local wf = io.open(source, "w")
            if wf then
              for _, l in ipairs(updated_lines) do
                wf:write(l .. "\n")
              end
              wf:close()
              vim.notify("✔ Updated: " .. source, vim.log.levels.INFO)
            else
              vim.notify("✘ Failed to write to: " .. source, vim.log.levels.ERROR)
            end
          end
        end
      end
    end
    f:close()
  else
    vim.notify("Failed to read current_tasks.md", vim.log.levels.ERROR)
  end

  return completed_tasks
end

return M
