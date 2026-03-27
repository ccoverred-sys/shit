local VisualsModule = {}

function VisualsModule:Init(Window)
    local Tab = Window:CreateTab("Visuals")
    local ChamsSector = Tab:CreateSector("Elite Chams", "Left")
    local WorldSector = Tab:CreateSector("Environment", "Right")
    
    local Settings = {
        Enabled = false,
        Material = Enum.Material.ForceField, -- ForceField дает X-Ray эффект
        Color = Color3.fromRGB(255, 0, 0),
        Transparency = 0.5
    }

    -- 1. ВКЛЮЧЕНИЕ ЧАМСОВ
    ChamsSector:AddToggle("Enable Material Chams", false, function(state)
        Settings.Enabled = state
        if not state then
            VisualsModule:ResetAll()
        end
    end)

    -- 2. ВЫБОР МАТЕРИАЛА (Neon или ForceField)
    ChamsSector:AddButton("Mode: X-Ray (ForceField)", function()
        Settings.Material = Enum.Material.ForceField
    end)

    ChamsSector:AddButton("Mode: Glow (Neon)", function()
        Settings.Material = Enum.Material.Neon
    end)

    -- 3. ЦВЕТА
    ChamsSector:AddButton("Color: Red", function() Settings.Color = Color3.fromRGB(255, 0, 0) end)
    ChamsSector:AddButton("Color: Cyan", function() Settings.Color = Color3.fromRGB(0, 255, 255) end)

    -- 4. ОКРУЖЕНИЕ
    WorldSector:AddButton("Full Bright", function()
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 14
        game:GetService("Lighting").GlobalShadows = false
    end)

    -- ФУНКЦИЯ ОЧИСТКИ (Возврат оригинальных материалов)
    function VisualsModule:ResetAll()
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Material = Enum.Material.Plastic -- Дефолтный пластик
                        part.Color = part:GetAttribute("OrigColor") or part.Color
                        part.Transparency = 0
                    end
                end
            end
        end
    end

    -- СИСТЕМНЫЙ ЦИКЛ (RenderStepped для плавности)
    game:GetService("RunService").RenderStepped:Connect(function()
        if not Settings.Enabled then return end
        
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        -- Сохраняем оригинал один раз
                        if not part:GetAttribute("OrigColor") then
                            part:SetAttribute("OrigColor", part.Color)
                        end
                        
                        -- Применяем Элитные Чамсы
                        part.Material = Settings.Material
                        part.Color = Settings.Color
                        part.Transparency = Settings.Transparency
                        -- ForceField на отрицательной прозрачности дает "свечение"
                        if Settings.Material == Enum.Material.ForceField then
                            part.Transparency = -1 
                        end
                    end
                end
            end
        end
    end)

    return VisualsModule
end

return VisualsModule
