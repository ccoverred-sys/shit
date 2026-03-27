local VisualsModule = {}

function VisualsModule:Init(Window)
    if not Window then return end

    local Tab = Window:CreateTab("Visuals")
    local ChamsSector = Tab:CreateSector("Elite Chams", "Left")
    local WorldSector = Tab:CreateSector("Environment", "Right")
    
    local Settings = {
        Enabled = false,
        Material = Enum.Material.ForceField,
        Color = Color3.fromRGB(255, 0, 0),
        Transparency = 0.5,
        Rainbow = false
    }

    -- 1. ТУМБЛЕР (Проверенный метод)
    ChamsSector:AddToggle("Enable Material Chams", false, function(state)
        Settings.Enabled = state
        if not state then VisualsModule:ResetChams() end
    end)

    -- 2. УНИВЕРСАЛЬНЫЙ ДРОПДАУН (Пробуем все варианты вызова)
    local materials = {"ForceField", "Neon", "Glass", "Ice", "Wood"}
    
    local function UpdateMat(selected)
        Settings.Material = Enum.Material[selected]
        print("[+] Material set to: " .. selected)
    end

    -- Попытка 1: (Name, List, Callback) - Самый частый в IsraelLib
    local success = pcall(function()
        ChamsSector:AddDropdown("Select Material", materials, function(selected)
            UpdateMat(selected)
        end)
    end)

    -- Попытка 2: Если первая не сработала (Name, List, Default, Callback)
    if not success then
        pcall(function()
            ChamsSector:AddDropdown("Select Material", materials, "ForceField", function(selected)
                UpdateMat(selected)
            end)
        end)
    end

    -- 3. КОЛОРПИКЕР (AddColorPicker)
    pcall(function()
        ChamsSector:AddColorPicker("Chams Color", Color3.fromRGB(255, 0, 0), function(newColor)
            Settings.Color = newColor
            Settings.Rainbow = false
        end)
    end)

    -- 4. ОКРУЖЕНИЕ
    WorldSector:AddButton("Full Bright", function()
        local Light = game:GetService("Lighting")
        Light.Brightness = 2
        Light.ClockTime = 14
        Light.GlobalShadows = false
    end)

    -- [ЛОГИКА РЕНДЕРА ОСТАЕТСЯ ПРЕЖНЕЙ]
    function VisualsModule:ResetChams()
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Material = Enum.Material.Plastic
                        part.Transparency = 0
                        part.Color = part:GetAttribute("OrigColor") or part.Color
                    end
                end
            end
        end
    end

    game:GetService("RunService").RenderStepped:Connect(function()
        if not Settings.Enabled then return end
        if Settings.Rainbow then Settings.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player ~= game:GetService("Players").LocalPlayer and player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        if not part:GetAttribute("OrigColor") then part:SetAttribute("OrigColor", part.Color) end
                        part.Material = Settings.Material
                        part.Color = Settings.Color
                        part.Transparency = (Settings.Material == Enum.Material.ForceField and -1) or (Settings.Material == Enum.Material.Glass and 0.8) or Settings.Transparency
                    end
                end
            end
        end
    end)

    return VisualsModule
end

return VisualsModule
