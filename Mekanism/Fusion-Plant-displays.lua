_Turbines = {
    peripheral.wrap("turbineValve_1"),
    peripheral.wrap("turbineValve_2"),
    peripheral.wrap("turbineValve_3"),
    peripheral.wrap("turbineValve_6"),
    peripheral.wrap("turbineValve_5"),
    peripheral.wrap("turbineValve_4")
}

_TurbinesPerSide = 3

_TurbineMonitors = {
    peripheral.wrap("monitor_33"),
    peripheral.wrap("monitor_32")
}

_Turbine_Data = {
    {
        ProductionRate=0,
        MaxProduction=0,
        FlowRate=0,
        MaxFlowRate=0,
        Steam=0,
        SteamCapacity=0,
        SteamNeeded=0,
        Name="",
        Formed=false
    },
    {
        ProductionRate=0,
        MaxProduction=0,
        FlowRate=0,
        MaxFlowRate=0,
        Steam=0,
        SteamCapacity=0,
        SteamNeeded=0,
        Name="",
        Formed=false
    },
    {
        ProductionRate=0,
        MaxProduction=0,
        FlowRate=0,
        MaxFlowRate=0,
        Steam=0,
        SteamCapacity=0,
        SteamNeeded=0,
        Name="",
        Formed=false
    },
    {
        ProductionRate=0,
        MaxProduction=0,
        FlowRate=0,
        MaxFlowRate=0,
        Steam=0,
        SteamCapacity=0,
        SteamNeeded=0,
        Name="",
        Formed=false
    },
    {
        ProductionRate=0,
        MaxProduction=0,
        FlowRate=0,
        MaxFlowRate=0,
        Steam=0,
        SteamCapacity=0,
        SteamNeeded=0,
        Name="",
        Formed=false
    },
    {
        ProductionRate=0,
        MaxProduction=0,
        FlowRate=0,
        MaxFlowRate=0,
        Steam=0,
        SteamCapacity=0,
        SteamNeeded=0,
        Name="",
        Formed=false
    }
}

_LaserAmplifier = peripheral.wrap("laserAmplifier_0")

_Center_Monitor = peripheral.wrap("monitor_28")
_Reactor = peripheral.wrap("fusionReactorLogicAdapter_1")
_ManagmentPath = "/disk2/fusion_plant/manager_state"

reactor_State = {
    Formed=false,
    Fluids={
        Water={
            amount=0,
            name=""
        },
        Steam={
            amount=0,
            name=""
        },
        Tritium={
            amount=0,
            name=""
        },
        Deuterium={
            amount=0,
            name=""
        },
        DT={
            amount=0,
            name=""
        }
    },
    Temps={
        Plasma=0,
        Case=0
    },
    Efficiency=0
}
laserStoredPower = 0
managmentState = "-OFFLINE-"

function grabData()
    while(true) do
        for i, turbine in ipairs(_Turbines) do
            if (turbine.isFormed()) then
                _Turbine_Data[i] = {
                    ProductionRate=turbine.getProductionRate()*0.4,
                    MaxProduction=turbine.getMaxProduction(),
                    FlowRate=turbine.getFlowRate(),
                    MaxFlowRate=turbine.getMaxFlowRate(),
                    Steam=turbine.getSteam(),
                    SteamCapacity=turbine.getSteamCapacity(),
                    SteamNeeded=turbine.getSteamNeeded(),
                    Name=peripheral.getName(turbine),
                    Formed=turbine.isFormed()
                }
            else
                _Turbine_Data[i] = {
                    ProductionRate=0,
                    MaxProduction=0,
                    FlowRate=0,
                    MaxFlowRate=0,
                    Steam=0,
                    SteamCapacity=0,
                    SteamNeeded=0,
                    Name=peripheral.getName(turbine),
                    Formed=turbine.isFormed()
                }
            end
        end
        laserStoredPower = _LaserAmplifier.getEnergy()*0.4
        --file = io.open(_ManagmentPath, "r")
        --managmentState = file.read(file)
        --io.close(file)
        if _Reactor.isFormed() then
            reactor_State_tmp = {
                Formed=_Reactor.isFormed(),
                Fluids={
                    Water=_Reactor.getWater(),
                    Steam=_Reactor.getSteam(),
                    Tritium=_Reactor.getTritium(),
                    Deuterium=_Reactor.getDeuterium(),
                    DT=_Reactor.getDTFuel()
                },
                Temps={
                    Plasma=_Reactor.getPlasmaTemperature(),
                    Case=_Reactor.getCaseTemperature()
                },
                Efficiency=_Reactor.getEfficiency()
            }
            reactor_State = reactor_State_tmp
        else
            reactor_State.Formed = false
        end

    end
