local Visuals = {}

function Visuals:Init(Window)
    -- ПРИНУДИТЕЛЬНЫЙ ФИКС БАГА ЛИБЫ (Вставляем пустую таблицу флагов)
    if Window and not Window.Flags then
        Window.Flags = {}
    end

    local Tab = Window:CreateTab("Visuals")
    local Sector = Tab:CreateSector("Box ESP", "Left")
    
    local Config = {
        Enabled = false,
        BoxColor = Color3.fromRGB(255, 0, 0)
    }

    -- 1. ТУМБЛЕР (Только AddToggle, он самый стабильный)
    Sector:AddToggle("Enable Boxes", false, function(state)
        Config.Enabled = state
    end)

    -- 2. ВЫБОР ЦВЕТА
    Sector:AddColorPicker("Box Color", Color3.fromRGB(255, 0, 0), function(color)
        Config.BoxColor = color
    end)

    -- ==========================================
    -- ЭТАЛОННЫЙ ДВИЖОК BOX ESP (DRAWING API)
    -- ==========================================
    local function CreateEsp(player)
        local box = Drawing.new("Square")
        box.Visible = false
        box.Thickness = 1
        box.Filled = false
        box.Transparency = 1
        box.Color = Config.BoxColor

        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if Config.Enabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= game.Players.LocalPlayer then
                local root = player.Character.HumanoidRootPart
                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)

                if onScreen then
                    -- Расчет размера квадрата
                    local camPos = workspace.CurrentCamera.CFrame.Position
                    local dist = (camPos - root.Position).Magnitude
                    local scale = (1 / dist) * 1000
                    
                    box.Size = Vector2.new(scale * 1.6, scale * 1.9)
                    box.Position = Vector2.new(pos.X - box.Size.X / 2, pos.Y - box.Size.Y / 2)
                    box.Color = Config.BoxColor
                    box.Visible = true
                else
                    box.Visible = false
                end
            else
                box.Visible = false
                -- Удаление, если игрок ливнул
                if not player.Parent then
                    box:Remove()
                    connection:Disconnect()
                end
            end
        end)
    end

    -- Запуск для всех
    for _, p in ipairs(game.Players:GetPlayers()) do
        CreateEsp(p)
    end
    game.Players.PlayerAdded:Connect(CreateEsp)

    return Visuals
end

return Visuals
