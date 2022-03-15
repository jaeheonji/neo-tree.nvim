# Neo-tree.nvim

Neo-tree is a Neovim plugin to browse the file system and other tree like
structures in whatever style suits you, including sidebars, floating windows,
netrw split style, or all of them at once!

![Neo-tree file system](https://github.com/nvim-neo-tree/resources/raw/main/images/Neo-tree-2.0-with-git-symbols.png)

### Breaking Changes BAD :bomb: :imp:

The biggest and most important feature of Neo-tree is that we will never
knowingly push a breaking change and interrupt your day. Bugs happen, but
breaking changes can always be avoided. When breaking changes are needed, there
will be a new branch that you can opt into, when it is a good time for you.

See [What is a Breaking Change?](#what-is-a-breaking-change) for details.


### User Experience GOOD :slightly_smiling_face: :thumbsup:

Aside from being polite about breaking changes, Neo-tree is also focused on the
little details of user experience. Everything should work exactly as you would
expect a sidebar to work without all of the glitchy behavior that is normally
accepted in (neo)vim sidebars. I can't stand glitchy behavior, and neither
should you!

- Neo-tree won't let other buffers take over it's window.
- Neo-tree won't leave it's window scrolled to the last line when there is
  plenty of room to display the whole tree.
- Neo-tree does not need to be manually refreshed (set `use_libuv_file_watcher=true`)
- Neo-tree can intelligently follow the current file (set `follow_current_file=true`)
- Neo-tree is thoughtful about maintaining or setting focus on the right node
- Neo-tree windows in different tabs are completely separate
- `respect_gitignore` actually works!

Neo-tree is smooth, efficient, stable, and pays attention to the little details.
If you find anything janky, wanky, broken, or unintuitive, please open an issue
so we can fix it.


## Quickstart

Example for packer:
```lua
use {
  "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    requires = { 
      "nvim-lua/plenary.nvim",
      "kyazdani42/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim" 
    },
    config = function ()
      -- See ":help neo-tree-highlights" for a list of available highlight groups
      vim.cmd([[
        let g:neo_tree_remove_legacy_commands = 1
        hi link NeoTreeDirectoryName Directory
        hi link NeoTreeDirectoryIcon NeoTreeDirectoryName
      ]])

      require("neo-tree").setup({
        close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,
        default_component_configs = {
          indent = {
            indent_size = 2,
            padding = 1, -- extra padding on left hand side
            with_markers = true,
            indent_marker = "│",
            last_indent_marker = "└",
            highlight = "NeoTreeIndentMarker",
          },
          icon = {
            folder_closed = "",
            folder_open = "",
            folder_empty = "ﰊ",
            default = "*",
          },
          name = {
            trailing_slash = false,
            use_git_status_colors = true,
          },
          git_status = {
            symbols = {
              -- Change type
              added     = "✚",
              deleted   = "✖",
              modified  = "",
              renamed   = "",
              -- Status type
              untracked = "",
              ignored   = "",
              unstaged  = "",
              staged    = "",
              conflict  = "",
            }
          },
        },
        filesystem = {
          filtered_items = {
            visible = false, -- when true, they will just be displayed differently than normal items
            hide_dotfiles = true,
            hide_gitignored = true,
            hide_by_name = {
              ".DS_Store",
              "thumbs.db"
              --"node_modules"
            },
            never_show = { -- remains hidden even if visible is toggled to true
              --".DS_Store",
              --"thumbs.db"
            },
          },
          follow_current_file = true, -- This will find and focus the file in the active buffer every
                                       -- time the current file is changed while the tree is open.
          use_libuv_file_watcher = true, -- This will use the OS level file watchers
                                          -- to detect changes instead of relying on nvim autocmd events.
          hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
                                                  -- in whatever position is specified in window.position
                                -- "open_current",  -- netrw disabled, opening a directory opens within the
                                                  -- window like netrw would, regardless of window.position
                                -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
          window = {
            position = "left",
            width = 40,
            mappings = {
              ["<2-LeftMouse>"] = "open",
              ["<cr>"] = "open",
              ["S"] = "open_split",
              ["s"] = "open_vsplit",
              ["C"] = "close_node",
              ["<bs>"] = "navigate_up",
              ["."] = "set_root",
              ["H"] = "toggle_hidden",
              ["I"] = "toggle_gitignore",
              ["R"] = "refresh",
              ["/"] = "fuzzy_finder",
              --["/"] = "filter_as_you_type", -- this was the default until v1.28
              --["/"] = "none" -- Assigning a key to "none" will remove the default mapping
              ["f"] = "filter_on_submit",
              ["<c-x>"] = "clear_filter",
              ["a"] = "add",
              ["d"] = "delete",
              ["r"] = "rename",
              ["c"] = "copy_to_clipboard",
              ["x"] = "cut_to_clipboard",
              ["p"] = "paste_from_clipboard",
              ["m"] = "move", -- takes text input for destination
              ["q"] = "close_window",
            }
          }
        },
        buffers = {
          show_unloaded = true,
          window = {
            position = "left",
            mappings = {
              ["<2-LeftMouse>"] = "open",
              ["<cr>"] = "open",
              ["S"] = "open_split",
              ["s"] = "open_vsplit",
              ["<bs>"] = "navigate_up",
              ["."] = "set_root",
              ["R"] = "refresh",
              ["a"] = "add",
              ["d"] = "delete",
              ["r"] = "rename",
              ["c"] = "copy_to_clipboard",
              ["x"] = "cut_to_clipboard",
              ["p"] = "paste_from_clipboard",
              ["bd"] = "buffer_delete",
            }
          },
        },
        git_status = {
          window = {
            position = "float",
            mappings = {
              ["<2-LeftMouse>"] = "open",
              ["<cr>"] = "open",
              ["S"] = "open_split",
              ["s"] = "open_vsplit",
              ["C"] = "close_node",
              ["R"] = "refresh",
              ["d"] = "delete",
              ["r"] = "rename",
              ["c"] = "copy_to_clipboard",
              ["x"] = "cut_to_clipboard",
              ["p"] = "paste_from_clipboard",
              ["A"]  = "git_add_all",
              ["gu"] = "git_unstage_file",
              ["ga"] = "git_add_file",
              ["gr"] = "git_revert_file",
              ["gc"] = "git_commit",
              ["gp"] = "git_push",
              ["gg"] = "git_commit_and_push",
            }
          }
        }
      })
      vim.cmd([[nnoremap \ :Neotree reveal<cr>]])
    end
}
```

_The above configuration is not everything that can be changed, it's just the
parts you might want to change first._


See `:h neo-tree` for full documentation. You can also preview that online at
[doc/neo-tree.txt](doc/neo-tree.txt), although it's best viewed within vim.


### Config Options

To see all of the default config options with commentary, you can view it online
at [lua/neo-tree/defaults.lua](lua/neo-tree/defaults.lua). You can also paste it
into your config after installing Neo-tree by running `:lua require("neo-tree").paste_default_config()`,
which will paste the default config as a `config` table into the current buffer.
You can then change what you want in the pasted `config` table and pass it to
`require("neo-tree").setup(config)`


### Commands (for sidebar and float postions)


Neo-tree does not define any default keybindings for nvim. The suggested
keybindings are:

```
    nnoremap / :Neotree toggle current reveal_force_cwd<cr>
    nnoremap | :Neotree reveal<cr>
    nnoremap gd :Neotree float reveal_file=<cfile> reveal_force_cwd<cr>
    nnoremap <leader>b :Neotree toggle show buffers right<cr>
    nnoremap <leader>s :Neotree float git_status<cr>
```

See `:h neo-tree-commands` for details and a full listing of available arguments.


### Netrw Hijack

```
:edit .
:[v]split .
```

If `"filesystem.window.position"` is set to `"current"`, or if you have specified
`filesystem.netrw_hijack_behavior = "open_current"`, then any command
that would open a directory will open neo-tree in the specified window.


## Sources

Neo-tree is built on the idea of supporting various sources. Sources are
basically interface implementations whose job it is to provide a list of
hierachical items to be rendered, along with commands that are appropriate to
those items.

### filesystem
The default source is `filesystem`, which displays your files and folders. This
is the default source in commands when none is specified.

This source can be used to:
- Browse the filesystem
- Control the current working directory of nvim
- Add/Copy/Delete/Move/Rename files and directories
- Search the filesystem
- Monitor git status and lsp diagnostics for the current working directory

### buffers
![Neo-tree buffers](https://github.com/nvim-neo-tree/resources/raw/main/images/Neo-tree-buffers.png)

Another available source is `buffers`, which displays your open buffers. This is
the same list you would see from `:ls`. To show with the `buffers` list, use:

```
:Neotree buffers
```


### git_status
This view take the results of the `git status` command and display them in a
tree. It includes commands for adding, unstaging, reverting, and committing.

The screenshot below shows the result of `:Neotree float git_status` while the 
filesystem is open in a sidebar:

![Neo-tree git_status](https://github.com/nvim-neo-tree/resources/raw/main/images/Neo-tree-git_status.png)


## Configuration and Customization

This is designed to be flexible. The way that is acheived is by making
everything a function, or a string that identifies a built-in function. All of the
built-in functions can be replaced with your own implementation, or you can 
add new ones.

Each node in the tree is created from the renderer specified for the given node
type, and each renderer is a list of component configs to be rendered in order. 
Each component is a function, either built-in or specified in your config. Those
functions simply return the text and highlight group for the component.

Additionally, there is an events system that you can hook into. If you want to
show some new data point related to your files, gather it in the
`before_render` event, create a component to display it, and reference that
component in the renderer for the `file` and/or `directory` type.

Details on how to configure everything is in the help file at `:h
neo-tree-configuration` or online at
[neo-tree.txt](https://github.com/nvim-neo-tree/neo-tree.nvim/blob/main/doc/neo-tree.txt)

Recipes for customizations can be found on the [wiki](wiki). Recipes include
things like adding a component to show the
[Harpoon](https://github.com/ThePrimeagen/harpoon) index for files, or
responding to the `"file_opened"` event to auto clear the search when you open a
file.


## Why?

There are many tree plugins for (neo)vim, so why make another one? Well, I
wanted something that was:

1. Easy to maintain and enhance.
2. Stable.
3. Easy to customize.

### Easy to maintain and enhance

This plugin is designed to grow and be flexible. This is accomplished by making
the code as decoupled and functional as possible. Hopefully new contributors
will find it easy to work with.

One big difference between this plugin and the ones that came before it, which
is also what finally pushed me over the edge into making a new plugin, is that
we now have libraries to build upon that did not exist when other tree plugins
were created. Most notably, [nui.nvim](https://github.com/MunifTanjim/nui.nvim)
and [plenary.nvm](https://github.com/nvim-lua/plenary.nvim). Building upon
shared libraries will go a long way in making neo-tree easy to maintain.

### Stable

This project will have releases and release tags that follow a simplified
Semantic Versioning scheme. The quickstart instructions will always refer to
the latest stable major version. Following the **main** branch is for
contributors and those that always want bleeding edge. There will be branches
for **v1.x**, **v2.x**, etc which will receive updates after a short testing
period in **main**. You should be safe to follow those branches and be sure
your tree won't break in an update. There will also be tags for each release
pushed to those branches named **v1.1**, **v1.2**, etc. If stability is
critical to you, or a bug accidentally make it into **v1.x**, you can use those
tags instead. It's possible we may backport bug fixes to those tags, but no
garauntees on that.

There will never be a breaking change within a major version (1.x, 2.x, etc.) If
a breaking change is needed, there will be depracation warnings in the prior
major version, and the breaking change will happen in the next major version.

### Easy to Customize

Neo-tree follows in the spirit of plugins like
[lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) and
[nvim-cokeline](https://github.com/noib3/nvim-cokeline). Everything will be
configurable and take either strings, tables, or functions. You can take sane
defaults or build your tree items from scratch. There should be the ability to
add any features you can think of through existing hooks in the setup function.

## What is a Breaking Change?

As of v1.30, a breaking change is defined as anything that _changes_ existing:

- vim commands (`:NeoTreeShow`, `:NeoTreeReveal`, etc)
- configuration options that are passed into the `setup()` function
- `NeoTree*` highlight groups
- lua functions exported in the following modules that are not prefixed with `_`:
    * `neo-tree`
    * `neo-tree.events`
    * `neo-tree.sources.manager`
    * `neo-tree.sources.*` (init.lua files)
    * `neo-tree.sources.*.commands`
    * `neo-tree.ui.renderer`
    * `neo-tree.utils`

If there are other functions you would like to use that are not yet considered
part of the public API, please open an issue so we can discuss it.

## Contributions

Contributions are encouraged. Please see [CONTRIBUTING](CONTRIBUTING.md) for more details.

## Acknowledgements

This project relies upon these two excellent libraries:
- [nui.nvim](https://github.com/MunifTanjim/nui.nvim) for all UI components, including the tree!
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) for backend utilities, such as scanning the filesystem.

The design is heavily inspired by these excellent plugins:
- [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)
- [nvim-cokeline](https://github.com/noib3/nvim-cokeline)

Everything I know about writing a tree control in lua, I learned from:
- [nvim-tree.lua](https://github.com/kyazdani42/nvim-tree.lua)
