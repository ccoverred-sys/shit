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

    -- 1. ГЛАВНЫЙ ВКЛЮЧАТЕЛЬ
    ChamsSector:CreateToggle("Enable Material Chams", false, function(state)
        Settings.Enabled = state
        if not state then
            VisualsModule:ResetChams()
        end
    end)

    -- 2. DROPDOWN (Выбор материала)
    -- В этой либе: CreateDropdown(Name, Options, Default, Callback)
    ChamsSector:CreateDropdown("Select Material", {"ForceField", "Neon", "Glass", "Ice", "Wood", "Diamond"}, "ForceField", function(selected)
        Settings.Material = Enum.Material[selected]
    end)

    -- 3. COLORPICKER (Выбор любого цвета)
    -- В этой либе: CreateColorpicker(Name, Default, Callback)
    ChamsSector:CreateColorpicker("Chams Color", Color3.fromRGB(255, 0, 0), function(newColor)
        Settings.Color = newColor
        Settings.Rainbow = false -- Выключаем радугу, если выбрали цвет вручную
    end)

    -- 4. ЭФФЕКТЫ
    ChamsSector:CreateToggle("Rainbow Mode", false, function(state)
        Settings.Rainbow = state
    end)

    -- 5. ОКРУЖЕНИЕ
    WorldSector:CreateButton("Full Bright", function()
        local Light = game:GetService("Lighting")
        Light.Brightness = 2
        Light.ClockTime = 14
        Light.GlobalShadows = false
    end)

    -- ФУНКЦИЯ СБРОСА (Internal)
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

    -- ЦИКЛ РЕНДЕРИНГА (Fast Update)
    game:GetService("RunService").RenderStepped:Connect(function()
        if not Settings.Enabled then return end
        
        if Settings.Rainbow then
            Settings.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        end
        
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player ~= game:GetService("Players").LocalPlayer and player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        if not part:GetAttribute("OrigColor") then
                            part:SetAttribute("OrigColor", part.Color)
                        end
                        
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
