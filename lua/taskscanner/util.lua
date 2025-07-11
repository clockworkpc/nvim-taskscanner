local M = {}

function M.normalize_task_line(line)
  -- Strip checkbox
  local body = line:gsub("^%- %[.?.%] ?", "")
  -- Strip tags like #task, #urgent
  body = body:gsub("#%w+", "")
  -- Strip emoji/punctuation, normalize whitespace
  body = body:gsub("[%p%c]", ""):gsub("%s+", " "):lower():match("^%s*(.-)%s*$")
  return body
end

local function pascal_case(tag)
  return tag:gsub("#", ""):gsub("_(%l)", function(c)
    return c:upper()
  end):gsub("^%l", string.upper)
end

local function is_dir(path)
  local stat = vim.loop.fs_stat(path)
  return stat and stat.type == "directory"
end

return M
