local VisualsModule = {}

function VisualsModule:Init(Window)
    local Tab = Window:CreateTab("Visuals")
    local ChamsSector = Tab:CreateSector("Elite Chams", "Left")
    local WorldSector = Tab:CreateSector("Environment", "Right")
    
    local Settings = {
        Enabled = false,
        Material = Enum.Material.ForceField,
        Color = Color3.fromRGB(255, 0, 0),
        Transparency = 0.5
    }

    -- 1. ПЕРЕКЛЮЧАТЕЛЬ ЧАМСОВ
    ChamsSector:AddToggle("Material Chams", false, function(state)
        Settings.Enabled = state
        if not state then
            -- Возврат к норме при выключении
            for _, p in ipairs(game.Players:GetPlayers()) do
                if p.Character then
                    for _, v in ipairs(p.Character:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.Material = Enum.Material.Plastic
                            v.Transparency = 0
                            v.Color = v:GetAttribute("OrigColor") or v.Color
                        end
                    end
                end
            end
        end
    end)

    -- 2. РЕЖИМЫ ОТОБРАЖЕНИЯ
    ChamsSector:AddButton("Mode: X-Ray (ForceField)", function()
        Settings.Material = Enum.Material.ForceField
    end)

    ChamsSector:AddButton("Mode: Glow (Neon)", function()
        Settings.Material = Enum.Material.Neon
    end)

    -- 3. ПРЕСЕТЫ ЦВЕТОВ
    ChamsSector:AddButton("Color: Red", function() Settings.Color = Color3.fromRGB(255, 0, 0) end)
    ChamsSector:AddButton("Color: Cyan", function() Settings.Color = Color3.fromRGB(0, 255, 255) end)

    -- 4. ОКРУЖЕНИЕ
    WorldSector:AddButton("Full Bright", function()
        local Light = game:GetService("Lighting")
        Light.Brightness = 2
        Light.ClockTime = 14
        Light.GlobalShadows = false
    end)

    -- СИСТЕМНЫЙ ЦИКЛ РЕНДЕРИНГА (Fast Update)
    game:GetService("RunService").RenderStepped:Connect(function()
        if not Settings.Enabled then return end
        
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        -- Сохраняем оригинальный цвет
                        if not part:GetAttribute("OrigColor") then
                            part:SetAttribute("OrigColor", part.Color)
                        end
                        
                        -- Применяем эффекты
                        part.Material = Settings.Material
                        part.Color = Settings.Color
                        
                        -- Спецэффект для X-Ray
                        if Settings.Material == Enum.Material.ForceField then
                            part.Transparency = -1 
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
