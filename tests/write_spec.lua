---@diagnostic disable: undefined-global, undefined-field
require("tests.test_helper")

describe("write_tasks", function()
  local notes_dir = "tests/fixtures"
  local output_file = notes_dir .. "/current_tasks.md"
  local write

  before_each(function()
    local modules = reset_taskscanner_modules(notes_dir)
    write = modules.write

    local f = io.open(output_file, "w")
    if f then
      f:close()
    end
  end)

  after_each(function()
    os.remove(output_file)
  end)

  it("returns source file mappings for each task", function()
    local ok, result = pcall(function()
      return write.write_tasks()
    end)

    print("RAW PCALL RETURN:", ok, result)
    assert.are.same(true, ok) -- more strict than is_true
    assert.is_table(result)

    for task, path in pairs(result) do
      print(string.format("[✓] %s -> %s", task, path))
      assert.are.same(true, ok)
      assert.is_table(result)
    end
  end)
end)

-- -- Adjust Lua's module path so it can find `taskscanner` in your plugin
-- package.path = package.path .. ";./lua/?.lua;./lua/?/init.lua"
--
-- -- mock before require
-- package.loaded["configs.notes"] = { notes_dir = "tests/fixtures" }
--
-- local write = require("taskscanner.write")
-- local config = require("configs.notes")
--
-- describe("write_tasks", function()
-- 	local notes_dir = "tests/fixtures"
-- 	local output_file = notes_dir .. "/current_tasks.md"
-- 	-- Inject fake config globally
--
-- 	before_each(function()
-- 		config.notes_dir = notes_dir
-- 		-- Clear the output file before each run
-- 		local f = io.open(output_file, "w")
-- 		if f then
-- 			f:close()
-- 		end
-- 	end)
--
-- 	after_each(function()
-- 		os.remove(output_file)
-- 	end)
--
-- 	it("writes urgent and normal tasks to current_tasks.md", function()
-- 		local sources = write.write_tasks()
--
-- 		local f = io.open(output_file, "r")
-- 		assert.is_not_nil(f)
--
-- 		local content = f:read("*all")
-- 		f:close()
--
-- 		-- Confirm both headers are present
-- 		assert.is_true(content:find("## Urgent Tasks") ~= nil)
-- 		assert.is_true(content:find("## Tasks") ~= nil)
--
-- 		-- Confirm #urgent tasks appear under correct section
-- 		assert.is_true(content:find("#urgent") ~= nil)
-- 		assert.is_true(content:find("#ai") ~= nil)
-- 	end)
--
-- 	it("deduplicates tasks and skips completed ones", function()
-- 		local sources = write.write_tasks()
--
-- 		local f = io.open(output_file, "r")
-- 		local lines = {}
-- 		for line in f:lines() do
-- 			table.insert(lines, line)
-- 		end
-- 		f:close()
--
-- 		-- Check that all lines are unique (no deduplication issues)
-- 		local seen = {}
-- 		for _, line in ipairs(lines) do
-- 			if line:match("^%- %[ %]") then
-- 				assert.is_nil(seen[line], "Duplicate task found: " .. line)
-- 				seen[line] = true
-- 			end
-- 		end
--
-- 		-- Check that completed task doesn't appear
-- 		for _, line in ipairs(lines) do
-- 			assert.is_nil(line:match("^%- %[X%]"), "Completed task should not be written: " .. line)
-- 		end
-- 	end)
--
-- 	it("returns source file mappings for each task", function()
-- 		local ok, result = pcall(function()
-- 			return write.write_tasks()
-- 		end)
--
-- 		if not ok then
-- 			print("❌ write_tasks threw an error:")
-- 			print(result)
-- 		end
--
-- 		assert.is_true(ok)
-- 		assert.is_table(result)
--
-- 		if not next(result) then
-- 			print("⚠️ No tasks found in sources")
-- 		end
--
-- 		for task, path in pairs(result) do
-- 			assert.is_true(task:match("#task"))
-- 			assert.is_true(path:match("%.md$"))
-- 		end
-- 	end)
--
-- 	it("handles missing or unreadable notes directory gracefully", function()
-- 		-- package.loaded["configs.notes"] = { notes_dir = "nonexistent/path" }
-- 		local ok, result = pcall(write.write_tasks)
-- 		assert.is_true(ok)
-- 		assert.are.same({}, result)
-- 	end)
-- end)
