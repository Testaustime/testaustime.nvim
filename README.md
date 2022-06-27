# Testaustime.nvim

The testaustime plugin for Neovim, written in Lua this time

## Installation

You can use your favourite plugin manager, here's an example for [packer.nvim](https://github.com/wbthomason/packer.nvim):
```lua
use {
    'testaustime/testaustime.nvim', requires = { 'nvim-lua/plenary.nvim' },
    config = function() require'testaustime'.setup({token = "yourtoken"}) end
}
```

Or you alternatively can simply use the plugin here then require and setup it elsewhere in your config:
```lua
use {
    'testaustime/testaustime.nvim', requires = { 'nvim-lua/plenary.nvim' },
}
```

## Configuration
These are all the available configuration options currently:
```lua
require'testaustime'.setup({
    token = "yourVerySecretTestaustimeAuthenticationToken", --required
    api_url = "https://your.testaustimeinstance.com",
    useragent = "FunnyUserAgentForBackendHostToLaughAt",
    ignored_filetypes = {"packer", "netrw", "help", "qf", "TelescopePrompt", "gitcommit"},
    editor_name = "Neovim",
})
```
