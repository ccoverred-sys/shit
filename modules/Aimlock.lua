local CombatModule = {}

function CombatModule:Init(Window)
    local Tab = Window:CreateTab("Combat")
    local Sector = Tab:CreateSector("Targeting", "Left")
    
    -- Внутренняя логика (AimLock)
    local Aim = { Enabled = false, Smoothness = 0.05 }
    
    Sector:AddToggle("Aim Lock", false, function(s) Aim.Enabled = s end)
    Sector:AddSlider("Smoothness", 1, 20, 5, 1, function(v) Aim.Smoothness = v/100 end)
    
    -- Твой код аимлока тут (RunService и т.д.)
    game:GetService("RunService").RenderStepped:Connect(function()
        if Aim.Enabled then 
            -- Логика наводки
        end
    end)
    
    return CombatModule
end

return CombatModule
