local Visuals = {}

function Visuals:Init(Window)
    -- ФОРСИРОВАННЫЙ ФИКС БАГА БИБЛИОТЕКИ
    -- Мы вручную создаем таблицу флагов, чтобы либа не ломалась
    pcall(function()
        if Window and not Window.Flags then Window.Flags = {} end
        if Window and not Window.Keys then Window.Keys = {} end
    end)

    local Tab = Window:CreateTab("Visuals")
    local Sector = Tab:CreateSector("Box ESP", "Left")
    
    local Config = {
        Enabled = false,
        Color = Color3.fromRGB(255, 0, 0)
    }

    -- 1. ТУМБЛЕР (Самый простой метод)
    Sector:AddToggle("Enable Boxes", false, function(state)
        Config.Enabled = state
    end)

    -- 2. ЦВЕТ (ColorPicker)
    Sector:AddColorPicker("Box Color", Color3.fromRGB(255, 0, 0), function(color)
        Config.Color = color
    end)

    -- ==========================================
    -- ЭЛИТНЫЙ ДВИЖОК BOX ESP (DRAWING API)
    -- Работает отдельно от косяков UI библиотеки
    -- ==========================================
    local function CreateEsp(player)
        local box = Drawing.new("Square")
        box.Visible = false
        box.Thickness = 1
        box.Filled = false
        box.Transparency = 1
        box.Color = Config.Color

        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            -- Проверка: включен ли ESP и жив ли игрок
            if Config.Enabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= game.Players.LocalPlayer then
                local root = player.Character.HumanoidRootPart
                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)

                if onScreen then
                    -- Расчет дистанции для масштабирования бокса
                    local camPos = workspace.CurrentCamera.CFrame.Position
                    local dist = (camPos - root.Position).Magnitude
                    local scale = (1 / dist) * 1000
                    
                    box.Size = Vector2.new(scale * 1.6, scale * 1.9)
                    box.Position = Vector2.new(pos.X - box.Size.X / 2, pos.Y - box.Size.Y / 2)
                    box.Color = Config.Color
                    box.Visible = true
                else
                    box.Visible = false
                end
            else
                box.Visible = false
                -- Очистка ресурсов при выходе игрока
                if not player.Parent then
                    box:Remove()
                    connection:Disconnect()
                end
            end
        end)
    end

    -- Запуск движка для всех игроков
    for _, p in ipairs(game.Players:GetPlayers()) do
        CreateEsp(p)
    end
    game.Players.PlayerAdded:Connect(CreateEsp)

    return Visuals
end

return Visuals
