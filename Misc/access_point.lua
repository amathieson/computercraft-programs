
args = {...}
print("Starting GPS Access Point At: "..args[1]..","..args[2]..","..args[3])

function runGPS()
    while true do
        shell.run("gps", "host", args[1], args[2], args[3])
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

parallel.waitForAny(eToExit,runGPS)