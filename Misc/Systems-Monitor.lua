_Monitor = peripheral.wrap("monitor_9")
_ME_Bridge = peripheral.wrap("meBridge_2")
_farm_motors = {
    {
        motor = peripheral.wrap("electric_motor_0"),
        crop = "Carrot & Cannola",
        rpm = 0
    },
    {
        motor = peripheral.wrap("electric_motor_1"),
        crop = "Wheat & Cannola",
        rpm = 0
    },
    {
        motor = peripheral.wrap("electric_motor_2"),
        crop = "Oak & Spruce",
        rpm = 0
    },
}

_Monitored_Item_Names = {
    "minecraft:diamond",
    "minecraft:gold_ingot",
    "mekanism:ingot_uranium",
    "mekanism:alloy_infused",
    "mekanism:ingot_steel"
}

os.loadAPI("bigfont")
_Monitor.clear()

function compareAmount(a,b)
    return a.amount > b.amount
end

function eToExit()
    print( "Press E to exit." )
    while true do
        local event, key = os.pullEvent( "key" ) -- limit os.pullEvent to the 'key' event
        
        if key == keys.e then -- if the key pressed was 'e'
        print( "You pressed [E]. Exiting program..." )
        error()
        end
    end
end
crafting = {}
crafting_tmp = {}
function checkCraft(item)
    if item.amount > 0 then
        if (item.amount > 0 and _ME_Bridge.isItemCrafting(item)) then
            table.insert(crafting_tmp, item)
        end
    end
end
ticker = false
items = {}
Monitored_Items = {}
item_count = 0
energyStored = 0
energyUsage = 0
energyMax = 0
crafting_cpus = {}
craftables = {}
crafting = {}

function grabMEData()
    while true do
        Monitored_Items_temp = {}
        items = _ME_Bridge.listItems()
        item_count = 0
        for i,item in ipairs(items) do
            item_count = item_count + item['amount']
            for j,name in ipairs(_Monitored_Item_Names) do
                if (item['name'] == name) then
                    table.insert(Monitored_Items_temp, item)
                end
            end
        end
        energyStored = _ME_Bridge.getEnergyStorage()
        energyUsage = _ME_Bridge.getEnergyUsage()
        energyMax = _ME_Bridge.getMaxEnergyStorage()

        crafting_cpus = _ME_Bridge.getCraftingCPUs()
        craftables = _ME_Bridge.listCraftableItems()
        crafting_tmp = {}
        for i,item in ipairs(craftables) do
            pcall(checkCraft, item)
        end
        crafting = crafting_tmp
        Monitored_Items = Monitored_Items_temp
    end
end

function monitorFarms()
    while true do
        for i,farm in ipairs(_farm_motors) do
            _farm_motors[i].rpm = farm.motor.getSpeed()
        end
        os.sleep(1)
    end
end

network = {
    types = {},
    devices = {}
}
function monitorNetwork()
    while true do
        networkTmp = {
            types = {},
            devices = {}
        }
        for i,periph in ipairs(peripheral.getNames()) do
            inArr = false
            curName = periph
            if not (curName == "left" or curName == "right" or curName == "front" or curName == "back" or curName == "top" or curName == "bottom") then
                for j,name in ipairs(networkTmp.devices) do
                    if name == curName then
                        inArr = true
                        break
                    end
                end
                if not inArr then
                    type = peripheral.getType(curName)
                    table.insert(networkTmp.devices, curName)
                    if (networkTmp.types[type] == nil) then
                        networkTmp.types[type] = 1
                    else
                        networkTmp.types[type] = networkTmp.types[type] + 1
                    end
                end
            end
        end

        network = networkTmp
        os.sleep(1)
    end
end

function bigNumbers(n)
    if n >= 10^9 then
        return string.format("%.2fG", n / 10^9)
    elseif n >= 10^6 then
        return string.format("%.2fM", n / 10^6)
    elseif n >= 10^3 then
        return string.format("%.2fK", n / 10^3)
    else
        return tostring(n)
    end
end


function __genOrderedIndex( t )
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex )
    return orderedIndex
end

function orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.

    local key = nil
    --print("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = __genOrderedIndex( t )
        key = t.__orderedIndex[1]
    else
        -- fetch the next value
        for i = 1,table.getn(t.__orderedIndex) do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i+1]
            end
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

function orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil
end

