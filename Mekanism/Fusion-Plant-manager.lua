_Reactor = peripheral.wrap("fusionReactorLogicAdapter_1")
_ManagmentPath = "/disk2/fusion_plant/manager_state"

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

lastEfficiency = 0
curEfficiency = 0
adjustment = 10
counter = 0
function monitor()
    while true do
        curEfficiency = _Reactor.getEfficiency()
        if curEfficiency > 0 then
            if lastEfficiency > curEfficiency then
                adjustment = -adjustment
            end
            _Reactor.adjustReactivity(((1-curEfficiency/100)*adjustment))
--            f = io.open(_ManagmentPath, "w")
  --          f.write("c:"..counter.."a:"..adjustment)
    --        f.close()
            print("Efficiency = " .. curEfficiency .. "\n" .. "Adjustment: " ..((1-curEfficiency/100)*adjustment))
            lastEfficiency = curEfficiency
            os.sleep(1)
        end
    end
end

parallel.waitForAny(eToExit,monitor)
