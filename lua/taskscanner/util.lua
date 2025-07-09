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

return M