page = 1
frameCounter = 1
pages = {
    {
        name = "CC Network"
    },
    {
        name = "Lithium Production"
    },
    {
        name = "Water Pumps"
    },
    {
        name = "Fissle Fuel Production"
    },
    {
        name = "Battery Storage"
    },
    {
        name = "Fusion Reactor"
    }
}
function drawLoop()
    while true do

        _Monitor.setTextScale(0.5)
        w,h = _Monitor.getSize()

        for y=1,h do
            _Monitor.setCursorPos(w/2,y)
            _Monitor.write("|")
        end
        _Monitor.setCursorPos(w/2,24)
        _Monitor.write("+"..string.rep("-",w/2))

        bigfont.writeOn(_Monitor, 1, "ME SYSTEM",w/2+32,4)

        _Monitor.setCursorPos(w/2+6,10)
        _Monitor.write("Stored Items: "..item_count.."        ")
        _Monitor.setCursorPos(w/2+6,12)
        _Monitor.write("Energy:")
        _Monitor.setCursorPos(w/2+8,13)
        _Monitor.write("Stored: "..bigNumbers(math.floor(energyStored*2)).."FE - "..bigNumbers(math.floor(energyStored)).."AE        ")
        _Monitor.setCursorPos(w/2+8,14)
        _Monitor.write("Using: "..bigNumbers(math.floor(energyUsage*2)).."FE/t - "..bigNumbers(math.floor(energyUsage)).."AE/t        ")
        _Monitor.setCursorPos(w/2+8,15)
        _Monitor.write("Maximum: "..bigNumbers(math.floor(energyMax*2)).."FE - "..bigNumbers(math.floor(energyMax)).."AE        ")
        _Monitor.setCursorPos(w/2+6,17)
        if table.getn(Monitored_Items) >= 5 then
            table.sort(Monitored_Items, compareAmount)
            _Monitor.write("Common Items: ")
            _Monitor.setCursorPos(w/2+8,18)
            _Monitor.write(Monitored_Items[1].displayName..": "..Monitored_Items[1].amount.."        ")
            _Monitor.setCursorPos(w/2+8,19)
            _Monitor.write(Monitored_Items[2].displayName..": "..Monitored_Items[2].amount.."        ")
            _Monitor.setCursorPos(w/2+8,20)
            _Monitor.write(Monitored_Items[3].displayName..": "..Monitored_Items[3].amount.."        ")
            _Monitor.setCursorPos(w/2+8,21)
            _Monitor.write(Monitored_Items[4].displayName..": "..Monitored_Items[4].amount.."        ")
            _Monitor.setCursorPos(w/2+8,22)
            _Monitor.write(Monitored_Items[5].displayName..": "..Monitored_Items[5].amount.."        ")
        end



        _Monitor.setCursorPos(w/2+50,10)
        _Monitor.write("Crafting CPUs: "..table.getn(crafting_cpus).."        ")
        _Monitor.setCursorPos(w/2+50,12)
        _Monitor.write("Current Jobs:")
        if table.getn(crafting) > 0 then
            for y=13,math.min(13+9, 12+table.getn(crafting)) do
                _Monitor.setCursorPos(w/2+52,y)
                _Monitor.write(crafting[y-12].displayName..": "..crafting[y-12].amount.."                     ")
            end
            for y=13+table.getn(crafting),13+9 do
                _Monitor.setCursorPos(w/2+52,y)
                _Monitor.write("                                          ")
            end
        end
        if table.getn(crafting) == 0 then
            _Monitor.setCursorPos(w/2+52,13)
            _Monitor.write("No Jobs Currently...")
        end
        for y=14+table.getn(crafting),14+8 do
            _Monitor.setCursorPos(w/2+52,y)
            _Monitor.write("                                          ")
        end


        width = w/2 / #_farm_motors
        
        bigfont.writeOn(_Monitor, 1, "CROP FRAMS",w/2+30,25)

        for i,v in ipairs(_farm_motors) do
            x = i - 0.5
            if v.rpm == 0 then
                _Monitor.setBackgroundColour(colours.red)
                _Monitor.setTextColour(colours.white)
            else
                _Monitor.setBackgroundColour(colours.green)
                _Monitor.setTextColour(colours.black)
            end
            _Monitor.setCursorPos(w/2+4 + x*width,29)
            _Monitor.write(string.rep(" ", 4))
            _Monitor.setCursorPos(w/2+3 + x*width,30)
            _Monitor.write(string.rep(" ", 6))
            _Monitor.setCursorPos(w/2+2 + x*width,31)
            _Monitor.write(string.rep(" ", 8))
            _Monitor.setCursorPos(w/2+2 + x*width,32)
            _Monitor.write(string.rep(" ", 8))
            _Monitor.setCursorPos(w/2+4 + x*width,35)
            _Monitor.write(string.rep(" ", 4))
            _Monitor.setCursorPos(w/2+3 + x*width,34)
            _Monitor.write(string.rep(" ", 6))
            _Monitor.setCursorPos(w/2+2 + x*width,33)
            _Monitor.write(string.rep(" ", 8))

            _Monitor.setCursorPos(w/2+4 + x*width,31)
            _Monitor.write("Farm")
            _Monitor.setCursorPos(w/2+6 - math.floor(string.len(string.format("%02d",i))/2) + x*width,32)
            _Monitor.write(string.format("%02d",i))
            _Monitor.setCursorPos(w/2+6 - math.floor(string.len(v.rpm.." RPM")/2) + x*width,33)
            _Monitor.write(v.rpm.." RPM")
            
            _Monitor.setBackgroundColour(colours.black)
            _Monitor.setTextColour(colours.white)
            _Monitor.setCursorPos(w/2+6 - math.floor(string.len(v.crop)/2) + x*width,37)
            _Monitor.write(v.crop)
        end

        _Monitor.setBackgroundColour(colours.black)
        _Monitor.setTextColour(colours.white)

        if page == 1 then
            bigfont.writeOn(_Monitor, 1, "CC Network",28,4)
            _Monitor.setCursorPos(2,11)
            _Monitor.write("Detected Devices: ")
            y = 12
            for key, value in orderedPairs(network.types) do
                _Monitor.setCursorPos(4,y)
                _Monitor.write(string.format("%s:%s", key, value..string.rep(" ",20)))
                y = y+1
            end
            _Monitor.setCursorPos(34,11)
            _Monitor.write("Network Services: ")
            y = 12
            _Monitor.setCursorPos(36,y)
            _Monitor.write("NO SERVICS CURRENTLY MONITORED")
