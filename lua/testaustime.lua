local Job = require("plenary.job")

last_heartbeat = 0

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

    for ft in vim.g.testaustime_ignore:gmatch("%S+") do
        if ft == hb.language then
            return
        end
    end

    last_heartbeat = now

    local url = vim.g.testaustime_url .. "/activity/update"
    local useragent = vim.g.testaustime_useragent or "testaustime.nvim"

    return Job:new({
        command = "curl",
        args = { "-sd", heartbeattojson(hb), "-H", "Content-Type: application/json", "-H",
            "Authorization: Bearer " .. vim.g.testaustime_token, "-A", useragent, url },
    }):start()
end

function sendflush()
    local url = vim.g.testaustime_url .. "/activity/flush"

    local useragent = vim.g.testaustime_useragent or "testaustime.nvim"

    return Job:new({
        command = "curl",
        args = { "-sX", "POST", "-H", "Authorization: Bearer " .. vim.g.testaustime_token, "-A", useragent, url }
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

vim.api.nvim_create_autocmd({ "CursorMoved" }, { callback = sendheartbeat })
vim.api.nvim_create_autocmd({ "ExitPre" }, { callback = sendflush })
