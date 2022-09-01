-- Monitoring for Power Systems
os.loadAPI("bigfont") 


DiskName = "disk"
MonitorName = "monitor_4"


MonitorPeriph = peripheral.wrap(MonitorName)
w,h = MonitorPeriph.getSize()

MonitorPeriph.setBackgroundColour(colours.black)
MonitorPeriph.setTextColor(colours.white)
MonitorPeriph.clear()
MonitorPeriph.setTextScale(0.5)
bigfont.writeOn(MonitorPeriph, 1, "MAIN POWER SYSTEM",w/2-24,4)


Circuits = {}
hiX = 0
for line in io.lines(DiskName.."/power_systems/map.lua") do
    -- X,Y,Computer,EnergyMeter,Name,direction
    rowX, rowY, rowComputer, rowEnergyMeter, rowDirection, rowName = line:match("%s*(.-),%s*(.-),%s*(.-),%s*(.-),%s*(.-),%s*(.+)")
    Circuits[#Circuits + 1] = { ["x"] = rowX, ["y"] = rowY, ["computer"] = rowComputer, ["energyMeter"] = rowEnergyMeter, ["name"] = rowName, ["direction"] = rowDirection }
    if (tonumber(rowX) > hiX) then
        hiX = tonumber(rowX)
    end
end

dash = false

MonitorPeriph.setTextColor(colours.white)

MonitorPeriph.setCursorPos(2,h/2+2)
MonitorPeriph.write(string.rep("=", (w-2)))

MonitorPeriph.setCursorPos(2,h/2+4)
MonitorPeriph.write(string.rep("=", (w-2)))

while (true) do
    spacing = (w-5)/hiX
    BusBarEnergiesd = false

    for  _, circuit in ipairs(Circuits) do
        local x = tonumber(circuit["x"])
        local y = tonumber(circuit["y"])
        local computer = circuit["computer"]
        local energyMeter = circuit["energyMeter"]
        local name = circuit["name"]
        local direction = tonumber(circuit["direction"])
        local power = peripheral.call("energymeter_"..energyMeter,"getTransferRate")
        if (y == 0) then
            MonitorPeriph.setCursorPos(3+x*spacing,h/2+2)
            if (fs.exists(DiskName.."/power_systems/breakers/"..computer)) then
                MonitorPeriph.setTextColor(colours.red)
            else
                MonitorPeriph.setTextColor(colours.green)
            end
            MonitorPeriph.write("|")
            MonitorPeriph.setCursorPos(3+x*spacing,h/2+1)
            MonitorPeriph.write("|")
            MonitorPeriph.setCursorPos(3+x*spacing,h/2)
            if (direction > 0) then
                MonitorPeriph.write("V")
                if ((power > 0) or BusBarEnergiesd) then
                    BusBarEnergiesd = true
                end
            else
                MonitorPeriph.write("^")
            end
            MonitorPeriph.setTextColor(colours.white)
            MonitorPeriph.setCursorPos(3+x*spacing-1,h/2-1)
            MonitorPeriph.write(peripheral.call("energymeter_"..energyMeter,"getTransferRate"))
            if (#name > 7) then
                MonitorPeriph.setCursorPos(3+x*spacing-3,h/2-3)
                MonitorPeriph.write(name:sub(1,7))
                MonitorPeriph.setCursorPos(3+x*spacing-(#name-7)/2,h/2-2)
                MonitorPeriph.write(name:sub(8,#name))
            else
                MonitorPeriph.setCursorPos(3+x*spacing-#name/2,h/2-2)
                MonitorPeriph.write(name)
            end
        else
            MonitorPeriph.setCursorPos(3+x*spacing,h/2+4)
            if (fs.exists(DiskName.."/power_systems/breakers/"..computer)) then
                MonitorPeriph.setTextColor(colours.red)
            else
                MonitorPeriph.setTextColor(colours.green)
            end
            MonitorPeriph.write("|")
            MonitorPeriph.setCursorPos(3+x*spacing,h/2+5)
            MonitorPeriph.write("|")
            MonitorPeriph.setCursorPos(3+x*spacing,h/2+6)
            if (direction > 0) then
                MonitorPeriph.write("^")
                if ((power > 0) or BusBarEnergiesd) then
                    BusBarEnergiesd = true
                end
            else
                MonitorPeriph.write("V")
            end
            MonitorPeriph.setTextColor(colours.white)
            MonitorPeriph.setCursorPos(3+x*spacing-1,h/2+7)
            MonitorPeriph.write(power)
            if (#name > 7) then
                MonitorPeriph.setCursorPos(3+x*spacing-3,h/2+8)
                MonitorPeriph.write(name:sub(1,7))
                MonitorPeriph.setCursorPos(3+x*spacing-(#name-7)/2,h/2+9)
                MonitorPeriph.write(name:sub(8,#name))
            else
                MonitorPeriph.setCursorPos(3+x*spacing-#name/2,h/2+8)
                MonitorPeriph.write(name)
            end
        end
    end

    
    MonitorPeriph.setCursorPos(2,h/2+3)
    if (BusBarEnergiesd) then
        MonitorPeriph.setTextColor(colours.green)
    else
        MonitorPeriph.setTextColor(colours.red)
    end

    if (dash) then
        MonitorPeriph.write(string.rep("- ", (w-2)/2))
    else
        MonitorPeriph.write(string.rep(" -", (w-2)/2))
    end
    dash = not dash

    os.sleep(0.1)
end
