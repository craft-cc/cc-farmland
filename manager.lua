 
Controller = {}

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
    --print("[FaceToFront] CURRENT DIRECTION: " .. currentDirection)
    while Controller.DefaultDireciton.FRONT ~= currentDirection do
        currentDirection = turnRight(currentDirection)
        --print("NEW CURRENT DIRECTION: " .. currentDirection)
    end
    --print("*NEW* CURRENT DIRECTION: " .. currentDirection)
    return currentDirection

end

function Controller:faceToBack(currentDirection)
    --print("[FaceToBack] CURRENT DIRECTION: " .. currentDirection)
    while Controller.DefaultDireciton.BACK ~= currentDirection do
        currentDirection = turnRight(currentDirection)
        --print("NEW CURRENT DIRECTION: " .. currentDirection)
    end
    --print("*NEW* CURRENT DIRECTION: " .. currentDirection)
    return currentDirection

end

function Controller:faceToLeft(currentDirection)
    --print("[FaceToLeft] CURRENT DIRECTION: " .. currentDirection)
    while Controller.DefaultDireciton.LEFT ~= currentDirection do
        currentDirection = turnLeft(currentDirection)
        --print("NEW CURRENT DIRECTION: " .. currentDirection)
    end
    --print("*NEW* CURRENT DIRECTION: " .. currentDirection)
    return currentDirection

end

function Controller:faceToRight(currentDirection)
    --print("[FaceToRight] CURRENT DIRECTION: " .. currentDirection)
    while Controller.DefaultDireciton.RIGHT ~= currentDirection do
        --print("NEW CURRENT DIRECTION: " .. currentDirection)
        currentDirection = turnRight(currentDirection)
    end
    --print("*NEW* CURRENT DIRECTION: " .. currentDirection)
    return currentDirection
end