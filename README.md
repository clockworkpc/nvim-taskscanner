# nvim-taskscanner

A minimal Neovim plugin that scans your Markdown notes for `#task` entries and generates a deduplicated task list. Perfect for Obsidian-style workflows or plain Markdown task tracking.

![screenshot](https://github.com/user-attachments/assets/d1b56650-f145-476f-b206-703a3d37884d)

## ✨ Features

* Scans all `.md` files in your notes directory
* Finds lines that:

  * Start with `- [ ]` or `- [X]`
  * Include `#task` or other custom tags
* Generates a clean `current_tasks.md` file with deduplicated tasks
* Supports tag filtering (e.g., `#urgent`)
* Syncs completed tasks back to their original files
* Configurable and scriptable from Lua

## 📦 Installation

### Using `lazy.nvim`

```lua
{
  "clockworkpc/nvim-taskscanner",
  config = function()
    require("taskscanner").setup({
      notes_dir = "~/Dropbox/Documents", -- optional, defaults to this
    })

    vim.api.nvim_create_user_command("WriteTasks", function()
      require("taskscanner").write_tasks()
    end, {})

    vim.api.nvim_create_user_command("SyncCompletedTasks", function()
      require("taskscanner").sync_completed_tasks()
    end, {})
  end,
}
```

### Using `packer.nvim`

```lua
use {
  "clockworkpc/nvim-taskscanner",
  config = function()
    require("taskscanner").setup({
      notes_dir = "~/Dropbox/Documents"
    })

    vim.api.nvim_create_user_command("WriteTasks", function()
      require("taskscanner").write_tasks()
    end, {})

    vim.api.nvim_create_user_command("SyncCompletedTasks", function()
      require("taskscanner").sync_completed_tasks()
    end, {})
  end
}
```

## 🧠 Usage

Run the following commands inside Neovim:

* `:WriteTasks`
  Scans your notes and writes deduplicated tasks to `current_tasks.md`.

* `:SyncCompletedTasks`
  Scans `current_tasks.md` and syncs completed tasks (`- [X]`) back to their source files.

## 🛠 Configuration

You can set your `notes_dir` on setup. This directory will be recursively scanned for `.md` files.

```lua
require("taskscanner").setup({
  notes_dir = "~/my/markdown/notes",
})
```

## 🧪 Development Notes

Functions are modular and testable:

* `generate_tasks(notes_dir, tag)`
  Returns a filtered list of tasks by optional `tag` (e.g., `#urgent`).

* `write_tasks()`
  Writes all matching tasks to `current_tasks.md`.

* `sync_completed_tasks()`
  Marks completed tasks in their original files.

## 🗃 File Structure

```
plugin/
  taskscanner.lua       -- Autoload entrypoint
lua/taskscanner/
  init.lua              -- Setup + exports
  generate.lua          -- Task scanner and formatter
  write.lua             -- Writes task file
  sync.lua              -- Syncs completed tasks
  util.lua              -- Utility functions
```

## 📁 Example Task Format

```md
- [ ] fix bug in module #task #urgent
- [X] write documentation #task
```

## ✅ License
GPLv3
