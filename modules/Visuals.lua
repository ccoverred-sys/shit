local Visuals = {}

function Visuals:Init(Window)
    local Tab = Window:CreateTab("Visuals")
    local Sector = Tab:CreateSector("Elite Chams", "Left")
    
    -- Локальные настройки (инкапсуляция)
    local Config = {
        Enabled = false,
        Material = Enum.Material.ForceField,
        Color = Color3.fromRGB(255, 0, 0),
        Transparency = 0.5
    }

    -- 1. ТУМБЛЕР (Включение)
    Sector:AddToggle("Enable Chams", false, function(state)
        Config.Enabled = state
        if not state then
            -- Сброс при выключении (pcall для защиты)
            pcall(function()
                for _, p in ipairs(game.Players:GetPlayers()) do
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

    -- 2. ДРОПДАУН (Материалы)
    -- Исправленный синтаксис: Name, List, Default, Callback
    local matList = {"ForceField", "Neon", "Glass", "Ice", "Plastic"}
    Sector:AddDropdown("Material", matList, "ForceField", function(selected)
        if Enum.Material[selected] then
            Config.Material = Enum.Material[selected]
            print("[+] Материал изменен на: " .. selected)
        end
    end)

    -- 3. ПАЛИТРА ЦВЕТОВ (ColorPicker)
    -- В твоей либе обычно: Name, DefaultColor, Callback
    Sector:AddColorPicker("Chams Color", Color3.fromRGB(255, 0, 0), function(color)
        Config.Color = color
    end)

    -- 4. ОКРУЖЕНИЕ (Быстрая кнопка)
    local WorldSector = Tab:CreateSector("Environment", "Right")
    WorldSector:AddButton("Full Bright", function()
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 14
        game:GetService("Lighting").GlobalShadows = false
    end)

    -- ЛОГИКА РЕНДЕРА (Высокопроизводительный цикл)
    game:GetService("RunService").RenderStepped:Connect(function()
        if Config.Enabled then
            for _, p in ipairs(game.Players:GetPlayers()) do
                if p ~= game.Players.LocalPlayer and p.Character then
                    for _, part in ipairs(p.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.Material = Config.Material
                            part.Color = Config.Color
                            
                            -- ForceField (X-Ray) эффект
                            if Config.Material == Enum.Material.ForceField then
                                part.Transparency = -1
                            else
                                part.Transparency = Config.Transparency
                            end
                        end
                    end
                end
            end
        end
    end)

    return Visuals
end

return Visuals
