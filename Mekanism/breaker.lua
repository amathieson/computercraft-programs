-- Monitoring for Power Systems


DiskName = "disk"
ComputerName = peripheral.call("bottom","getNameLocal"):gsub("computer_", "")
print("Monitoring:"..ComputerName)

while (true) do
    if (fs.exists(DiskName.."/power_systems/breakers/"..ComputerName)) then
        redstone.setOutput("back", true)
    else
        redstone.setOutput("back", false)
    end
    os.sleep(0.1)
end