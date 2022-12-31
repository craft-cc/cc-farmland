require("my_debug")
require("controller")
require("station")
farmlandData = nil -- unserialiseJSON(farmlandDataJson)
initDebug(true)



function readJsonFile(path)
    local file = fs.open(path, "r")
    if not file then
        error("Could not open file: " .. path)
    end
    local contents = file.readAll()
    file.close()
    return textutils.unserialize(contents)
end

function writeJsonFile(path, data)
    local file = fs.open(path, "w")
    if not file then
        error("Could not open file: " .. path)
    end
    file.write(textutils.serialize(data))
    file.close()
end



local function parseArguments(arg)
    logger("FUNC => parseArguments | param (arg): ", arg)



    local function validation(input)
        logger("FUNC => validation | param (input): ", input)
        return string.match(input, "%d+x%d+")
    end

    local function split(input, pattern)
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



    local function readFile(path)
        local file = fs.open(path, "r")
        local contents = file.readAll()
        file.close()
        return textutils.unserialiseJSON(contents)
    end

    local result = readFile("./farmland/farmland_data.json");
    return result.workplace
end



local function scan()
    logger("FUNC => scan")

    local function onCheckPot()
        
        local status,farmlandTier,seedName,location
        local workerGridLocation = Worker:getGridLocation()
        location = Worker:location()
        local gridLoation = {workerGridLocation.row, workerGridLocation.col}
        local potInventory = Inventory:open("pot","bototm")
        if not potInventory then return "" end
        local content = potInventory.list()
        if not content then return "" end

        if #content == 0 then
            status = "empty"
        end

        for _, item in pairs(content) do
            if(item.slot == 1) then
                seedName = item.name
            end
            if(item.slot == 2) then
                farmlandTier = content[2].name
            end
        end
        
        if not seedName then status = "pending_seed" end
        if not farmlandTier then status = "pending_farmland" end
        if not status then status = "planted" end

        savePotInfo({status = status,farmlandTier = farmlandTier,seedName =seedName,location = location,gridLoation = gridLoation})
    end

    local function checkAllPots()
        logger("FUNC => checkAllPots")
        local workplace = getWorkplaceData()
        local size = tonumber(workplace.width)
        local nextDirection = Station.relativeRight
        for row = 1, tonumber(workplace.lenght) do
            Controller:moveByCol(row, size, nextDirection)
            if nextDirection == Station.relativeRight then
                nextDirection = Station.relativeLeft
            else
                nextDirection = Station.relativeRight
            end
        end
    end

    Worker:leaveStation()
    checkAllPots()
    Worker:returnToStation()


end


local function select(paraments, execute)
    local beginArea = paraments[1]
    local endArea = paraments[2]
    local firstRow, firstCol = parseArguments(beginArea)
    Worker:leaveStation()
    --local function execute() Worker:placeItem() end
    if not endArea then
        Controller:toDestination(firstRow, firstCol)
        Worker:returnToStation()
        return
    end
    local lastRow, lastCol = parseArguments(endArea)

    local direction = 1
    for row = firstRow, lastRow do 
        for col = firstCol, lastCol, direction do
            Controller:toDestination(row, col, execute)
        end
        direction = -direction
        firstCol, lastCol = lastCol, firstCol
    end


    Worker:returnToStation()
end


