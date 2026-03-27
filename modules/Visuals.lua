local Visuals = {}

function Visuals:Init(Window)
    if not Window then return end

    local Tab = Window:CreateTab("Visuals")
    local Sector = Tab:CreateSector("Elite Chams", "Left")
    
    local Config = {
        Enabled = false,
        FillColor = Color3.fromRGB(255, 0, 0),
        OutlineColor = Color3.fromRGB(255, 255, 255),
        Mode = "AlwaysOnTop"
    }

    -- 1. ТУМБЛЕР (Включение)
    Sector:AddToggle("Enable Elite Visuals", false, function(state)
        Config.Enabled = state
        if not state then
            -- Мгновенная очистка при выключении
            for _, p in ipairs(game.Players:GetPlayers()) do
                if p.Character then
                    local h = p.Character:FindFirstChild("EliteHighlight")
                    if h then h:Destroy() end
                end
            end
        end
    end)

    -- 2. ДРОПДАУН (Исправленный синтаксис для кликабельности)
    -- В этой либе: Name, Options (Table), Callback
    local modes = {"AlwaysOnTop", "Occluded"}
    Sector:AddDropdown("Visual Mode", modes, function(selected)
        Config.Mode = selected
        print("[!] Mode changed to: " .. selected)
    end)

    -- 3. ПАЛИТРА (ColorPicker)
    Sector:AddColorPicker("Fill Color", Color3.fromRGB(255, 0, 0), function(color)
        Config.FillColor = color
    end)

    -- 4. ОКРУЖЕНИЕ
    local WorldSector = Tab:CreateSector("Environment", "Right")
    WorldSector:AddButton("Full Bright", function()
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 14
        game:GetService("Lighting").GlobalShadows = false
    end)

    -- ЛОГИКА РЕНДЕРА (Highlight System - Самые мощные чамсы)
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
                
                -- Визуальные настройки
                highlight.FillColor = Config.FillColor
                highlight.OutlineColor = Config.OutlineColor
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                
                -- Просвет сквозь стены
                if Config.Mode == "AlwaysOnTop" then
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                else
                    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
                end
            end
        end
    end)

    return Visuals
end

return Visuals
