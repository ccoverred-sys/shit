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

    -- 1. ГЛАВНЫЙ ВКЛЮЧАТЕЛЬ
    ChamsSector:AddToggle("Enable Material Chams", false, function(state)
        Settings.Enabled = state
        if not state then
            VisualsModule:ResetChams()
        end
    end)

    -- 2. ВЫБОРОЧНЫЙ СПИСОК (DROPDOWN) - Тот самый "ахуенный" выбор
    -- Аргументы: Name, Options (table), Default, Callback
    ChamsSector:AddDropdown("Select Material", {"ForceField", "Neon", "Glass", "Ice", "Wood", "Diamond"}, "ForceField", function(selected)
        Settings.Material = Enum.Material[selected]
        print("[!] Material changed to: " .. selected)
    end)

    -- 3. ЦВЕТА И ЭФФЕКТЫ
    ChamsSector:AddToggle("Rainbow Mode", false, function(state)
        Settings.Rainbow = state
    end)

    ChamsSector:AddButton("Color: Red", function() Settings.Color = Color3.fromRGB(255, 0, 0); Settings.Rainbow = false end)
    ChamsSector:AddButton("Color: Cyan", function() Settings.Color = Color3.fromRGB(0, 255, 255); Settings.Rainbow = false end)

    -- 4. ОКРУЖЕНИЕ
    WorldSector:AddButton("Full Bright", function()
        local Light = game:GetService("Lighting")
        Light.Brightness = 2
        Light.ClockTime = 14
        Light.GlobalShadows = false
    end)

    -- ФУНКЦИЯ СБРОСА
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

    -- ЦИКЛ РЕНДЕРИНГА
    game:GetService("RunService").RenderStepped:Connect(function()
        if not Settings.Enabled then return end
        
        if Settings.Rainbow then
            Settings.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        end
        
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player ~= game:GetService("Players").LocalPlayer and player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        if not part:GetAttribute("OrigColor") then
                            part:SetAttribute("OrigColor", part.Color)
                        end
                        
                        part.Material = Settings.Material
                        part.Color = Settings.Color
                        
                        -- Специальная прозрачность для X-Ray (ForceField)
                        if Settings.Material == Enum.Material.ForceField then
                            part.Transparency = -1 
                        else
                            part.Transparency = Settings.Transparency
                        end
                    end
                end
            end
        end
    end)

    return VisualsModule
end

return VisualsModule
