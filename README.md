# nvim-taskscanner

A minimal Neovim plugin that scans your Markdown notes for `#task` entries and writes them into a `current_tasks.md` file in the root of your workspace.

![nvim-taskrunner](https://github.com/user-attachments/assets/d1b56650-f145-476f-b206-703a3d37884d)

## ✨ Features
- Scans all `.md` files in your current working directory
- Finds lines that:
  - Contain `#task`
  - Begin with `- [ ]` (unchecked tasks only)
- Outputs them to a deduplicated list in `current_tasks.md`

## 📦 Installation

### lazy.nvim
```lua
{
  "clockworkpc/nvim-taskscanner",
  config = function()
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
    vim.api.nvim_create_user_command("WriteTasks", function()
      require("taskscanner").write_tasks()
    end, {})
  end
}
```

## 🧠 Usage
Run the command:

```vim
:WriteTasks
```

This will generate (or overwrite) a `current_tasks.md` file in your project directory with all matching unchecked `#task` entries.

## 📁 Example
Input from scattered files:
```markdown
- [ ] #task Read Chapter 3
- [ ] #task Fix nvim config
```

Output file:
```markdown
- [ ] #task Read Chapter 3
- [ ] #task Fix nvim config
```

## 🔒 Excludes
- Completed tasks (`- [x]`)
- The `current_tasks.md` file itself (to avoid self-referencing)

---
PRs and improvements welcome. taskscanner
