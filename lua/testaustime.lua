local M = {}

local Job = require("plenary.job")

local last_heartbeat = 0

local testaustime_ignore = {"packer", "netrw", "help", "qf", "TelescopePrompt", "gitcommit"}
local testaustime_secret_projects = {}
local testaustime_url = "https://api.testaustime.fi"
local testaustime_token = ""
local testaustime_useragent = "testaustime.nvim"
local testaustime_editor_name = "Neovim"
local testaustime_hostname = vim.fn.hostname()

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
    local root = git_root()

    if root == "" then
        root = vim.fn.getcwd()
    end

    local project_name = root:match("/([^/]+)$")

    for _, ignored_project_name in ipairs(testaustime_secret_projects) do
        if root:find(ignored_project_name) ~= nil then
            project_name = "hidden"
        end
    end

    return {
        language = vim.bo.filetype,
        hostname = testaustime_hostname,
        editor_name = vim.g.testaustime_editor_name or "Neovim",
        project_name = project_name
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
    testaustime_secret_projects = userconfig.secret_projects or testaustime_secret_projects
    testaustime_hostname = userconfig.hostname or testaustime_hostname
    vim.api.nvim_create_autocmd({ "CursorMoved" }, { callback = sendheartbeat })
    vim.api.nvim_create_autocmd({ "ExitPre" }, { callback = sendflush })
end

return M
