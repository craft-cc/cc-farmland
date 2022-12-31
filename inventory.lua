
Inventory = {}



function Inventory:open(type,side)
    local inventory = {
        content = {},
        type = nil,
        export = nil,
        import = nil,
        list = nil,
    }
    local content = inventory.content

    local function listTurtleContent()
        content = {}
        for i = 1, 16 do
            turtle.select(i) 
            local item = turtle.getItemDetail()
            if item then
                content[#content + 1] = {name = item.name, count = item.count, slot = i}
            else
                content[#content + 1] = {name = nil, count = 0, slot = i}
            end
        end
    end
    local function transferToChest(itemName)
        Worker.selectByName(itemName)
        turtle.dropUp()
        return Inventory:open("chest","up")
    end


    local function listItems()
        content = {}
        for slot, item in ipairs(inventoryWraped.list()) do
            content[#content + 1] = {name = item.name, count = item.count, slot = slot}
        end
        return content
    end

    inventory.type = type
    if type == "turtle" then
        inventory.list = listTurtleContent
        inventory.transferToChest = transferToChest
        return inventory
    end

    if not side then return  end
    local inventoryWraped = peripheral.wrap(side)
    local function import(fromInventory,fromSlot,limit,toSlot)
        if not limit then limit = 1 end
        inventory.pullItems(inventoryWraped.getName(fromInventory),fromSlot,limit,toSlot)
    end
    local function export(toInventory,toSlot,limit,fromSlot)
        if not limit then limit = 1 end
        inventory.pushItems(inventoryWraped.getName(toInventory),toSlot,limit,fromSlot)
    end
    inventory.list = listItems
    inventory.import = import
    inventory.export = export
    return inventory
    
end 

function Inventory:getItemByName(content,name)
    for i, item in ipairs(content) do
        if item.name == name then
          logger("item name: ", item.name)
          return item.slot, item.count
        end
      end
      return nil, 0    
end



function Inventory:getItemByPattern(content,pattern)
    for i, item in ipairs(content) do
        if item.name and string.find(item.name, pattern) then
          return item.slot, item.count
        end
      end
      return nil, 0  
end






return Inventory

