local VisualsModule = {}

function VisualsModule:Init(Window)
    if not Window then return end

    -- 1. Создаем вкладку
    local Tab = Window:CreateTab("Visuals")
    
    -- 2. Создаем секторы (визуальные рамки)
    Tab:CreateSector("Elite Chams", "Left")
    Tab:CreateSector("Environment", "Right")
    
    local Settings = {
        Enabled = false,
        Material = Enum.Material.ForceField,
        Color = Color3.fromRGB(255, 0, 0),
        Rainbow = false
    }

    -- ВНИМАНИЕ: В этой либе элементы создаются через Tab!
    -- Формат: Tab:AddToggle("ИмяСектора", "Название", Дефолт, Коллбэк)

    -- ТУМБЛЕР
    Tab:AddToggle("Elite Chams", "Enable Chams", false, function(state)
        Settings.Enabled = state
        if not state then VisualsModule:ResetChams() end
    end)

    -- ДРОПДАУН (Материалы)
    local mats = {"ForceField", "Neon", "Glass", "Ice"}
    Tab:AddDropdown("Elite Chams", "Select Material", mats, "ForceField", function(selected)
        Settings.Material = Enum.Material[selected]
    end)

    -- КОЛОРПИКЕР
    Tab:AddColorpicker("Elite Chams", "Chams Color", Color3.fromRGB(255, 0, 0), function(newColor)
        Settings.Color = newColor
        Settings.Rainbow = false
    end)

    -- КНОПКА (В другой сектор)
    Tab:AddButton("Environment", "Full Bright", function()
        local L = game:GetService("Lighting")
        L.Brightness = 2
        L.ClockTime = 14
        L.GlobalShadows = false
    end)

    -- [ЛОГИКА СБРОСА]
    function VisualsModule:ResetChams()
        for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
            if p.Character then
                for _, v in ipairs(p.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Material = Enum.Material.Plastic
                        v.Transparency = 0
                        v.Color = v:GetAttribute("OrigColor") or v.Color
                    end
                end
            end
        end
    end

    -- [ЦИКЛ РЕНДЕРА]
    game:GetService("RunService").RenderStepped:Connect(function()
        if not Settings.Enabled then return end
        for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
            if p ~= game:GetService("Players").LocalPlayer and p.Character then
                for _, part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        if not part:GetAttribute("OrigColor") then part:SetAttribute("OrigColor", part.Color) end
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