--            for key, value in orderedPairs(network.types) do
--                _Monitor.setCursorPos(36,y)
--                _Monitor.write(string.format("%s:%s", key, value..string.rep(" ",20)))
--                y = y+1
--            end
        end
        if page == 2 then
            bigfont.writeOn(_Monitor, 1, "Lithium Production",20,4)
        end


        x = 1
        for i,v in ipairs(pages) do
            _Monitor.setBackgroundColour(colors.lightGray)
            _Monitor.setTextColour(colors.gray)
            
            if (x + 2 + #v.name > w/2-4) then
                _Monitor.setCursorPos(x,h)
                _Monitor.write("...")
                break
            else
                if page == i then
                    _Monitor.setBackgroundColour(colors.gray)
                    _Monitor.setTextColour(colors.lightGray)
                end
                _Monitor.setCursorPos(x,h)
                _Monitor.write(" "..v.name.." ")
                x = x + 2 + #v.name
            end
        end
        if (x < w/2-1) then
            _Monitor.setBackgroundColour(colors.lightGray)
            _Monitor.setTextColour(colors.gray)
            _Monitor.setCursorPos(x,h)
            _Monitor.write(string.rep(" ", w/2-x))
        end
        _Monitor.setBackgroundColour(colours.black)
        _Monitor.setTextColour(colours.white)


        frameCounter = frameCounter + 1
        if frameCounter > 8 then
            page = page + 1
            frameCounter = 1
            if page > table.getn(pages) then
                page = 1
            end
            for y=1,h-1 do
                _Monitor.setBackgroundColour(colours.black)
                _Monitor.setTextColour(colours.white)
                _Monitor.setCursorPos(1,y)
                _Monitor.write(string.rep(" ", w/2-1))
            end
        end

        _Monitor.setCursorPos(w-1,h)
        if ticker then
            _Monitor.write("# ")
            ticker = false
        else
            _Monitor.write(" #")
            ticker = true
        end

        os.sleep(0.5)
    end
end

parallel.waitForAny(eToExit,drawLoop, grabMEData, monitorFarms, monitorNetwork)