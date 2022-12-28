require("my_debug")
require("controller")
require("station")
farmlandData = nil -- unserialiseJSON(farmlandDataJson)
initDebug(true)




local function parseArguments(arg)
    logger("FUNC => parseArguments | param (arg): ", arg)



    local function validation(input)
    logger("FUNC => validation | param (input): ", input)

        logger("FUNC => validation | param (input): ", input)



        return string.match(input, "%d+x%d+")
    end

    local function split(input, pattern)
    logger("FUNC => split | param (input, pattern): ", input, pattern)

        logger("FUNC => split | param (input, pattern): ", input, pattern)



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
    logger("FUNC => getWorkplaceData")



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
    logger("FUNC => scan")


    local function getDirectionFromTypes(direction)
    logger("FUNC => getDirectionFromTypes | param (direction): ", direction)

        if DirectionTypes.NORTH == direction then
            return DirectionTypes.NORTH
        end
        if DirectionTypes.SOUTH == direction then
            return DirectionTypes.SOUTH
        end
        if DirectionTypes.WEST == direction then
            return DirectionTypes.WEST
        end
        if DirectionTypes.EAST == direction then
            return DirectionTypes.EAST
        end
    end


    if not Worker.direction then
        local direction = Controller:recheckDirection()
        logger("FUNC => scan RESULT => direction", direction)
        Worker.direction = direction
        Worker:changeDirection(direction)
        Station.relativeFront = getDirectionFromTypes(Worker.relativeFront)
        Station.relativeRight = getDirectionFromTypes(Worker.relativeRight)
        Station.relativeLeft = getDirectionFromTypes(Worker.relativeLeft)
        Station.relativeBack = getDirectionFromTypes(Worker.relativeBack)

    end






    local workplace = getWorkplaceData()
    local size = tonumber(workplace.width)
    Worker:faceToRight()
    local lastRight = true
    for row = 1, tonumber(workplace.lenght) do
        if lastRight then
            Controller:moveByRightCol(row, size)
        else
            Controller:moveByLeftCol(row, size)
        end
    end
end

local function plant(selectArea, seed, farmland)
    logger("FUNC => plant | param (selectArea, seed, farmland): ", selectArea, seed, farmland)



    local storage = Station:getStorage()
    local inventory = Worker:getInventory()

    local function isMinTier()
    logger("FUNC => isMinTier")

        logger("FUNC => isMinTier")



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
    logger("FUNC => replace")




end

function abort(reasson)
    logger("FUNC => abort | param (reasson): ", reasson)





    error(reasson)
end

local function setup()
    logger("FUNC => setup")



    if not Worker:isAtStation() then
        Worker:goToStation()
    end
    Worker:refuel()
    Worker:forward(2)
end

function run()
    logger("FUNC => run")




    if #arg <= 0 then
        return error("No argument provided")
    end
    setup()
    if arg[1] == 'scan' then
        return scan()
    end

end

function print_call_stack()
    local level = 1
    while true do
        local info = debug.getinfo(level, "nSl")
        if not info then break end
        print(string.format("%d\t%s\t%s:%d", level, info.name, info.source, info.currentline))
        level = level + 1
    end
end

run()
