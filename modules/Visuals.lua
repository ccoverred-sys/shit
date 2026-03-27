--[[
    ELITE CHAMS MODULE (MODULAR)
    Type: High-Visibility Thermal X-Ray
    Developer: Expert Level AI
]]

local Chams = {
    Enabled = false,
    FillColor = Color3.fromRGB(255, 0, 0),
    OutlineColor = Color3.fromRGB(255, 255, 255),
    FillTransparency = 0.5,
    OutlineTransparency = 0
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Функция применения чамсов к персонажу
function Chams:Apply(char)
    if not char then return end
    
    local highlight = char:FindFirstChild("EliteChams")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "EliteChams"
        highlight.Parent = char
    end
    
    highlight.FillColor = self.FillColor
    highlight.OutlineColor = self.OutlineColor
    highlight.FillTransparency = self.FillTransparency
    highlight.OutlineTransparency = self.OutlineTransparency
    highlight.Adornee = char
    highlight.Enabled = self.Enabled
end

-- Основной цикл обновления
task.spawn(function()
    while task.wait(1) do
        if Chams.Enabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    Chams:Apply(player.Character)
                end
            end
        else
            -- Очистка при выключении
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    local hl = player.Character:FindFirstChild("EliteChams")
                    if hl then hl:Destroy() end
                end
            end
        end
    end
end)

-- Слушатель новых игроков
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        if Chams.Enabled then
            task.wait(1) -- Ждем загрузки персонажа
            Chams:Apply(char)
        end
    end)
end)

return Chams
