local Visuals = {}

function Visuals:Init(Window)
    if not Window then return end

    local Tab = Window:CreateTab("Visuals")
    local Sector = Tab:CreateSector("Elite Chams", "Left")
    
    local Config = {
        Enabled = false,
        FillColor = Color3.fromRGB(255, 0, 0),
        OutlineColor = Color3.fromRGB(255, 255, 255),
        Mode = "AlwaysOnTop" -- Режим видимости сквозь стены
    }

    -- 1. ТУМБЛЕР (Включение)
    Sector:AddToggle("Enable Elite Visuals", false, function(state)
        Config.Enabled = state
        if not state then
            -- Мгновенная очистка всех эффектов
            for _, p in ipairs(game.Players:GetPlayers()) do
                if p.Character then
                    local h = p.Character:FindFirstChild("EliteHighlight")
                    if h then h:Destroy() end
                end
            end
        end
    end)

    -- 2. ДРОПДАУН (Материалы/Режимы)
    -- В этой либе для работы списка нужно передавать таблицу ПРЯМЫМ аргументом
    local modes = {"AlwaysOnTop", "Occluded", "OutlineOnly"}
    Sector:AddDropdown("Visual Mode", modes, "AlwaysOnTop", function(selected)
        Config.Mode = selected
    end)

    -- 3. ЦВЕТ ЗАЛИВКИ (ColorPicker)
    Sector:AddColorPicker("Fill Color", Color3.fromRGB(255, 0, 0), function(color)
        Config.FillColor = color
    end)

    -- 4. ЦВЕТ КОНТУРА (ColorPicker)
    Sector:AddColorPicker("Outline Color", Color3.fromRGB(255, 255, 255), function(color)
        Config.OutlineColor = color
    end)

    -- 5. ОКРУЖЕНИЕ
    local WorldSector = Tab:CreateSector("Environment", "Right")
    WorldSector:AddButton("Full Bright", function()
        local Lighting = game:GetService("Lighting")
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.ExposureCompensation = 0.5
    end)

    -- ЛОГИКА ОБНОВЛЕНИЯ (Elite Highlighting)
    -- Это намного стабильнее и красивее, чем смена материалов
    game:GetService("RunService").Heartbeat:Connect(function()
        if not Config.Enabled then return end
        
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character then
                local char = player.Character
                local highlight = char:FindFirstChild("EliteHighlight")
                
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "EliteHighlight"
                    highlight.Parent = char
                end
                
                -- Настройка визуалов
                highlight.FillColor = Config.FillColor
                highlight.OutlineColor = Config.OutlineColor
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                
                -- Режим "сквозь стены"
                if Config.Mode == "AlwaysOnTop" then
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                else
                    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
                end

                if Config.Mode == "OutlineOnly" then
                    highlight.FillTransparency = 1
                end
            end
        end
    end)

    return Visuals
end

return Visuals
