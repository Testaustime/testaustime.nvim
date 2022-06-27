local M = {}

local Job = require("plenary.job")

local last_heartbeat = 0

local testaustime_ignore = {"packer", "netrw", "help", "qf", "TelescopePrompt", "gitcommit"}
local testaustime_url = "https://api.testaustime.fi"
local testaustime_token = ""
local testaustime_useragent = "testaustime.nvim"
local testaustime_editor_name = "Neovim"

---@return string
function git_root()
    local f = io.popen("git rev-parse --show-toplevel 2>/dev/null", 'r')
    if f == nil then
        return ""
    end
    local s = f:read('*l')
    if s == nil then
        return ""
    end
    f:close()
    return s
end

function sendheartbeat()
    local now = os.time()

    if now - last_heartbeat < 30 then
        return
    end

    local hb = getheartbeatdata()

    for _,ft in ipairs(testaustime_ignore) do
        if ft == hb.language then
            return
        end
    end

    last_heartbeat = now

    local url = testaustime_url .. "/activity/update"

    return Job:new({
        command = "curl",
        args = { "-sd", heartbeattojson(hb), "-H", "Content-Type: application/json", "-H",
            "Authorization: Bearer " .. testaustime_token, "-A", testaustime_useragent, url },
    }):start()
end

function sendflush()
    local url = testaustime_url .. "/activity/flush"

    return Job:new({
        command = "curl",
        args = { "-sX", "POST", "-H", "Authorization: Bearer " .. testaustime_token, "-A", testaustime_useragent, url }
    }):start()
end

---@return table
function getheartbeatdata()
    local git_root_name = git_root()
    local root = ""

    if git_root_name == "" then
        root = vim.fn.getcwd()
    else
        root = git_root_name
    end

    return {
        language = vim.bo.filetype,
        hostname = vim.fn.hostname(),
        editor_name = vim.g.testaustime_editor_name or "Neovim",
        project_name = root:match("/([^/]+)$")
    }
end

---@param hb table
---@return string
function heartbeattojson(hb)
    return string.format([[{"language":"%s","hostname":"%s","editor_name":"%s","project_name":"%s"}]],
        hb.language, hb.hostname, hb.editor_name, hb.project_name)
end

---@param userconfig table
function M.setup(userconfig)
    testaustime_ignore = userconfig.ignored_filetypes or testaustime_ignore
    testaustime_url = userconfig.api_url or testaustime_url
    testaustime_token = assert(userconfig.token, "Missing api token for testaustime")
    testaustime_useragent = userconfig.useragent or testaustime_useragent
    testaustime_editor_name = userconfig.editor_name or testaustime_editor_name
    vim.api.nvim_create_autocmd({ "CursorMoved" }, { callback = sendheartbeat })
    vim.api.nvim_create_autocmd({ "ExitPre" }, { callback = sendflush })
end

return M
