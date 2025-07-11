local M = {}
local util = require("taskscanner.util")

-- write function to add tasks to table from filepath

function M.add_tasks_to_table(files, filepath, notes_dir)
  if filepath then
    -- Convert relative to absolute path
    if not filepath:match("^/") then
      local cwd = assert(io.popen("pwd")):read("*l")
      filepath = cwd .. "/" .. filepath
    end

    -- Check if the file exists
    local f = io.open(filepath, "r")
    if f then
      f:close()
      table.insert(files, filepath)
      return
    else
      print("FILEPATH NOT FOUND, falling back to scanning notes_dir")
    end
  end

  -- Fallback: scan all markdown files in notes_dir
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

function M.write_section(lines, header, tasks)
  table.insert(lines, header)
  if #tasks > 0 then
    table.sort(tasks)
    for _, task in ipairs(tasks) do
      table.insert(lines, task)
    end
  end
  table.insert(lines, "") -- always add a blank line
end

function M.write_nested_tag(lines, tag, content)
  local flat_tasks = {}
  local subtags = {}

  for k, v in pairs(content) do
    if type(k) == "string" then
      table.insert(subtags, k)
    elseif type(k) == "number" then
      table.insert(flat_tasks, v)
    end
  end

  table.sort(subtags)

  M.write_section(lines, "## " .. tag, flat_tasks)

  for _, sub in ipairs(subtags) do
    M.write_section(lines, "### " .. sub, content[sub])
  end
end

function M.write_all_sections(lines, tasks_by_tag)
  local function write_tag_section(tag, content)
    if vim.tbl_islist(content) then
      M.write_section(lines, "## " .. tag, content)
    else
      local flat_tasks = {}
      local subtags = {}

      for k, v in pairs(content) do
        if type(k) == "string" then
          table.insert(subtags, k)
        elseif type(k) == "number" then
          table.insert(flat_tasks, v)
        end
      end

      table.sort(subtags)

      if #flat_tasks > 0 then
        M.write_section(lines, "## " .. tag, flat_tasks)
      else
        table.insert(lines, "## " .. tag)
        table.insert(lines, "")
      end

      for _, sub in ipairs(subtags) do
        M.write_section(lines, "### " .. sub, content[sub])
      end
    end
  end

  -- Write #urgent first if present
  if tasks_by_tag["urgent"] then
    write_tag_section("urgent", tasks_by_tag["urgent"])
  end

  -- Write all other tags (excluding "urgent" and "Untagged") sorted
  local tags = {}
  for tag in pairs(tasks_by_tag) do
    if tag ~= "urgent" and tag ~= "Untagged" then
      table.insert(tags, tag)
    end
  end
  table.sort(tags)

  for _, tag in ipairs(tags) do
    write_tag_section(tag, tasks_by_tag[tag])
  end

  -- Write untagged last
  if tasks_by_tag["Untagged"] then
    write_tag_section("Untagged", tasks_by_tag["Untagged"])
  end
end

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

  M.add_tasks_to_table(files, filepath, notes_dir)

  for _, file in ipairs(files) do
    util.process_file(file, seen, completed, task_sources, tasks_by_tag)
  end
  -- Write the sorted output
  local lines = {}
  M.write_all_sections(lines, tasks_by_tag)

  local file = io.open(output_file, "w")
  if file then
    for i, line in ipairs(lines) do
      if i < #lines then
        file:write(line .. "\n")
      else
        file:write(line) -- no newline after last non-empty line
      end
    end
    file:close()

    vim.notify("taskscanner: tasks written to " .. output_file, vim.log.levels.INFO)
  else
    vim.notify("taskscanner: failed to open " .. output_file, vim.log.levels.ERROR)
  end
end

return M
