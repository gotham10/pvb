local urls = {
    "https://raw.githubusercontent.com/gotham10/pvb/refs/heads/main/plantsautobuy2.0.lua",
    "https://raw.githubusercontent.com/gotham10/pvb/refs/heads/main/gearautobuy3.0.lua",
    "https://raw.githubusercontent.com/gotham10/pvb/refs/heads/main/claimcash.lua"
}

for _, url in ipairs(urls) do
    local ok, src = pcall(function() return game:HttpGet(url) end)
    if not ok or not src then
        warn(("Failed to download from %s : %s"):format(url, tostring(src)))
    else
        local exec_ok, exec_err = pcall(function() loadstring(src)() end)
        if not exec_ok then
            warn(("Failed to run script from %s : %s"):format(url, tostring(exec_err)))
        end
    end
end