end


os.loadAPI("bigfont")
ticker = false
function drawLoop()
    while (true) do
        for i,monit in ipairs(_TurbineMonitors) do
            monit.setTextScale(0.8)
            monit.setBackgroundColour(colours.black)
            monit.setTextColour(colors.white)
            w,h = monit.getSize()
            for j = 0,_TurbinesPerSide-1 do
                turbine = _Turbine_Data[j+1+(i-1)*_TurbinesPerSide]
                monit.setBackgroundColour(colors.lightGray)
                monit.setTextColour(colors.gray)
                tw = bigfont.makeBlittleText(2, string.sub(turbine.Name, 14),1,1).width
                for y = h/_TurbinesPerSide*j+1,h/_TurbinesPerSide*(j+1) do
                    monit.setCursorPos(1, y)
                    monit.write(string.rep(" ", tw+1))
                end
                bigfont.writeOn(monit, 2, string.sub(turbine.Name, 14),2, h/_TurbinesPerSide*j+3)


                if not (turbine.Formed == true) then
                    monit.setBackgroundColour(colors.red)
                    monit.setTextColour(colors.white)
                    for y = h/_TurbinesPerSide*j+1,h/_TurbinesPerSide*(j+1) do
                        monit.setCursorPos(tw+2, y)
                        monit.write(string.rep(" ", w-tw))
                    end
                    monit.setCursorPos(tw+1 + ((w-tw)/2-9), h/_TurbinesPerSide*j+2)
                    monit.write("TURBINE NOT FORMED")
                else
                    monit.setBackgroundColour(colors.gray)
                    monit.setTextColour(colors.white)
                    for y = h/_TurbinesPerSide*j+1,h/_TurbinesPerSide*(j+1) do
                        monit.setCursorPos(tw+2, y)
                        monit.write(string.rep(" ", w-tw))
                    end
                    y = h/_TurbinesPerSide*j+2
                    monit.setCursorPos(tw+3, y+0)
                    monit.write("Production: "..turbine.ProductionRate.."          ")
                    monit.setCursorPos(tw+3, y+1)
                    monit.write("Max Production: "..turbine.MaxProduction.."          ")
                    monit.setCursorPos(tw+3, y+2)
                    monit.write("Flow Rate: "..turbine.FlowRate.."          ")
                    monit.setCursorPos(tw+3, y+3)
                    monit.write("Max Flow Rate: "..turbine.MaxFlowRate.."          ")
                    monit.setCursorPos(tw+3, y+4)
                    monit.write("Steam: "..turbine.Steam.amount.."          ")
                    monit.setCursorPos(tw+3, y+5)
                    monit.write("Steam Type:"..turbine.Steam.name.."          ")
                    monit.setCursorPos(tw+3, y+6)
                    monit.write("Steam Capacity: "..turbine.SteamCapacity.."          ")
                    monit.setCursorPos(tw+3, y+7)
                    monit.write("Steam Needed: "..turbine.SteamNeeded.."          ")
                end
            end
            for j = 1,_TurbinesPerSide-1 do
                monit.setCursorPos(1, h/_TurbinesPerSide*j)
                monit.setBackgroundColour(colours.black)
                monit.setTextColour(colors.white)
                monit.write(string.rep("-", w))
            end
            monit.setCursorPos(1, h)
            monit.write("Monitoring "..table.getn(_Turbines).." Turbines...")

            monit.setCursorPos(w-1, h)
            if ticker then
                monit.write(" #")
            else
                monit.write("# ")
            end
        end

        
        _Center_Monitor.setTextScale(0.5)
        _Center_Monitor.setBackgroundColour(colours.black)
        _Center_Monitor.setTextColour(colors.white)
        w,h = _Center_Monitor.getSize()

        for y = 1, h-1 do
            _Center_Monitor.setCursorPos(1,y)
            _Center_Monitor.blit(
                string.rep(" ",w),
                string.rep("0",w),
                string.rep("8",w/3)..string.rep("7",w/3+1)..string.rep("8",w/3)
            )
            y = y + 1
        end
        _Center_Monitor.setBackgroundColour(colors.lightGray)
        _Center_Monitor.setTextColour(colors.gray)
        _Center_Monitor.setCursorPos(10,1)
        _Center_Monitor.write("Laser Amplifier")

        _Center_Monitor.setCursorPos(2,2)
        _Center_Monitor.write("Stored Energy: "..math.floor(laserStoredPower/1000).."kFE       ")

        _Center_Monitor.setCursorPos((w/3*2)+14,1)
        _Center_Monitor.write("Fluids State")
        _Center_Monitor.setCursorPos((w/3*2)+3,2)
        _Center_Monitor.write("Water:")
        _Center_Monitor.setCursorPos((w/3*2)+5,3)
        _Center_Monitor.write(reactor_State.Fluids.Water.name:gsub("mekanismgenerators","mekgen")..": "..math.floor(reactor_State.Fluids.Water.amount/1000).."b          ")
        _Center_Monitor.setCursorPos((w/3*2)+3,4)
        _Center_Monitor.write("Tritium:")
        _Center_Monitor.setCursorPos((w/3*2)+5,5)
        _Center_Monitor.write(reactor_State.Fluids.Tritium.name:gsub("mekanismgenerators","mekgen")..": "..math.floor(reactor_State.Fluids.Tritium.amount/1000).."b          ")
        _Center_Monitor.setCursorPos((w/3*2)+3,6)
        _Center_Monitor.write("Deuterium:")
        _Center_Monitor.setCursorPos((w/3*2)+5,7)
        _Center_Monitor.write(reactor_State.Fluids.Deuterium.name:gsub("mekanismgenerators","mekgen")..": "..math.floor(reactor_State.Fluids.Deuterium.amount/1000).."b          ")
        _Center_Monitor.setCursorPos((w/3*2)+3,8)
        _Center_Monitor.write("D-T Fuel:")
        _Center_Monitor.setCursorPos((w/3*2)+5,9)
        _Center_Monitor.write(reactor_State.Fluids.DT.name:gsub("mekanismgenerators","mekgen")..": "..math.floor(reactor_State.Fluids.DT.amount/1000).."b          ")
        _Center_Monitor.setBackgroundColour(colors.gray)
        _Center_Monitor.setTextColour(colors.lightGray)
        _Center_Monitor.setCursorPos((w/3)+12,1)
        _Center_Monitor.write("Reactor State")
        _Center_Monitor.setCursorPos((w/3)+2,2)
        _Center_Monitor.write("Temperatures:")
        _Center_Monitor.setCursorPos((w/3)+4,3)
        _Center_Monitor.write("Case: "..math.floor(reactor_State.Temps.Case).."K          ")
        _Center_Monitor.setCursorPos((w/3)+4,4)
        _Center_Monitor.write("Plasma: "..math.floor(reactor_State.Temps.Plasma).."K          ")
        _Center_Monitor.setCursorPos((w/3)+2,5)
        _Center_Monitor.write("Efficiency: "..math.floor(reactor_State.Efficiency).."          ")

        
        _Center_Monitor.setBackgroundColour(colours.black)
        _Center_Monitor.setTextColour(colors.white)
        _Center_Monitor.setCursorPos(1,h)
        --_Center_Monitor.write("Reactor Monitoring: "..managmentState)
        _Center_Monitor.setCursorPos(w-1, h)
        if ticker then
            _Center_Monitor.write(" #")
        else
            _Center_Monitor.write("# ")
        end

        ticker = not ticker
        os.sleep(0.5)
    end
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
_Center_Monitor.clear()
for i,monit in ipairs(_TurbineMonitors) do
    monit.clear()
end
parallel.waitForAny(eToExit,drawLoop,grabData)
