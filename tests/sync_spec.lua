package.loaded["configs.notes"] = {
  notes_dir = "tests/fixtures",
}

---@diagnostic disable: undefined-global, undefined-field
require("tests.test_helper")

local sync = require("taskscanner.sync")
local notes_dir = "tests/fixtures"
local task_file = notes_dir .. "/current_tasks.md"
local test_file3 = notes_dir .. "/file3.md"
local test_file4 = notes_dir .. "/file4.md"

local function write_file(path, contents)
  local f = assert(io.open(path, "w"))
  f:write(table.concat(contents, "\n"))
  f:close()
end

describe("sync_completed_tasks", function()
  before_each(function()
    -- Reset test files
    write_file(task_file, {
      "- [X] review code changes #task",
      "- [ ] this should be ignored",
    })

    write_file(test_file3, {
      "- [ ] review code changes #task",
      "- [ ] some other task #task",
    })

    write_file(test_file4, {
      "- [ ] another task #task",
    })
  end)

  it("marks completed tasks in matching files", function()
    sync.sync_completed_tasks()

    local f = assert(io.open(test_file3, "r"))
    local content = f:read("*a")
    f:close()

    assert(content:match("- %[X%] review code changes #task"))
    assert(content:match("- %[ %] some other task #task"))
  end)

  it("does not change unrelated files", function()
    sync.sync_completed_tasks()

    local f = assert(io.open(test_file4, "r"))
    local content = f:read("*a")
    f:close()

    assert(content:match("- %[ %] another task #task"))
    assert.is_nil(content:match("%[X%]"))
  end)

  it("does not modify file if no match", function()
    write_file(test_file3, {
      "- [ ] not completed yet #task",
    })
    sync.sync_completed_tasks()

    local f = assert(io.open(test_file3, "r"))
    local content = f:read("*a")
    f:close()

    assert(content:match("- %[ %] not completed yet #task"))
  end)

  it("notifies if current_tasks.md is missing", function()
    os.remove(task_file)
    local spy = spy.new(function() end)
    vim.notify = spy
    sync.sync_completed_tasks()
    assert.spy(spy).was_called_with(match.is_string(), vim.log.levels.ERROR)
  end)
end)
