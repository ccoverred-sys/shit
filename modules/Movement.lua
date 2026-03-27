local MoveModule = {}

function MoveModule:Init(Window)
    local Tab = Window:CreateTab("Movement")
    local Sector = Tab:CreateSector("Air Controls", "Left")
    
    Sector:AddToggle("Fly Hack", false, function(s) 
        print("Fly is now: " .. tostring(s))
    end)
    
    Sector:AddSlider("Fly Speed", 10, 300, 50, 1, function(v) end)
    
    return MoveModule
end

return MoveModule
