local VisualsModule = {}

function VisualsModule:Init(Window)
    -- Создаем вкладку и сектор (как в Movement)
    local Tab = Window:CreateTab("Visuals")
    local Sector = Tab:CreateSector("Elite Chams", "Left")
    
    local Settings = {
        Enabled = false,
        Material = Enum.Material.ForceField,
        Color = Color3.fromRGB(255, 0, 0)
    }

    -- 1. ТУМБЛЕР (Проверенный метод из Movement)
    Sector:AddToggle("Enable Chams", false, function(state)
        Settings.Enabled = state
        if not state then
            -- Сброс материалов при выключении
            pcall(function()
                for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                    if p.Character then
                        for _, v in ipairs(p.Character:GetDescendants()) do
                            if v:IsA("BasePart") then
                                v.Material = Enum.Material.Plastic
                                v.Transparency = 0
                            end
                        end
                    end
                end
            end)
        end
    end)

    -- 2. КНОПКИ СМЕНЫ РЕЖИМА (Вместо проблемного дропдауна)
    Sector:AddButton("Mode: X-Ray", function()
        Settings.Material = Enum.Material.ForceField
    end)

    Sector:AddButton("Mode: Neon Glow", function()
        Settings.Material = Enum.Material.Neon
    end)

    -- 3. ЦИКЛ ОБНОВЛЕНИЯ (RenderStepped)
    game:GetService("RunService").RenderStepped:Connect(function()
        if not Settings.Enabled then return end
        
        for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
            if p ~= game:GetService("Players").LocalPlayer and p.Character then
                for _, part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.Material = Settings.Material
                        part.Color = Settings.Color
                        -- Просвет сквозь стены для ForceField
                        if Settings.Material == Enum.Material.ForceField then
                            part.Transparency = -1
                        else
                            part.Transparency = 0.5
                        end
                    end
                end
            end
        end
    end)

    return VisualsModule
end

return VisualsModule
