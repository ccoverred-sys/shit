local Movement = {}

function Movement:Init(Window)
    local Tab = Window:CreateTab("Movement")
    local Sector = Tab:CreateSector("Air Controls", "Left")
    
    -- Конфиг модуля
    local Config = {
        Fly = false,
        Speed = 50,
        Jump = false
    }

    -- 1. Полет
    Sector:AddToggle("Fly Hack", false, function(state)
        Config.Fly = state
    end)

    -- 2. Скорость полета
    Sector:AddSlider("Fly Speed", 10, 300, 50, 1, function(v)
        Config.Speed = v
    end)

    -- 3. Бесконечный прыжок
    Sector:AddToggle("Infinite Jump", false, function(state)
        Config.Jump = state
    end)

    -- ЛОГИКА (Loop)
    game:GetService("RunService").RenderStepped:Connect(function()
        local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if Config.Fly and root then
            local cam = workspace.CurrentCamera.CFrame
            local dir = Vector3.new(0,0,0)
            local UIS = game:GetService("UserInputService")
            
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.LookVector end
            
            root.Velocity = dir * Config.Speed
            root.Anchored = (dir.Magnitude == 0)
        elseif root and root.Anchored then
            root.Anchored = false
        end
    end)

    game:GetService("UserInputService").JumpRequest:Connect(function()
        if Config.Jump then
            local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum:ChangeState("Jumping") end
        end
    end)

    return Movement
end

return Movement
