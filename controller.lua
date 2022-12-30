require("worker")
Controller = {}


function Controller:toDestination(destRow, destCol,execute)
    logger("FUNC => Controller:toDestination | param (destRow, destCol): ", destRow, destCol)


    local function moveInRowsToDestination(rowsToMove, step)
        logger("FUNC => moveInRowsToDestination | param (rowsToMove,step): ", rowsToMove, step)
        local workerLocation = Worker:getGridLocation()
        Controller:moveInRows(workerLocation.row, workerLocation.row + step)
        return rowsToMove - 1
    end

    local function moveInColumnsToDestination(colsToMove, step)
        logger("FUNC => moveInColumnsToDestination | param (colsToMove,step): ", colsToMove, step)
        local workerLocation = Worker:getGridLocation()
        Controller:moveInColumns(workerLocation.col, workerLocation.col + step, true)
        return colsToMove - 1
    end

    local function moveTowardsDestination(startRow, startCol, targetRow, targetCol)
        logger("FUNC => moveTowardsDestination | param (startRow, startCol, targetRow, targetCol): ", startRow, startCol, targetRow, targetCol)
        local rowsToMove = math.abs(startRow - targetRow)
        local colsToMove = math.abs(startCol - targetCol)

        local step = 1
  
        while rowsToMove > 0 do
            if startRow > targetRow then
                step = -1
            end
            rowsToMove = moveInRowsToDestination(rowsToMove, step)
        end
        while colsToMove > 0 do
            if startCol > targetCol then
                step = -1
            end
            colsToMove = moveInColumnsToDestination(colsToMove, step)
        end
    end

    local workerLocation = Worker:getGridLocation()
    local startRow, startCol = workerLocation.row, workerLocation.col
    local targetRow, targetCol = destRow, destCol
    moveTowardsDestination(startRow, startCol, targetRow, targetCol)
    if execute then
        execute()
    end
  
end

function Controller:moveByCol(row,size,direction,execute)
    logger("FUNC => Controller:moveByCol(row, init,size, direction,execute): ", row, init,size, direction,execute)
    local function moveByRightCol()
        logger("FUNC => moveByRightCol")
        for col = 1, size, 1 do          logger(" for col = init, size, 1 ",col, init, size, 1)
            local workerLocation = Worker:getGridLocation()
            local initRow, initCol = workerLocation.row, workerLocation.col
            Controller:toPosition(initRow, initCol, row, col)
            Worker:setGridLocation(row, col)
            if execute then
                execute()
            end
            
        end
    end

    local function moveByLeftCol()
        logger("FUNC => moveByLeftCol")
        for col = size, 1, -1 do logger(" for col = init, size, -1 ",col, size, init, -1)
            local workerLocation = Worker:getGridLocation()
            local initRow, initCol = workerLocation.row, workerLocation.col
            Controller:toPosition(initRow, initCol, row, col)
            Worker:setGridLocation(row, col)
            if execute then
                execute()
            end
        end
    end

    if direction == Station.relativeRight then
        moveByRightCol()
    elseif direction == Station.relativeLeft then
        moveByLeftCol()
    else
        error("Invalid direction: " .. direction)
    end


end

function Controller:toPosition(fromRow, fromColumn, toRow, toColumn)
    logger("FUNC => Controller:toPosition | param (fromRow, fromColumn, toRow, toColumn): ", fromRow, fromColumn, toRow,
        toColumn)
    Controller:moveInRows(fromRow, toRow) --   __
    Controller:moveInColumns(fromColumn, toColumn) --   |
end


function Controller:moveInRows(fromRow, toRow)
    logger("FUNC => Controller:moveInRows | param (fromRow, toRow): ", fromRow, toRow)
    if fromRow == toRow then
        return
    end
    local workerGridLocation = Worker:getGridLocation()
    local col = workerGridLocation.col

    if fromRow > toRow then
        Worker:faceToBack()
    else
        Worker:faceToFront()
    end

    Worker:forward()
    Worker:setGridLocation(toRow,col)
end

function Controller:moveInColumns(fromColumn, toColumn, afterFaceDirection)
    logger("FUNC => Controller:moveInColumns | param (fromColumn, toColumn): ", fromColumn, toColumn)

    if fromColumn == toColumn then
        return
    end

    if fromColumn > toColumn then
        if afterFaceDirection or (fromColumn == 1 or fromColumn == 16) then
            Worker:faceToLeft()
        end
        Worker:forward()
    elseif fromColumn < toColumn then
        if afterFaceDirection or (fromColumn == 1 or fromColumn == 16) then
            Worker:faceToRight()
        end
        Worker:forward()
    end
    Worker:getGridLocation().col = toColumn
end

local function getMovementInfo(action)
    logger("FUNC => getMovementInfo | param (action): ", action)
    if not action then
        action = ActionsTypes.FORWARD
    end
    local locationInMove = nil
    if action == ActionsTypes.FORWARD then
        if not Worker:forward() then
            return getMovementInfo(ActionsTypes.RIGHT)
        else
            locationInMove = Worker:location(true)
            Worker:undo()
            return locationInMove
        end
    end
    if action == ActionsTypes.RIGHT then
        if not Worker:right() then
            return getMovementInfo(ActionsTypes.LEFT)
        else
            locationInMove = Worker:location(true)
            Worker:undo()
            return locationInMove
        end
    end
    if action == ActionsTypes.LEFT then
        if not Worker:left() then
            return getMovementInfo(ActionsTypes.BACK)
        else
            locationInMove = Worker:location(true)
            Worker:undo()
            return locationInMove
        end
    end
    if action == ActionsTypes.BACK then
        if not Worker:left() then
            assert(false, "Impossible to move!")
        else
            locationInMove = Worker:location(true)
            Worker:undo()
            return locationInMove
        end
    end
    return locationInMove
end

local function getDirection(dx,dz)
    logger("FUNC => getDirection")

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


function Controller:recheckDirection()
    logger("FUNC => Controller:recheckDirection")
    local locationInMove = getMovementInfo()
    local turtleX, turtleZ = locationInMove[1], locationInMove[2]
    if not turtleX then return nil end

    local stationLocation = Station:getStationLocation()
    if not stationLocation then
        Station:setLocation()
        stationLocation = Station:getStationLocation()
    end

    local dest_x, dest_z = stationLocation[1], stationLocation[2]
    local dx = dest_x - turtleX
    local dz = dest_z - turtleZ

    local direction = getDirection(dx,dz)
    return direction
end


