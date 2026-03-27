local Combat = {}

function Combat:Init(Window)
    local Tab = Window:CreateTab("Combat")
    local Sector = Tab:CreateSector("Aim Assist", "Left")
    
    local Config = {
        Enabled = false,
        Smoothness = 0.1,
        FOV = 150,
        TargetPart = "Head"
    }

    -- 1. Тумблер Аима
    Sector:AddToggle("Aim Lock", false, function(state)
        Config.Enabled = state
    end)

    -- 2. Плавность
    Sector:AddSlider("Smoothness", 1, 10, 2, 1, function(v)
        Config.Smoothness = v / 20
    end)

    -- 3. Радиус (FOV)
    Sector:AddSlider("Aim FOV", 50, 800, 150, 1, function(v)
        Config.FOV = v
    end)

    -- ЛОГИКА НАВОДКИ
    local Camera = workspace.CurrentCamera
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local function GetClosest()
        local target = nil
        local dist = Config.FOV
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Config.TargetPart) then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character[Config.TargetPart].Position)
                if onScreen then
                    local mouseDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if mouseDist < dist then
                        target = p.Character[Config.TargetPart]
                        dist = mouseDist
                    end
                end
            end
        end
        return target
    end

    game:GetService("RunService").RenderStepped:Connect(function()
        if Config.Enabled then
            local target = GetClosest()
            if target then
                local lookCF = CFrame.new(Camera.CFrame.Position, target.Position)
                Camera.CFrame = Camera.CFrame:Lerp(lookCF, Config.Smoothness)
            end
        end
    end)

    return Combat
end

return Combat