local function plant(paraments)
    logger("FUNC => plant | param (selectArea, seed, farmland): ", paraments[1], paraments[2])
    

    local paramentSeed, paramentFarmland = paraments[1], paraments[2]


    --local storage = Station:getStorage()
    --local inventory = Worker:getInventory()

    local function isMinTier()
        logger("FUNC => isMinTier")

        --local seedTier = farmlandData.findTier(seed)
        --local farmlandTier = farmlandData.findTier(farmland)
        --return farmlandTier >= seedTier
        return true
    end

    if not isMinTier() then
        return abort("You need a better farmland to plant this seed!")
    end
   --[[ if not storage then
        return abort("You need config a storage before plant!")
    end
        if not inventory:hasItem(seed) then
        local success, item = storage:request(seed)
        if not success then
            return abort("You don't have " .. seed .. " available in the storage!")
        end
        inventory.addItem(item)
            if not inventory:hasItem(farmland) then
        local success, item = storage:request(farmland)
        if not success then
            return abort("You don't have " .. farmland .. " available in the storage!")
        end
        inventory.addItem(farmland)
    end
    end
    ]]

    local function getSeedByName(name)
        
    end

    local function getFarmlandByName(name)
        
    end

    local function updatePotInfo()
        
    end

    local seed = getSeedByName(paramentSeed:match("seed_(.+)"))

    local farmland = getFarmlandByName(paramentFarmland:match("farmland_tier_(%d+)"))


    local function execute ()
        logger("seed,farmland " ,seed,farmland)
        Worker:insertItem(seed)
        Worker:insertItem(farmland)
        updatePotInfo()
    end

    select({paraments[3],paraments[4]}, execute)


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
    Worker:initialize()
    Worker:refuel()
end



args = { ... }

function run()
    logger("FUNC => run")

    local argumentsAvailables = {
        select = {
            name = "select",
            parament = {
                minNumber = 1,
                maxNumber = 2,
                pattern = "%d+x%d+"
            },
            execute = select
        },
        scan = {
            name = "scan",
            parament = {
                minNumber = 0,
            },
            execute = scan
        },
        plant = {
            name = "plant", -- what (seed,farmland tier), where,
            parament = {
                minNumber = 3,
                maxNumber = 4,
                pattern = {"seed_(.-)%s*farmland_tier_(%d+)%s*(%d+x%d+)%s*(%d+x%d+)"}
            },
            execute = plant
        },
        remove = {
            name = "remove",
            parament = {
                minNumber = 1,
                maxNumber = 2,
                pattern = "%d+x%d+"
            }
        },
        replace = {
            name = "replace",
            parament = {
                minNumber = 1,
                maxNumber = 2,
                pattern = "%d+x%d+"
            }
        },
    }

    local function getParaments()
        local paraments = {}
        for i = 2, #args do
            paraments[#paraments + 1] = args[i]
        end
        return paraments
    end

    local function match(paraments, pattern)
        if type(pattern) == "table" then
            print(table.concat(paraments, " "))
            if not string.match(table.concat(paraments, " "), pattern[1]) then
                return false, "Invalid argument: " .. param
            end
            return true
        end 
        for _, param in pairs(paraments) do
            if not string.match(param, pattern) then
                return false, "Invalid argument: " .. param
            end
        end
        return true
    end

    local function validateArguments()
        if not (#args > 0) then
            return false, "Not enough arguments provided"
        end

        local argument = argumentsAvailables[args[1]]
        if not argument then
            return false,"Unknow command: " .. args[1]
        end

        local paraments = getParaments()
        if #paraments > 0 then
            if argument.parament.minNumber >= #paraments and argument.parament.maxNumber <= #paraments then
                local errorMessage = "Invalid number of arguments for command '"
                    .. argument.name .. "': expected "
                    .. argument.parament.minNumber
                    .. " to " .. argument.parament.maxNumber
                    .. ", got " .. #paraments
                return false,errorMessage
            end
    
            local success, message = match(paraments, argument.parament.pattern)
    
            if not success then
                return false,message
            end
        end

        return true,argument
    end
    local success, result = validateArguments()
    if not success then
        local message = result
        term.setTextColor(colors.red)
        logger(message)
        term.setTextColor(colors.white)
        return
    end
    if not result then return end
    local command = result
    local paraments = getParaments()
    logger("Executing " .. command.name .. " with " .. #paraments .. " paraments")
    logger(command)
    setup()
    command.execute(paraments)
end

run()
