args = { ... }

function readToken()
    local file = fs.open(".env", "r")
    if not file then
        return ""
    end
    local tokenLine = file.readLine()
    local token = string.sub(tokenLine, 7)
    file.close()
    return token
end

function writeToken(token)
    local file = fs.open(".env", "w")
    file.writeLine("token=" .. token)
    file.close()
end

local token = readToken()
if #args == 1 and #token == 0 then
    token = args[1]
    writeToken(token)
end



if not term.isColor() then
    return error("Computer need to be advacend")
end
if (not token) or #token < 1 then
    return error("token is not define")
end

function download_cloud_catcher()
    shell.run("wget https://cloud-catcher.squiddev.cc/cloud.lua")
    while not shell.resolveProgram("cloud") do
        sleep(0.5)
    end
end

local files = {}
function list_files(dir)
    for index, value in pairs(fs.list(dir)) do
        local path = dir .. "/" .. value
        if not string.find(path, '/rom/') and value ~= "cloud.lua" then
            -- If the file is a directory, list its contents recursively
            if fs.isDir(path) then
                list_files(path)
            else
                files[#files + 1] = path
            end
        end
    end
    return files
end

function connect_to_cloud()
    if not shell.resolveProgram("cloud") then
        download_cloud_catcher()
    end
    if cloud_catcher then
        return
    end
    shell.run("bg cloud " .. token)
    sleep(1)
end

connect_to_cloud()
local files = {
    "./farmland/manager.lua",
    "./farmland/worker.lua",
    "./farmland/controller.lua",
    "./farmland/farmland_data.json",
    "./farmland/seeds_tier.json",
    "./startup.lua",
    "./init.lua",
    "./farmland/my_debug.lua" } --list_files("./farmland")
--for index,file in ipairs(files) do print(#files) end
for index, file in ipairs(files) do
    print("cloud edit " .. file)
    cloud_catcher.edit(file)
    sleep(0.1)
end



if multishell.getCount() > 1 then
    return shell.exit()
end

