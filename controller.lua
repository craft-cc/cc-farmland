require("worker")
Controller = {}



function Controller:moveInRows(fromRow, fromColumn, toRow, toColumn)
    if fromRow > toRow then
        Worker:faceToBack()
        for row = toRow, fromRow - 1 do
            Worker:forward()
        end
    elseif fromRow < toRow then
        Worker:faceToFront()
        for row = toRow - 1, fromRow, -1 do
            Worker:forward()
        end
    end
end

function Controller:moveInColumns(fromRow, fromColumn, toRow, toColumn)
    if fromColumn > toColumn then
        Worker:faceToLeft()
        for col = toColumn, fromColumn - 1 do
            Worker:forward()
        end
    elseif fromColumn < toColumn then
        Worker:faceToRight()
        for col = toColumn - 1, fromColumn, -1 do
            Worker:forward()
        end
    end

end

function Controller:toPosition(fromRow, fromColumn, toRow, toColumn)
    Controller:moveInRows(fromRow, fromColumn, toRow, toColumn) --   __
    Controller:moveInColumns(fromRow, fromColumn, toRow, toColumn) --   |
    return direction
end

function Controller:recheckDirection()

    local function getMoveInfo(action)
        local locationInMove = nil
        if action == ActionsTypes.FORWARD then
            if not Worker:forward() then
                getMoveInfo(ActionsTypes.RIGHT)
            else
                locationInMove = Worker:location()
                Worker:undo()
            end
        end
        if action == ActionsTypes.RIGHT then
            if not Worker:right() then
                getMoveInfo(ActionsTypes.LEFT)
            else
                locationInMove = Worker:location()
                Worker:undo()
            end
        end
        if action == ActionsTypes.LEFT then
            if not Worker:left() then
                getMoveInfo(ActionsTypes.BACK)
            else
                locationInMove = Worker:location()
                Worker:undo()
            end
        end
        if action == ActionsTypes.BACK then
            if not Worker:left() then
                assert(false, "Impossible to move!")
            else
                locationInMove = Worker:location()
                Worker:undo()
            end
        end
        return { action, locationInMove }
    end

    local function compareLocations(originLocation, afterMoveInfo)
        local action, afterMoveLocation = afterMoveInfo[1], afterMoveInfo[2]
        local turtleX, turtleZ = Worker:location()
        if not turtleX then return nil end
        local stationLocation = Station:getStationLocation()

        local dest_x, dest_z = stationLocation[1], stationLocation[2]
        local dx = dest_x - turtleX
        local dz = dest_z - turtleZ

        if math.abs(dx) > math.abs(dz) then
            if dx < 0 then
                return DirectionTypes.WEST
            else
                return DirectionTypes.EAST
            end
        else
            if dz < 0 then
                return DirectionTypes.SOUTH
            else
                return DirectionTypes.NORTH
            end
        end
    end  
end
