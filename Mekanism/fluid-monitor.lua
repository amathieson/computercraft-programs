_pipes = {
    {
        lane="Sector 0A",
        pipe=peripheral.wrap("eliteMechanicalPipe_0"),
        filled_percent=0,
        content={name="",amount=""},
        tank=peripheral.wrap("advancedFluidTank_0")
    },
    {
        lane="Sector 0B",
        pipe=peripheral.wrap("eliteMechanicalPipe_1"),
        filled_percent=0,
        content={name="",amount=""},
        tank=peripheral.wrap("advancedFluidTank_0")
    },
    {
    lane="Sector 1A",
    pipe=peripheral.wrap("ultimateMechanicalPipe_0"),
    filled_percent=0,
    content={name="",amount=""},
    tank=peripheral.wrap("advancedFluidTank_1")
    },
    {
    lane="Sector 1B",
    pipe=peripheral.wrap("ultimateMechanicalPipe_1"),
    filled_percent=0,
    content={name="",amount=""},
    tank=peripheral.wrap("advancedFluidTank_1")
    }
    
}

_Monitor = peripheral.wrap("monitor_27")
_Monitor.clear()
_Monitor.setTextScale(0.5)
w,h = _Monitor.getSize()


ticker = false

function drawLoop()
    while true do
    spacing = w/table.getn(_pipes)
    
    for i,pipe in ipairs(_pipes) do
        x = i-0.5
        _Monitor.setCursorPos(spacing*x-#pipe.lane/2,h/2)
        _Monitor.write(pipe.lane)
        _Monitor.setCursorPos(spacing*x-#pipe.content.name/2,h/2+1)
        _Monitor.write(pipe.content.name)
        _Monitor.setCursorPos(spacing*x-5,h/2+2)
        _Monitor.blit(string.rep("#",pipe.filled_percent/10)..string.rep(" ",10-pipe.filled_percent/10),
                      string.rep("b",pipe.filled_percent/10)..string.rep("7",10-pipe.filled_percent/10),
                      string.rep("b",pipe.filled_percent/10)..string.rep("7",10-pipe.filled_percent/10))
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

function monitorWater()
    while true do
        for i,pipe in ipairs(_pipes) do
            _pipes[i].filled_percent = pipe.pipe.getFilledPercentage()*100
            _pipes[i].content = pipe.tank.getStored()
        end
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


parallel.waitForAny(eToExit,drawLoop, monitorWater)
    
