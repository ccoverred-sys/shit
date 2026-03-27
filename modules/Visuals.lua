local Visuals = {}

function Visuals:Init(Window)
    if not Window then return end

    -- Фикс для либы (затыкаем ошибку flags)
    if not Window.Flags then Window.Flags = {} end

    local Tab = Window:CreateTab("Visuals")
    local Sector = Tab:CreateSector("ESP Settings", "Left")
    
    local Config = {
        BoxEsp = false,
        BoxColor = Color3.fromRGB(255, 0, 0)
    }

    -- 1. ТУМБЛЕР (Включение Box ESP)
    Sector:AddToggle("Enable Box ESP", false, function(state)
        Config.BoxEsp = state
    end)

    -- 2. ЦВЕТ (Выбор цвета боксов)
    Sector:AddColorPicker("Box Color", Color3.fromRGB(255, 0, 0), function(color)
        Config.BoxColor = color
    end)

    -- 3. ОКРУЖЕНИЕ
    local WorldSector = Tab:CreateSector("Environment", "Right")
    WorldSector:AddButton("Full Bright", function()
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 14
    end)

    -- ==========================================
    -- ДВИЖОК ОТРИСОВКИ BOX ESP (Drawing API)
    -- ==========================================
    local function CreateEsp(player)
        local box = Drawing.new("Square")
        box.Visible = false
        box.Thickness = 1
        box.Filled = false
        box.Transparency = 1

        local function Update()
            local connection
            connection = game:GetService("RunService").RenderStepped:Connect(function()
                if Config.BoxEsp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= game.Players.LocalPlayer then
                    local root = player.Character.HumanoidRootPart
                    local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)

                    if onScreen then
                        local size = (workspace.CurrentCamera.CFrame.Position - root.Position).Magnitude
                        local scale = (1 / size) * 1000
                        
                        box.Size = Vector2.new(scale * 1.5, scale * 1.8)
                        box.Position = Vector2.new(pos.X - box.Size.X / 2, pos.Y - box.Size.Y / 2)
                        box.Color = Config.BoxColor
                        box.Visible = true
                    else
                        box.Visible = false
                    end
                else
                    box.Visible = false
                end
                
                -- Удаление при выходе игрока
                if not player.Parent then
                    box:Remove()
                    connection:Disconnect()
                end
            end)
        end
        coroutine.wrap(Update)()
    end

    -- Инициализация для всех
    for _, p in ipairs(game.Players:GetPlayers()) do
        CreateEsp(p)
    end
    game.Players.PlayerAdded:Connect(CreateEsp)

    return Visuals
end

return Visuals
