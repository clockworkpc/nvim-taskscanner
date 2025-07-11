local M = {}
local util = require("taskscanner.util")

function M.write_new_tasks(filepath)
  local notes_config = require("configs.notes")
  local notes_dir = notes_config.notes_dir:gsub("^~", os.getenv("HOME") or "")

  if not util.is_dir(notes_dir) then
    vim.notify("taskscanner: notes_dir does not exist: " .. notes_dir, vim.log.levels.ERROR)
    return {}
  end

  local output_file = notes_dir .. "/current_tasks.md"
  local task_sources = {}
  local seen = {}
  local completed = {}
  local tasks_by_tag = { Untagged = {} }

  local files = {}

  if filepath and vim.loop.fs_stat(filepath) then
    table.insert(files, filepath)
  else
    local handle = io.popen("find " .. notes_dir .. " -name '*.md' ! -name 'current_tasks.md'")
    if not handle then
      vim.notify("taskscanner: failed to scan notes dir", vim.log.levels.ERROR)
      return {}
    end
    for line in handle:lines() do
      table.insert(files, line)
    end
    handle:close()
  end

  for _, file in ipairs(files) do
    local f = io.open(file, "r")
    if f then
      for line in f:lines() do
        if line:match("^%- %[ %] #task") or line:match("^%- %[X%] #task") then
          local norm = util.normalize_task_line(line)
          if line:match("^%- %[X%]") then
            completed[norm] = true
          elseif not seen[norm] and not completed[norm] then
            seen[norm] = true
            task_sources[norm] = file

            -- Extract tags
            local tags = {}
            for tag in line:gmatch("#[%w_]+") do
              if tag ~= "#task" then
                table.insert(tags, tag)
              end
            end

            -- Clean task line
            local cleaned = line
                :gsub("#[%w_]+", "")
                :gsub("%s+", " ")
                :match("^%s*(.-)%s*$")

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
      f:close()
    end
  end

  -- [ existing section rendering logic goes here ]
  -- lines = ...
  -- write_section(...)
  -- io.open(output_file, "w") ...

  return task_sources
end
