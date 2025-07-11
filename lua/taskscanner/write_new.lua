local M = {}
local util = require("taskscanner.util")

-- local function pascal_case(tag)
--   return tag:gsub("#", ""):gsub("_(%l)", function(c)
--     return c:upper()
--   end):gsub("^%l", string.upper)
-- end

-- local function is_dir(path)
--   local stat = vim.loop.fs_stat(path)
--   return stat and stat.type == "directory"
-- end

function M.write_new_tasks()
  local notes_config = require("configs.notes")
  local notes_dir = notes_config.notes_dir:gsub("^~", os.getenv("HOME") or "")
  local output_file = notes_dir .. "/current_tasks.md"

  if not util.is_dir(notes_dir) then
    vim.notify("taskscanner: notes_dir does not exist: " .. notes_dir, vim.log.levels.ERROR)
    return {}
  end

  local tasks_by_tag = { Untagged = {} }
  local seen = {}
  local completed = {}

  local grep_cmd = "grep -r --include='*.md' '#task' " .. notes_dir .. " | grep -v 'current_tasks.md'"
  local handle = io.popen(grep_cmd)
  if not handle then
    vim.notify("taskscanner: failed to run grep", vim.log.levels.ERROR)
    return {}
  end

  for line in handle:lines() do
    local filename, content = line:match("^(.-):(.*)$")
    if filename and content then
      content = vim.trim(content)
      local is_completed = content:match("^%- %[X%]")
      local is_task = content:match("^%- %[ %] #task")
      if is_task then
        local norm = util.normalize_task_line(content)
        if is_completed then
          completed[norm] = true
        elseif not seen[norm] and not completed[norm] then
          seen[norm] = true

          -- Extract tags excluding #task
          local tags = {}
          for tag in content:gmatch("#%w+") do
            if tag ~= "#task" then
              table.insert(tags, tag)
            end
          end

          -- Strip tags from content
          local cleaned = content:gsub("#%w+", ""):gsub("%s+$", "")

          if #tags == 0 then
            table.insert(tasks_by_tag["Untagged"], cleaned)
          elseif #tags == 1 then
            local key = util.pascal_case(tags[1])
            tasks_by_tag[key] = tasks_by_tag[key] or {}
            table.insert(tasks_by_tag[key], cleaned)
          elseif #tags >= 2 then
            local top = util.pascal_case(tags[1])
            local sub = util.pascal_case(tags[2])
            tasks_by_tag[top] = tasks_by_tag[top] or {}
            tasks_by_tag[top][sub] = tasks_by_tag[top][sub] or {}
            table.insert(tasks_by_tag[top][sub], cleaned)
          end
        end
      end
    end
  end
  handle:close()

  -- Write the sorted output
  local lines = {}

  local function write_section(header, tasks)
    if #tasks > 0 then
      table.insert(lines, header)
      table.sort(tasks)
      for _, task in ipairs(tasks) do
        table.insert(lines, task)
      end
      table.insert(lines, "")
    end
  end

  -- Write untagged
  write_section("## Untagged", tasks_by_tag["Untagged"] or {})

  for tag, content in pairs(tasks_by_tag) do
    if tag ~= "Untagged" then
      if vim.tbl_islist(content) then
        write_section("## " .. tag, content)
      else
        local subtags = vim.tbl_keys(content)
        table.sort(subtags)
        table.insert(lines, "## " .. tag)
        for _, sub in ipairs(subtags) do
          write_section("### " .. sub, content[sub])
        end
      end
    end
  end

  local file = io.open(output_file, "w")
  if file then
    for _, line in ipairs(lines) do
      file:write(line .. "\n")
    end
    file:close()
    vim.notify("taskscanner: tasks written to " .. output_file, vim.log.levels.INFO)
  else
    vim.notify("taskscanner: failed to open " .. output_file, vim.log.levels.ERROR)
  end
end

return M
