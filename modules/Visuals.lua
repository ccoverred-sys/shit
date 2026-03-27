local Visuals = {}

function Visuals:Init(Window)
    local Tab = Window:CreateTab("Visuals")
    local Sector = Tab:CreateSector("Elite Chams", "Left")
    
    local Config = {
        Enabled = false,
        Material = Enum.Material.ForceField,
        Color = Color3.fromRGB(255, 0, 0)
    }

    -- 1. Включение
    Sector:AddToggle("Enable Chams", false, function(state)
        Config.Enabled = state
    end)

    -- 2. Выбор Материала (Dropdown)
    Sector:AddDropdown("Material", {"ForceField", "Neon", "Glass", "Ice"}, "ForceField", function(selected)
        Config.Material = Enum.Material[selected]
    end)

    -- 3. Выбор Цвета (ColorPicker)
    Sector:AddColorPicker("Chams Color", Color3.fromRGB(255, 0, 0), function(color)
        Config.Color = color
    end)

    -- ЛОГИКА РЕНДЕРА
    game:GetService("RunService").RenderStepped:Connect(function()
        if Config.Enabled then
            for _, p in ipairs(game.Players:GetPlayers()) do
                if p ~= game.Players.LocalPlayer and p.Character then
                    for _, v in ipairs(p.Character:GetDescendants()) do
                        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                            v.Material = Config.Material
                            v.Color = Config.Color
                            v.Transparency = (Config.Material == Enum.Material.ForceField and -1) or 0.5
                        end
                    end
                end
            end
        end
    end)

    return Visuals
end

return Visuals
