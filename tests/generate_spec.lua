-- Adjust Lua's module path so it can find `taskscanner` in your plugin
package.path = package.path .. ";./lua/?.lua;./lua/?/init.lua"

local generate = require("taskscanner.generate")

describe("generate_tasks", function()
  local notes_dir = "tests/fixtures"

  it("finds all #task entries", function()
    local tasks = generate.generate_tasks(notes_dir)
    print("Found " .. #tasks .. " tasks")
    assert.is_true(#tasks == 5)

    for _, task in ipairs(tasks) do
      assert.is_true(task:match("^%- %[ %] #task") ~= nil)
    end
  end)

  it("filters tasks by tag #urgent", function()
    local tasks = generate.generate_tasks(notes_dir, "#urgent")
    assert.is_true(#tasks == 2)
    for _, task in ipairs(tasks) do
      assert.is_true(task:find("#urgent", 1, true) ~= nil)
    end
  end)

  it("filters tasks by tag #ai", function()
    local tasks = generate.generate_tasks(notes_dir, "#ai")
    assert.is_true(#tasks == 1)
    for _, task in ipairs(tasks) do
      assert.is_true(task:find("#ai", 1, true) ~= nil)
    end
  end)


  it("returns empty list for unmatched tag", function()
    local tasks = generate.generate_tasks(notes_dir, "#nonexistent")
    assert.are.same({}, tasks)
  end)
end)
