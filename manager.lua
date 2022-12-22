 
require("debug")
debug(true)

Worker = {}
Controller = {}
Station = {}

Controller["DefaultDireciton"] = {
    FRONT = "south",
    BACK = "north",
    RIGHT = "west",
    LEFT = "east"
}
function Controller:turnRight(currentDirection)
    turtle.turnRight()
    if currentDirection == "north" then
        return "east"
    end
    if currentDirection == "east" then
        return "south"
    end
    if currentDirection == "south" then
        return "west"
    end
    if currentDirection == "west" then
        return "north"
    end
end

function Controller:turnLeft(currentDirection)
    turtle.turnLeft()
    if currentDirection == "north" then
        return "west"
    end
    if currentDirection == "east" then
        return "north"
    end
    if currentDirection == "south" then
        return "east"
    end
    if currentDirection == "west" then
        return "south"
    end
end

function Controller:faceToFront(currentDirection)
    logger("[FaceToFront] CURRENT DIRECTION: " .. currentDirection)
    while Controller.DefaultDireciton.FRONT ~= currentDirection do
        currentDirection = turnRight(currentDirection)
        logger("NEW CURRENT DIRECTION: " .. currentDirection)
    end
    logger("*NEW* CURRENT DIRECTION: " .. currentDirection)
    return currentDirection

end

function Controller:faceToBack(currentDirection)
    logger("[FaceToBack] CURRENT DIRECTION: " .. currentDirection)
    while Controller.DefaultDireciton.BACK ~= currentDirection do
        currentDirection = turnRight(currentDirection)
        logger("NEW CURRENT DIRECTION: " .. currentDirection)
    end
    logger("*NEW* CURRENT DIRECTION: " .. currentDirection)
    return currentDirection

end

function Controller:faceToLeft(currentDirection)
    logger("[FaceToLeft] CURRENT DIRECTION: " .. currentDirection)
    while Controller.DefaultDireciton.LEFT ~= currentDirection do
        currentDirection = turnLeft(currentDirection)
        logger("NEW CURRENT DIRECTION: " .. currentDirection)
    end
    logger("*NEW* CURRENT DIRECTION: " .. currentDirection)
    return currentDirection

end

function Controller:faceToRight(currentDirection)
    logger("[FaceToRight] CURRENT DIRECTION: " .. currentDirection)
    while Controller.DefaultDireciton.RIGHT ~= currentDirection do
        logger("NEW CURRENT DIRECTION: " .. currentDirection)
        currentDirection = turnRight(currentDirection)
    end
    logger("*NEW* CURRENT DIRECTION: " .. currentDirection)
    return currentDirection
end



local function moveInRows(fromRow, fromColumn, toRow, toColumn, direction)
    if fromRow > toRow then
        direction = Controller:faceToBack(direction)
        for row = toRow, fromRow - 1 do
            local success, msg = turtle.forward()
        end
    elseif fromRow < toRow then
        direction = Controller:faceToFront(direction)
        for row = toRow - 1, fromRow, -1 do
            local success, msg = turtle.forward()
        end
    end
end

local function moveInColumns(fromRow, fromColumn, toRow, toColumn, direction)
    if fromColumn > toColumn then
        direction = Controller:faceToLeft(direction)
        for col = toColumn, fromColumn - 1 do
            turtle.forward()
        end
    elseif fromColumn < toColumn then
        direction = Controller:faceToRight(direction)
        for col = toColumn - 1, fromColumn, -1 do
            turtle.forward()
        end
    end
    
end


 function Controller:toPosition(fromRow, fromColumn, toRow, toColumn, direction)
    if direction == nil then
        direction = Controller.DefaultDireciton.FRONT
    end
    moveInRows(fromRow, fromColumn, toRow, toColumn, direction) --   __
    moveInColumns(fromRow, fromColumn, toRow, toColumn, direction) --   | 
    return direction
end

function Controller:recheckDirection()

    local function getNewLocation(action)
        local locationInMove = nil
        if action == 'forward' then
            if not Worker:forward() then 
                getNewLocation("right")
            else
                locationInMove = Worker:location()
                Worker:undo()
            end
        end
        if action == "right" then
            if not Worker:right() then 
                getNewLocation("left")
            else
                locationInMove = Worker:location()
                Worker:undo()
            end
        end
        if action == "left" then
            if not Worker:left() then 
                getNewLocation("back")
            else
                locationInMove = Worker:location()
                Worker:undo()
            end
        end
        if action == "back" then
            if not Worker:left() then
                assert(false,"Impossible to move!")
            else
                locationInMove = Worker:location()
                Worker:undo()
            end
        end
        return locationInMove
    end
    local function compareLocations(originLocation, currentLocation)
        
        local result = nil

        if result == DefaultDireciton.FRONT then
            return Controller.DefaultDireciton.FRONT
        end
        if result == DefaultDireciton.RIGHT then
            return Controller.DefaultDireciton.RIGHT
        end
        if result == DefaultDireciton.LEFT then
            return Controller.DefaultDireciton.LEFT
        end
        if result == DefaultDireciton.BACK then
            return Controller.DefaultDireciton.BACK
        end
    end

    local turtleX,turtleY,turtleZ = Worker:location()
    if not turtleX then return nil end
    local stationLocation = Station:getStationLocation()
    local afterMoveLocation = getNewLocation()


end
