local VisualsModule = {}

function VisualsModule:Init(Window)
    local Tab = Window:CreateTab("Visuals")
    local ChamsSector = Tab:CreateSector("Elite Chams", "Left")
    local WorldSector = Tab:CreateSector("Environment", "Right")
    
    local Settings = {
        Enabled = false,
        Material = Enum.Material.ForceField, -- Дефолтный X-Ray
        Color = Color3.fromRGB(255, 0, 0),
        Transparency = 0.5,
        Rainbow = false
    }

    -- 1. ГЛАВНЫЙ ВКЛЮЧАТЕЛЬ
    ChamsSector:AddToggle("Enable Material Chams", false, function(state)
        Settings.Enabled = state
        if not state then
            -- Мгновенный сброс всех эффектов при выключении
            for _, player in ipairs(game.Players:GetPlayers()) do
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
    end)

    -- 2. ВЫБОР МАТЕРИАЛА (Advanced Selection)
    ChamsSector:AddButton("Material: X-Ray (ForceField)", function()
        Settings.Material = Enum.Material.ForceField
    end)

    ChamsSector:AddButton("Material: Glow (Neon)", function()
        Settings.Material = Enum.Material.Neon
    end)

    ChamsSector:AddButton("Material: Ghost (Glass)", function()
        Settings.Material = Enum.Material.Glass
    end)

    ChamsSector:AddButton("Material: Frozen (Ice)", function()
        Settings.Material = Enum.Material.Ice
    end)

    -- 3. ЦВЕТОВАЯ ПАЛИТРА
    ChamsSector:AddButton("Color: Red", function() Settings.Color = Color3.fromRGB(255, 0, 0) end)
    ChamsSector:AddButton("Color: Cyan", function() Settings.Color = Color3.fromRGB(0, 255, 255) end)
    ChamsSector:AddButton("Color: Green", function() Settings.Color = Color3.fromRGB(0, 255, 0) end)
    
    ChamsSector:AddToggle("Rainbow Mode", false, function(state)
        Settings.Rainbow = state
    end)

    -- 4. НАСТРОЙКИ МИРА
    WorldSector:AddButton("Full Bright", function()
        local Light = game:GetService("Lighting")
        Light.Brightness = 2
        Light.ClockTime = 14
        Light.GlobalShadows = false
    end)

    -- СИСТЕМНЫЙ ЦИКЛ ОБНОВЛЕНИЯ (High-Frequency Render)
    game:GetService("RunService").RenderStepped:Connect(function()
        if not Settings.Enabled then return end
        
        -- Радужный эффект, если включен
        if Settings.Rainbow then
            Settings.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        end
        
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        -- Сохранение оригинала (однократно)
                        if not part:GetAttribute("OrigColor") then
                            part:SetAttribute("OrigColor", part.Color)
                        end
                        
                        -- Применение выбранного материала
                        part.Material = Settings.Material
                        part.Color = Settings.Color
                        
                        -- Спец-настройка прозрачности для материалов
                        if Settings.Material == Enum.Material.ForceField then
                            part.Transparency = -1 -- Тот самый X-Ray эффект
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
