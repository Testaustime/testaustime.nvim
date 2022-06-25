# Testaustime.nvim

The testaustime plugin for Neovim, written in Lua this time

## Installation

You can use your favourite plugin manager, here's an example for [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use { 'testaustime/testaustime.nvim', requires = { 'nvim-lua/plenary.nvim' } }
```

These options are available
```lua
vim.g.testaustime_url = "https://your.testaustimeinstance.com" -- required
vim.g.testaustime_token = "YourVerySecretTestaustimeAuthenticationToken" --required
vim.g.testaustime_useragent = "FunnyUserAgentForBackendHostToLaughAt"
vim.g.testaustime_ignore = "packer netrw help qf TelescopePrompt gitcommit" -- A space-separated list of ignored filetypes
vim.g.testaustime_editor_name = "Neovim"
```
