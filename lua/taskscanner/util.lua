local M = {}

function M.normalize_task_line(line)
  return line
      :gsub("^%- %[.?.%] ?", "") -- Strip checkbox
      :gsub("#%w+", "")          -- Remove tags
      :gsub("%s+", " ")          -- Normalize whitespace
      :lower()                   -- Case-insensitive
      :match("^%s*(.-)%s*$")     -- Trim edges
end

function M.pascal_case(tag)
  return tag:gsub("^#", "")        -- remove leading '#'
      :gsub("_(%w)", string.upper) -- _x → X
      :gsub("^%l", string.upper)   -- first char → uppercase
      :gsub("_(%w)", string.upper) -- do again in case double underscores
      :gsub("_", "")               -- finally remove leftover underscores
end

function M.is_dir(path)
  local stat = vim.loop.fs_stat(path)
  return stat and stat.type == "directory"
end

function M.extract_tags(line)
  local tags = {}
  for tag in line:gmatch("#[%w_]+") do
    if tag ~= "#task" then
      table.insert(tags, tag)
    end
  end
  return tags
end

function M.clean_task_line(line)
  return line
      :gsub("#[%w_]+", "")
      :gsub("%s+", " ")
      :match("^%s*(.-)%s*$")
end

function M.insert_task(tags, cleaned, tasks_by_tag)
  if #tags == 0 then
    table.insert(tasks_by_tag["Untagged"], cleaned)
  elseif #tags == 1 then
    local key = M.pascal_case(tags[1])
    tasks_by_tag[key] = tasks_by_tag[key] or {}
    table.insert(tasks_by_tag[key], cleaned)
  else
    local top = M.pascal_case(tags[1])
    local sub = M.pascal_case(tags[2])
    tasks_by_tag[top] = tasks_by_tag[top] or {}
    tasks_by_tag[top][sub] = tasks_by_tag[top][sub] or {}
    table.insert(tasks_by_tag[top][sub], cleaned)
  end
end

function M.process_file(file, seen, completed, task_sources, tasks_by_tag)
  local f = io.open(file, "r")
  if not f then return end

  for line in f:lines() do
    if line:match("^%- %[ %] #task") or line:match("^%- %[X%] #task") then
      local norm = M.normalize_task_line(line)

      if line:match("^%- %[X%]") then
        completed[norm] = true
      elseif not seen[norm] and not completed[norm] then
        seen[norm] = true
        task_sources[norm] = file

        local tags = M.extract_tags(line)
        local cleaned = M.clean_task_line(line)
        M.insert_task(tags, cleaned, tasks_by_tag)
      end
    end
  end

  f:close()
end

return M
