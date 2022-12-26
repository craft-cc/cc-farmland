require("debug")
require("controller")
farmlandData = nil -- unserialiseJSON(farmlandDataJson)
debug(true)




local function parseArguments(arg)
    local function validation(input)
        return string.match(input, "%d+x%d+")
    end

    local function split(input, pattern)
        local substrings = {}
        for substring in string.gmatch(input, "[^" .. pattern .. "]+") do
            substrings[#substrings + 1] = substring
        end
        return substrings
    end

    local substrs = split(arg, "x")
    local targetRow = tonumber(substrs[1])
    local targetColumn = tonumber(substrs[2])
    return targetRow, targetColumn
end

local function getWorkplaceData()
    local function read_file(path)
        local file = fs.open(path, "r")
        local contents = file.readAll()
        file.close()
        return textutils.unserialiseJSON(contents)
    end
    local result = read_file("./farmland/farmland_data.json");
    return result.workplace    
end

local function scan()
    if not Worker.direction then
        local direction = Controller:recheckDirection()
        Worker.direction = direction
        Controller:changeDirectiion(direction)
    end
    logger("Worker.relativeFront "..Worker.relativeFront)
    logger("Worker.relativeBack " ..Worker.relativeFront)
    logger("Worker.relativeRight "..Worker.relativeFront)
    logger("Worker.relativeLeft "..Worker.relativeFront)

    logger("Worker.direction, ".. Worker.direction)
    local workplace = getWorkplaceData()
    local size = tonumber(workplace.width)
    for row = 1, tonumber(workplace.lenght) do
        if (Worker.relativeRight == Worker.direction) then
            Controller:moveByRightCol(row, size)
        else
            Controller:moveByLeftCol(row, size)
        end
    end
end

local function plant(selectArea, seed, farmland)
    local storage = Station:getStorage()
    local inventory = Worker:getInventory()

    local function isMinTier()
        local seedTier = farmlandData.findTier(seed)
        local farmlandTier = farmlandData.findTier(farmland)
        if farmlandTier >= seedTier then
            return true
        end
        return false
    end

    if not isMinTier() then
        return abort("You need a better farmland to plant this seed!")
    end
    if not storage then
        return abort("You need config a storage before plant!")
    end
    if not inventory:hasItem(seed) then
        local success, item = storage:request(seed)
        if not success then
            return abort("You don't have " .. seed .. " available in the storage!")
        end
        inventory.addItem(item)
    end
    if not inventory:hasItem(farmland) then
        local success, item = storage:request(farmland)
        if not success then
            return abort("You don't have " .. farmland .. " available in the storage!")
        end
        inventory.addItem(farmland)
    end

end

local function replace()

end

function abort(reasson)
    logger("*********** ABORT **********")
    logger(reasson)
    error(reasson)
end

local function setup()
    if not Worker:isAtStation() then
        Worker:goToStation()
    end
    Worker:refuel()
    Worker:forward(2)
end

function run()

    if #arg <= 0 then
        return error("No argument provided")
    end
    setup()
    if arg[1] == 'scan' then
        return scan()
    end

end

run()
