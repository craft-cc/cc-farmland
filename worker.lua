Station = require("station")
require("my_debug")
Inventory = require("inventory")


Worker = {
    gridLocation = { row = 1, col = 1 },
    actionsHistory = {},
    direction = nil,
    relativeFront = nil,
    relativeRight = nil,
    relativeLeft = nil,
    relativeBack = nil,
    turtleInventory = Inventory:open("turtle")
}




DirectionTypes = {
    NORTH = "north",
    EAST  = "east",
    SOUTH = "south",
    WEST  = "west",
}

ActionsTypes = {
    FORWARD = "forward",
    BACK = "back",
    RIGHT = "right",
    LEFT = "left",
    TURN_RIGHT = "turn_right",
    TURN_LEFT = "turn_left",
    UP = "up",
    DOWN = "down"
}


function Worker:initialize()
    logger("FUNC => Worker:initialize")

    local function defineDirections()
        logger("FUNC => defineDirections")
        local direction = Controller:recheckDirection()
        Worker.direction = direction
        Worker:changeDirection(direction)
        Station:setStationDirections()
    end

    if not Worker:isAtStation() then
        Worker:goToStation()
    end
    if not Worker.direction then
        defineDirections()
    end

end

local function executeAction(actionType, nTimes)
    logger("FUNC => executeAction | param (actionType, nTimes): ", actionType, nTimes)



    local actionErrorMessage = "Move " .. actionType .. " not possible"
    if not nTimes then nTimes = 1 end

    local function doAction()
        logger("FUNC => doAction")



        if actionType == ActionsTypes.FORWARD then
            return turtle.forward()
        end
        if actionType == ActionsTypes.BACK then
            return turtle.back()
        end
        if actionType == ActionsTypes.TURN_RIGHT then
            return turtle.turnRight()
        end
        if actionType == ActionsTypes.TURN_LEFT then
            return turtle.turnLeft()
        end
        if actionType == ActionsTypes.UP then
            return turtle.up()
        end
        if actionType == ActionsTypes.DOWN then
            return turtle.down()
        end
    end

    for i = 1, nTimes do
        if not doAction() then
            error(actionErrorMessage)
        else
            local action = { action = actionType, nTimes = nTimes }
            Worker.actionsHistory[#Worker.actionsHistory + 1] = action
        end
    end
    return true
end

function Worker:changeDirection(currentDirection, actionType)
    logger("FUNC => Worker:changeDirection | param (currentDirection, actionType): ", currentDirection, actionType)

    local function setWorkerRelativeDirections(direction)
        logger("FUNC => setWorkerRelativeDirections | param (direction): ", direction)
        Worker.relativeFront = direction[1]
        Worker.relativeRight = direction[2]
        Worker.relativeLeft = direction[3]
        Worker.relativeBack = direction[4]
    end

    function swipeDirections(direction)
        logger("FUNC => swipeDirections | param (direction): ", direction)
        if direction == DirectionTypes.NORTH then
            return { DirectionTypes.NORTH, DirectionTypes.EAST, DirectionTypes.WEST, DirectionTypes.SOUTH }
        elseif direction == DirectionTypes.EAST then
            return { DirectionTypes.EAST, DirectionTypes.SOUTH, DirectionTypes.NORTH, DirectionTypes.WEST }
        elseif direction == DirectionTypes.SOUTH then
            return { DirectionTypes.SOUTH, DirectionTypes.WEST, DirectionTypes.EAST, DirectionTypes.NORTH }
        elseif direction == DirectionTypes.WEST then
            return { DirectionTypes.WEST, DirectionTypes.NORTH, DirectionTypes.SOUTH, DirectionTypes.EAST }
        end
    end

    local newDirections = swipeDirections(currentDirection)
    setWorkerRelativeDirections(newDirections)
    if actionType == ActionsTypes.TURN_RIGHT then
        Worker.direction = newDirections[2]
    elseif actionType == ActionsTypes.TURN_LEFT then
        Worker.direction = newDirections[3]
    end
    return Worker.direction

end

function Worker:turnRight(nTimes)
    logger("FUNC => Worker:turnRight | param (nTimes): ", nTimes)
    local error = not executeAction(ActionsTypes.TURN_RIGHT, nTimes)
    if error then
        return false
    end
    Worker:changeDirection(Worker.direction, ActionsTypes.TURN_RIGHT)
end

function Worker:turnLeft(nTimes)
    logger("FUNC => Worker:turnLeft | param (nTimes): ", nTimes)
    local error = not executeAction(ActionsTypes.TURN_LEFT, nTimes)
    if error then
        return false
    end
    Worker:changeDirection(Worker.direction, ActionsTypes.TURN_LEFT)
end

function Worker:forward(nTimes)
    logger("FUNC => Worker:forward | param (nTimes): ", nTimes)
    return executeAction(ActionsTypes.FORWARD, nTimes)
end

function Worker:back(nTimes)
    logger("FUNC => Worker:back | param (nTimes): ", nTimes)
    return executeAction(ActionsTypes.BACK, nTimes)
end

function Worker:right(nTimes)
    logger("FUNC => Worker:right | param (nTimes): ", nTimes)
    Worker:turnRight(nTimes)
    Worker:forward(nTimes)

end

function Worker:left(nTimes)
    logger("FUNC => Worker:left | param (nTimes): ", nTimes)
    if Worker:turnLeft(nTimes) and Worker:forward(nTimes) then
        return true
    end
    return false

end

function Worker:undo()
    logger("FUNC => Worker:undo")
    local function getLastAction(history)
        logger("FUNC => getLastAction | param (history): ", history)
        local result = history[#history]
        return result.action, result.nTimes
    end

    local function opositeAction(actionType)
        logger("FUNC => opositeAction | param (actionType): ", actionType)
        if actionType == ActionsTypes.FORWARD then
            return ActionsTypes.BACK
        end
        if actionType == ActionsTypes.BACK then
            return ActionsTypes.FORWARD
        end
        if actionType == ActionsTypes.TURN_RIGHT then
            return ActionsTypes.TURN_LEFT
        end
        if actionType == ActionsTypes.TURN_LEFT then
            return ActionsTypes.TURN_RIGHT
        end
        if actionType == ActionsTypes.UP then
            return ActionsTypes.DOWN
        end
        if actionType == ActionsTypes.DOWN then
            return ActionsTypes.UP
        end
    end

    local history = Worker.actionsHistory
    local recentAction, nTimes = getLastAction(history)
    local action = opositeAction(recentAction)
    executeAction(action, nTimes)
    table.remove(history, #history)
end

function Worker:location(useArray)
    logger("FUNC => Worker:location | param (array): ", array)
    local x, y, z = gps.locate()
    if aruseArrayray then
        return { x, z, y }
    end
    return x, z, y
end

function Worker:isAtStation()
    logger("FUNC => Worker:isAtStation")
    local dataBottom = Worker.inspect("bottom")
    local backTypes = { peripheral.getType("back") }

    if dataBottom.name ~= Station.Blocks.IRON_BLOCK then
        return false
    end
    for typeK, typeV in pairs(backTypes) do
        if typeV == Station.Blocks.INVENTORY then
            return true
        end
    end
end


local function faceToRelativeSide(relativeSide)
    logger("FUNC => faceToRelativeSide | param (relativeSide): ", relativeSide)
    local function closeToRight(direction)
        logger("FUNC => closeToRight | param (direction): ", direction)
        local rightLookup = {
            north = "east",
            east = "south",
            south = "west",
            west = "north"
        }
        logger("BOOLEAN => rightLookup[Worker.direction] ==direction: ", rightLookup[Worker.direction], Worker.direction)

        return rightLookup[Worker.direction] == direction
    end

    local direction = Worker.direction
    local isCloseToRight = closeToRight(relativeSide)
    while relativeSide ~= direction do
        direction = Worker.direction
        logger("LOOP => while relativeSide ~= direction : ", "relativeSide: " .. relativeSide, "direction: " .. direction)
        if relativeSide == direction then
            break
        end
        --
        if isCloseToRight then
            Worker:turnRight()
        else
            Worker:turnLeft()
        end
    end
end

function Worker:faceToFront()
    logger("FUNC => Worker:faceToFront")
    faceToRelativeSide(Station.relativeFront)
end

function Worker:faceToRelativeFront()
    logger("FUNC => Worker:faceToRelativeFront")
    faceToRelativeSide(Worker.relativeFront)
end

function Worker:faceToBack()
    logger("FUNC => Worker:faceToBack")
    faceToRelativeSide(Station.relativeBack)
end

function Worker:faceToRelativeBack()
    logger("FUNC => Worker:faceToRelativeBack")
    faceToRelativeSide(Worker.relativeBack)
end

function Worker:faceToRight()
    logger("FUNC => Worker:faceToRight")
    faceToRelativeSide(Station.relativeRight)
end

function Worker:faceToRelativeRight()
    logger("FUNC => Worker:faceToRelativeRight")
    faceToRelativeSide(Worker.relativeLeft)
end

function Worker:faceToLeft()
    logger("FUNC => Worker:faceToLeft")
    faceToRelativeSide(Station.relativeLeft)
end

function Worker:faceToRelativeLeft()
    logger("FUNC => Worker:faceToRelativeLeft")
    faceToRelativeSide(Worker.relativeLeft)
end



function Worker.inspect(side)

    local function getInspectResult(inspect)
        logger("FUNC => getInspectResult | param (inspect): ", inspect)
        local success, data = inspect()
        if success then
            return data
        end
        error("Inspect " .. side .. " failed")
    end

    if not side then side = "front" end
    if side == 'front' then return getInspectResult(turtle.inspect) end
    if side == 'top' then return getInspectResult(turtle.inspectUp) end
    if side == 'bottom' then return getInspectResult(turtle.inspectDown) end
    error("The " .. side .. " property you have specified is not supported or does not exist.")
end


function Worker:getGridLocation()
    logger("FUNC => Worker:getGridLocation: ", Worker.gridLocation)
    return Worker.gridLocation
end

function Worker:setGridLocation(row, col)
    logger("FUNC => Worker:setGridLocation | param (row, col): ", row, col)

    Worker.gridLocation = { row = row, col = col }
end

function Worker:refuel()
    logger("FUNC => Worker:refuel")

    local function refuelOnStation()
        logger("FUNC => refuelOnStation")
        local function isFuelLowerThan(limit)
            logger("FUNC => isFuelLowerThan | param (limit): ", limit)
            local maxFuel = turtle.getFuelLimit()
            local currentFuel = turtle.getFuelLevel()
            local value = (100 * currentFuel) / maxFuel
            return value < limit
        end

        if isFuelLowerThan(0.80) then
            turtle.select(1)
            return turtle.refuel()
        end
        return true
    end

    refuelOnStation()

end

function Worker:goToStation()
    logger("FUNC => Worker:goToStation")
    local gridLocation = Worker:getGridLocation()
    if (gridLocation.row == 0 or gridLocation.col == 0) then
        if Worker.direction ~= Worker.relativeFront then
            Worker:faceToFront()
        end
        return
    end
    Controller:toPosition(gridLocation.row, gridLocation.col, 1, 1)
    Worker:faceToFront()
    Worker:back()
end

function Worker:insertItem(itemName,type)
    
    local function placeUpChest()
        Worker:selectByName("chest")
        turtle.placeUp()
    end

    local function breakUpChest()
        Worker:selectByName("chest")
        turtle.bigUp()
    end

    placeUpChest()
    local chestInventory = Worker:getInventory().transferToChest(itemName)
    if not chestInventory  then return false, "" end

    local pot = Inventory:open("pot","bottom")
    if not pot  then return false, "" end

    chestInventory:export(pot,1)
    breakUpChest()

end



function Worker:selectByName(name) 
   local slot = Inventory:getItemByPattern(Worker:getInventory().list(),name)
   turtle.select(slot)
end

function Worker:replaceItem(item)
    logger("FUNC => Worker:replaceItem | param (item): ", item)
end


function Worker:geItemFromInventory(pattern)
    local inventory = Worker:getInventory()
    for i, item in ipairs(inventory) do
      if item.name and string.find(item.name, pattern) then
        logger("item name: ", item.name)
        return item.slot, item.count
      end
    end
    return nil, 0 -- Return nil and 0 if no matching item was found
end

function Worker:getInventory()
    return Worker.turtleInventory
end

function Worker:returnToStation()
    local workerPosition = Worker:getGridLocation()
    if not Worker:isAtStation() then
        Controller:toDestination(1, 1)
        Worker:faceToFront()
        Worker:back(2)
    end
end

function Worker:leaveStation()
    if Worker:isAtStation() then
        Worker:faceToFront()
        Worker:forward(2)
    end
end

function Worker:removeItem(item)
    logger("FUNC => Worker:removeItem | param (item): ", item)
end

function Worker:placeItem(slot)
    logger("FUNC => Worker:placeItem")
    turtle.select(slot)
    turtle.placeUp()
end
