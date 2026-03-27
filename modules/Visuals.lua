local VisualsModule = {}

function VisualsModule:Init(Window)
    local Tab = Window:CreateTab("Visuals")
    local Sector = Tab:CreateSector("Elite Chams", "Left")
    
    local Settings = {
        Enabled = false,
        Material = Enum.Material.ForceField,
        Color = Color3.fromRGB(255, 0, 0)
    }

    -- 1. ВКЛЮЧЕНИЕ
    Sector:AddToggle("Enable Chams", false, function(state)
        Settings.Enabled = state
        if not state then
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

    -- 2. ДРОПДАУН (Строгий синтаксис: Name, List, Default, Callback)
    local materials = {"ForceField", "Neon", "Glass", "Ice", "Wood"}
    Sector:AddDropdown("Select Material", materials, "ForceField", function(selected)
        if Enum.Material[selected] then
            Settings.Material = Enum.Material[selected]
        end
    end)

    -- 3. КОЛОРПИКЕР (Палитра)
    -- Аргументы: Name, DefaultColor, Callback
    Sector:AddColorPicker("Chams Color", Color3.fromRGB(255, 0, 0), function(newColor)
        Settings.Color = newColor
    end)

    -- ЛОГИКА РЕНДЕРА
    game:GetService("RunService").RenderStepped:Connect(function()
        if not Settings.Enabled then return end
        for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
            if p ~= game:GetService("Players").LocalPlayer and p.Character then
                for _, part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.Material = Settings.Material
                        part.Color = Settings.Color
                        -- Хак прозрачности для ForceField (X-Ray)
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
