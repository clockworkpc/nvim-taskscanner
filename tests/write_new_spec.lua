---@diagnostic disable: undefined-global, undefined-field
require("tests.test_helper")

package.loaded["configs.notes"] = {
  notes_dir = "tests/fixtures",
}

local write_new = require("taskscanner.write_new")
local util = require("taskscanner.util")

local notes_dir = "tests/fixtures"
local output_file = notes_dir .. "/current_tasks.md"

local function write_file(path, lines)
  assert(type(lines) == "table", "lines must be a table of strings")
  local f = assert(io.open(path, "w"))
  f:write(table.concat(lines, "\n"))
  f:close()
end

local function read_file(path)
  local f = assert(io.open(path, "r"))
  local content = f:read("*a")
  f:close()
  return vim.split(content, "\n")
end

describe("write_new_tasks", function()
  before_each(function()
    -- Clean slate
    write_file(output_file, {})

    -- Sample task input
    write_file(notes_dir .. "/tasks1.md", {
      "- [ ] #task fix bug in module #work",
      "- [ ] #task refactor database #work #backend_team",
      "- [ ] #task buy groceries",            -- untagged
      "- [ ] #task prepare launch #urgent #pdi",
      "- [X] #task old completed task #work", -- should be ignored
    })
  end)

  it("writes structured tasks grouped by tags", function()
    write_new.write_new_tasks('tests/fixtures/tasks1.md')

    local lines = read_file(output_file)

    assert.same({
      "## Untagged",
      "- [ ] buy groceries",
      "",
      "## Urgent",
      "",
      "### Pdi",
      "- [ ] prepare launch",
      "",
      "## Work",
      "- [ ] fix bug in module",
      "",
      "### BackendTeam",
      "- [ ] refactor database",
      "",
    }, lines)
  end)

  it("omits completed tasks", function()
    write_file(notes_dir .. "/tasks2.md", {
      "- [X] #task do not show this #work",
      "- [ ] #task show this instead #work",
    })
    write_new.write_new_tasks()
    local lines = read_file(output_file)

    for _, line in ipairs(lines) do
      assert.not_equal("- [ ] do not show this", line)
    end

    -- for _, line in ipairs(lines) do
    --   assert.not_match(line, "do not show this")
    -- end
  end)

  it("sorts alphabetically within headers", function()
    write_file(notes_dir .. "/tasks3.md", {
      "- [ ] #task zzz item #dev",
      "- [ ] #task aaa item #dev",
    })
    write_new.write_new_tasks()
    local lines = read_file(output_file)

    local dev_start
    for i, line in ipairs(lines) do
      if line == "## Dev" then
        dev_start = i
        break
      end
    end

    assert.is_truthy(dev_start)
    assert.equal("- [ ] aaa item", lines[dev_start + 1])
    assert.equal("- [ ] zzz item", lines[dev_start + 2])
  end)
end)
