local M = {}

-- Default notes directory
M.notes_dir = vim.fn.expand(os.getenv("HOME") .. "/Dropbox/Documents")

-- Utility to check if path is a directory
local function is_dir(path)
  local stat = vim.loop.fs_stat(path)
  return stat and stat.type == "directory"
end

-- Setup function for plugin config
function M.setup(opts)
  local dir = vim.fn.expand(opts.notes_dir or M.notes_dir)

  if not is_dir(dir) then
    local ok, err = pcall(vim.fn.mkdir, dir, "p")
    if ok then
      vim.notify("taskscanner: created notes_dir: " .. dir, vim.log.levels.INFO)
    else
      vim.notify("taskscanner: failed to create notes_dir: " .. err, vim.log.levels.ERROR)
    end
  end

  M.notes_dir = dir
end

return M
