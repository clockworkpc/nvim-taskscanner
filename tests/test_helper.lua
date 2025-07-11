---@diagnostic disable: undefined-global, unused-local, cast-local-type, assign-type-mismatch
-- 🧱 Minimal vim global mock
_G.vim = {
  loop = {
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
    print("vim.notify:", msg, level)
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
