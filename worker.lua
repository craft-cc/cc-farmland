require("station")
require("debug")

Inventory = {
    addItem = function(fromInventory)
    end,
    transferItem = function(toInvetory)
    end
}

Worker = {
    gridLocation = { row  = 0, col = 0 },
    actionsHistory = {},
    direction = nil,
    relativeFront = nil,
    relativeRight = nil,
    relativeLeft = nil,
    relativeBack = nil,
    inventory = Inventory
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
    RIGHT ="right",
    LEFT="left",
    TURN_RIGHT = "turn_right",
    TURN_LEFT = "turn_left",
    UP = "up",
    DOWN = "down"
}


local function executeAction(actionType, nTimes)
    local actionErrorMessage = "Move " .. actionType .. " not possible"
    if not nTimes then nTimes = 1 end

    local function doAction()
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
            local action = { actionType, nTimes }
            Worker.actionsHistory[#Worker.actionsHistory + 1] = action
        end
    end
end


local function changeDirection(currentDirection, actionType)

    local function setWorkerRelativeDirections(direction)
        Worker.relativeFront = direction[1]
        Worker.relativeRight = directions[2]
        Worker.relativeLeft = directions[3]
        Worker.relativeBack = directions[4]
    end

    local function otherDirections(direction)
        local moreDirections = {}
        local options = { DirectionTypes.NORTH, DirectionTypes.EAST, DirectionTypes.WEST, DirectionTypes.SOUTH }
        local targetDirection = direction
        moreDirections[#moreDirections + 1] = targetDirection
        for i = 1, #options + 3, 1 do
            if #moreDirections == 4 then
                return moreDirections
            end
            local j = i
            if i > 4 then
                j = (i - 4)
            end
            if targetDirection == options[j] then
                if not options[j + 1] then
                    moreDirections[#moreDirections + 1] = options[1]
                    targetDirection = options[1]
                else
                    moreDirections[#moreDirections + 1] = options[j + 1]
                    targetDirection = moreDirections[#moreDirections]
                end

            end
        end
        return moreDirections
    end

    if not currentDirection then
        local direction = Controller:recheckDirection()
        if not direction then
            error("RecheckDirection return nil")
        end
        Worker.direction = direction
        setWorkerRelativeDirections(otherDirections(direction))
    end

    local function changeDirectionRight()
        if currentDirection == DirectionTypes.NORTH then
            return DirectionTypes.EAST
        end
        if currentDirection == DirectionTypes.EAST then
            return DirectionTypes.SOUTH
        end
        if currentDirection == DirectionTypes.SOUTH then
            return DirectionTypes.WEST
        end
        if currentDirection == DirectionTypes.WEST then
            return DirectionTypes.NORTH
        end
    end

    local function changeDirectionLeft()
        if currentDirection == DirectionTypes.NORTH then
            return DirectionTypes.WEST
        end
        if currentDirection == DirectionTypes.EAST then
            return DirectionTypes.NORTH
        end
        if currentDirection == DirectionTypes.SOUTH then
            return DirectionTypes.EAST
        end
        if currentDirection == DirectionTypes.WEST then
            return DirectionTypes.SOUTH
        end
    end

    if actionType == ActionsTypes.TURN_RIGHT then
        return changeDirectionRight()
    end
    if actionType == ActionsTypes.TURN_LEFT then
        return changeDirectionLeft()
    end

end


function Worker:forward(nTimes)
    return executeAction(ActionsTypes.FORWARD, nTimes)
end


function Worker:turnRight(nTimes)
    local error  = not executeAction(ActionsTypes.TURN_RIGHT, nTimes)
    if error then
        return false
    end
    changeDirection(Worker.direction)
end

function Worker:turnLeft(nTimes)
    local error  = not executeAction(ActionsTypes.TURN_LEFT, nTimes)
    if error then
        return false
    end
    changeDirection(Worker.direction)
end

function Worker:right(nTimes)
    Worker:turnRight(nTimes)
    Worker:forward(nTimes)

end

function Worker:left(nTimes)
    if Worker:turnLeft(nTimes) and Worker:forward(nTimes) then
        return true
    end
    return false

end

function Worker:back(nTimes)
    return executeAction(ActionsTypes.BACK, nTimes)
end



function Worker:undo()

    local function getLastAction(history)
        return history[#history + 1]
    end

    local function opositeAction(actionType)
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






function Worker:location(array)
    logger("Worker:location")
    local x, y, z = gps.locate()
    if array then
        return { x, z, y }
    end
    return x, z, y
end

function Worker.inspect(side)

    local function getInspectResult(inspect)

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

function Worker:isAtStation()
    local dataBottom = Worker.inspect("bottom")
    local backTypes = { peripheral.getType("back") }

    if dataBottom.name ~= Station.Blocks.IRON_BLOCK then
        return false
    end
    for typeK,typeV in pairs(backTypes) do
        if typeV == Station.Blocks.INVENTORY then
            return true
        end
    end

end

local function faceToRelativeSide(relativeSide)

    local function closeToRight(direction)
        -- TODO
        return true
    end

    local direction = Worker.direction
    while relativeSide ~= direction do
        direction = Worker.direction
        if closeToRight(direction) then
            Worker:turnRight()
        else
            Worker:turnLeft()
        end
    end
end

function Worker:faceToFront()
    faceToRelativeSide(Worker.relativeFront)
end

function Worker:faceToBack()
    faceToRelativeSide(Worker.relativeBack)
end

function Worker:faceToRight()
    faceToRelativeSide(Worker.relativeRight)
end

function Worker:faceToLeft()
    faceToRelativeSide(Worker.relativeLeft)
end

function Worker:getGridLocation()
    return Worker.gridLocation
end

function Worker:setGridLocation(row, col)
    Worker.gridLocation = { row = row, col = col }
end

function Worker:refuel()
    local function refuelOnStation()
        local function isFuelLowerThan(limit)
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

function Worker:insertItem(item)

end

function Worker:replaceItem(item)

end

function Worker:removeItem(item)

end
