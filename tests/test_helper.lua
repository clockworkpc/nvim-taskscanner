---@diagnostic disable: undefined-global, unused-local, cast-local-type, assign-type-mismatch

-- Ensure local plugin source is discoverable by busted
do
  local project_lua_path = "./lua/?.lua;./lua/?/init.lua"
  if not package.path:find(project_lua_path, 1, true) then
    package.path = package.path .. ";" .. project_lua_path
  end
end

-- 🧱 Minimal vim global mock
_G.vim = {
  loop = {
    os_getenv = os.getenv,
    cwd = function()
      return vim._mock_cwd or os.getenv("PWD") or "."
    end,
    fs_stat = function(path)
      -- Customize per test
      if path == "tests/fixtures" then
        return { type = "directory" }
      end
      return nil
    end,
  },
  notify = function(msg, level)
    -- You can log if needed
    -- print("vim.notify:", msg, level)
  end,
  log = {
    levels = {
      ERROR = "ERROR",
      INFO = "INFO",
      DEBUG = "DEBUG",
    },
  },
  trim = function(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
  end,
  list_extend = function(dst, src)
    for _, v in ipairs(src) do
      table.insert(dst, v)
    end
  end,
  tbl_islist = function(t)
    if type(t) ~= "table" then return false end
    local i = 0
    for k in pairs(t) do
      i = i + 1
      if k ~= i then return false end
    end
    return true
  end,
  tbl_keys = function(t)
    local keys = {}
    for k, _ in pairs(t) do
      table.insert(keys, k)
    end
    return keys
  end,
  split = function(str, sep, opts)
    local result = {}
    sep = sep or "\n"
    local pattern = "([^" .. sep .. "]*)"

    for part in str:gmatch(pattern .. sep) do
      table.insert(result, part)
    end

    -- Check if the string ends with the separator
    if str:sub(- #sep) == sep then
      table.insert(result, "")
    end

    return result
  end
}

-- 🧼 Reset modules between tests
_G.reset_taskscanner_modules = function(notes_dir)
  -- Clear Lua module cache
  package.loaded["taskscanner.write"] = nil
  package.loaded["taskscanner.util"] = nil
  package.loaded["configs.notes"] = { notes_dir = notes_dir }

  -- Return required modules fresh
  return {
    write = require("taskscanner.write"),
    config = require("configs.notes"),
  }
end

-- tests/test_helper.lua

---@class BustedAssert
---@field same fun(a: any, b: any): nil
---@field is_table fun(v: any): nil
---@field is_true fun(v: any): nil
---@field is_nil fun(v: any): nil
---@field are BustedAssertAre

---@class BustedAssertAre
---@field same fun(a: any, b: any): nil

---@diagnostic disable: undefined-global, unused-local, cast-local-type, assign-type-mismatch
local assert = assert
