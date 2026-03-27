local VisualsModule = {}

function VisualsModule:Init(Window)
    local Tab = Window:CreateTab("Visuals")
    local Sector = Tab:CreateSector("Elite Chams", "Left")
    
    local Settings = {
        Enabled = false,
        Material = Enum.Material.ForceField,
        Color = Color3.fromRGB(255, 0, 0)
    }

    -- Используем AddToggle, как в твоем Movement.lua
    Sector:AddToggle("Enable Chams", false, function(state)
        Settings.Enabled = state
        if not state then
            -- Сброс (pcall для безопасности)
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

    -- Вместо дропдауна пока кнопки (чтобы проверить отрисовку)
    Sector:AddButton("Mode: ForceField", function()
        Settings.Material = Enum.Material.ForceField
    end)

    Sector:AddButton("Mode: Neon", function()
        Settings.Material = Enum.Material.Neon
    end)

    -- Логика рендера (RunService)
    game:GetService("RunService").RenderStepped:Connect(function()
        if not Settings.Enabled then return end
        for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
            if p ~= game:GetService("Players").LocalPlayer and p.Character then
                for _, part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.Material = Settings.Material
                        part.Color = Settings.Color
                        part.Transparency = (Settings.Material == Enum.Material.ForceField and -1) or 0.5
                    end
                end
            end
        end
    end)

    return VisualsModule
end

return VisualsModule
