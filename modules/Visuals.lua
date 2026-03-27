local VisualsModule = {}

function VisualsModule:Init(Window)
    if not Window then return end

    local Tab = Window:CreateTab("Visuals")
    local ChamsSector = Tab:CreateSector("Elite Chams", "Left")
    local WorldSector = Tab:CreateSector("Environment", "Right")
    
    local Settings = {
        Enabled = false,
        Material = Enum.Material.ForceField,
        Color = Color3.fromRGB(255, 0, 0),
        Transparency = 0.5,
        Rainbow = false
    }

    -- 1. ТУМБЛЕР (Toggle)
    ChamsSector:Toggle("Enable Material Chams", false, function(state)
        Settings.Enabled = state
        if not state then VisualsModule:ResetChams() end
    end)

    -- 2. ВЫПАДАЮЩИЙ СПИСОК (Dropdown)
    -- Аргументы: Name, List, Callback
    ChamsSector:Dropdown("Select Material", {"ForceField", "Neon", "Glass", "Ice", "Wood"}, function(selected)
        if Enum.Material[selected] then
            Settings.Material = Enum.Material[selected]
            print("[+] Material changed to: " .. selected)
        end
    end)

    -- 3. ВЫБОР ЦВЕТА (ColorPicker)
    -- Аргументы: Name, DefaultColor, Callback
    ChamsSector:ColorPicker("Chams Color", Color3.fromRGB(255, 0, 0), function(newColor)
        Settings.Color = newColor
        Settings.Rainbow = false
    end)

    -- 4. РАДУГА (Toggle)
    ChamsSector:Toggle("Rainbow Mode", false, function(state)
        Settings.Rainbow = state
    end)

    -- 5. ОКРУЖЕНИЕ (Button)
    WorldSector:Button("Full Bright", function()
        local Light = game:GetService("Lighting")
        Light.Brightness = 2
        Light.ClockTime = 14
        Light.GlobalShadows = false
    end)

    -- [ЛОГИКА ОЧИСТКИ]
    function VisualsModule:ResetChams()
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Material = Enum.Material.Plastic
                        part.Transparency = 0
                        part.Color = part:GetAttribute("OrigColor") or part.Color
                    end
                end
            end
        end
    end

    -- [ЛОГИКА РЕНДЕРА]
    game:GetService("RunService").RenderStepped:Connect(function()
        if not Settings.Enabled then return end
        if Settings.Rainbow then Settings.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end
        
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player ~= game:GetService("Players").LocalPlayer and player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        if not part:GetAttribute("OrigColor") then part:SetAttribute("OrigColor", part.Color) end
                        
                        part.Material = Settings.Material
                        part.Color = Settings.Color
                        
                        if Settings.Material == Enum.Material.ForceField then
                            part.Transparency = -1 
                        elseif Settings.Material == Enum.Material.Glass then
                            part.Transparency = 0.8
                        else
                            part.Transparency = Settings.Transparency
                        end
                    end
                end
            end
        end
    end)

    return VisualsModule
end

return VisualsModule
