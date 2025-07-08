# nvim-taskscanner

A minimal Neovim plugin that scans your Markdown notes for `#task` entries and writes them into a `current_tasks.md` file in the root of your workspace.

![nvim-taskrunner](https://github.com/user-attachments/assets/d1b56650-f145-476f-b206-703a3d37884d)

## ✨ Features

* Scans all `.md` files in your notes directory
* Finds lines that:

  * Contain `#task`
  * Begin with `- [ ]` (unchecked tasks only)
* Outputs them to a deduplicated list in `current_tasks.md`
* Optionally syncs checked-off tasks back to their source files

## 📦 Installation

### lazy.nvim

```lua
{
  "clockworkpc/nvim-taskscanner",
  config = function()
    require("taskscanner").setup({
      notes_dir = "~/Dropbox/Documents", -- Optional: default is this path
    })

    vim.api.nvim_create_user_command("WriteTasks", function()
      require("taskscanner").write_tasks()
    end, {})
  end,
}
```

### packer.nvim

```lua
use {
  "clockworkpc/nvim-taskscanner",
  config = function()
    require("taskscanner").setup({
      notes_dir = "~/Dropbox/Documents", -- Optional: customize your notes path
    })

    vim.api.nvim_create_user_command("WriteTasks", function()
      require("taskscanner").write_tasks()
    end, {})
  end
}
```

## 🛠 Configuration

You can customize the base directory where your Markdown notes live by passing a `notes_dir` option to `setup()`:

```lua
require("taskscanner").setup({
  notes_dir = "~/my/notes/folder", -- Will be created if it doesn't exist
})
```

If `notes_dir` is not set, the plugin defaults to `~/Dropbox/Documents`.

## 🧠 Usage

```vim
:WriteTasks
```

This generates (or updates) a `current_tasks.md` file in your `notes_dir` with all matching unchecked `#task` entries.

## 📁 Example

Scattered input:

```markdown
- [ ] #task Read Chapter 3
- [ ] #task Fix nvim config
```

Output:

```markdown
- [ ] #task Read Chapter 3
- [ ] #task Fix nvim config
```

## 🔒 Excludes

* Completed tasks (`- [x]`)
* The `current_tasks.md` file itself (to avoid recursion)

---

PRs and improvements welcome.
**taskscanner** – simple task aggregation for your Markdown notes.

