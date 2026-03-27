local VisualsModule = {}

function VisualsModule:Init(Window)
    local Tab = Window:CreateTab("Visuals")
    local ESPSector = Tab:CreateSector("ESP & Chams", "Left")
    local WorldSector = Tab:CreateSector("Environment", "Right")
    
    local Settings = {
        Chams = false,
        Boxes = false,
        FullBright = false
    }

    -- 1. CHAMS (Highlight System)
    ESPSector:AddToggle("Elite Chams", false, function(state)
        Settings.Chams = state
    end)

    -- 2. ESP BOXES (Highlight-based)
    ESPSector:AddToggle("Player ESP", false, function(state)
        Settings.Boxes = state
    end)

    -- 3. FULL BRIGHT
    WorldSector:AddButton("Full Bright", function()
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 14
        game:GetService("Lighting").GlobalShadows = false
    end)

    -- СИСТЕМНЫЙ ЦИКЛ ОБНОВЛЕНИЯ (Fast Loop)
    task.spawn(function()
        while task.wait(1) do
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character then
                    local char = player.Character
                    local hl = char:FindFirstChild("EliteVisuals") or Instance.new("Highlight", char)
                    hl.Name = "EliteVisuals"
                    
                    -- Настройка видимости
                    hl.Enabled = (Settings.Chams or Settings.Boxes)
                    hl.FillTransparency = Settings.Chams and 0.5 or 1
                    hl.OutlineTransparency = Settings.Boxes and 0 or 1
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            end
        end
    end)

    return VisualsModule
end

return VisualsModule
