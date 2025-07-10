-- Adjust Lua's module path so it can find `taskscanner` in your plugin
package.path = package.path .. ";./lua/?.lua;./lua/?/init.lua"

local write = require("taskscanner.write")

describe("write_tasks", function()
  local notes_dir = "tests/fixtures"

  before_each(function()
    -- Mock the notes directory
    require("configs.notes").notes_dir = notes_dir
  end)

  it("writes urgent and normal tasks to current_tasks.md", function()
    write.write_tasks()

    local output_file = notes_dir .. "/current_tasks.md"
    local file = io.open(output_file, "r")
    assert.is_not_nil(file, "Output file should exist")

    local content = file:read("*all")
    file:close()

    assert.is_true(content:find("## Urgent Tasks") ~= nil)
    assert.is_true(content:find("## Tasks") ~= nil)
    assert.is_true(content:find("#urgent") ~= nil)
    assert.is_true(content:find("#task") ~= nil)
  end)

  it("handles no tasks gracefully", function()
    -- Clear the fixture files to simulate no tasks
    os.remove(notes_dir .. "/task1.md")
    os.remove(notes_dir .. "/task2.md")

    write.write_tasks()

    local output_file = notes_dir .. "/current_tasks.md"
    local file = io.open(output_file, "r")
    assert.is_not_nil(file, "Output file should exist even with no tasks")

    local content = file:read("*all")
    file:close()

    assert.is_true(content:find("## Urgent Tasks") == nil)
    assert.is_true(content:find("## Tasks") == nil)
  end)
end)
