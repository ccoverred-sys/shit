local MoveModule = {
    FlyEnabled = false,
    FlySpeed = 50,
    InfJump = false
}

local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

RunService.RenderStepped:Connect(function()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if MoveModule.FlyEnabled and root then
        local cam = workspace.CurrentCamera.CFrame
        local dir = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.LookVector end
        root.Velocity = dir * MoveModule.FlySpeed
        root.Anchored = (dir.Magnitude == 0)
    elseif root and root.Anchored then
        root.Anchored = false
    end
end)

UIS.JumpRequest:Connect(function()
    if MoveModule.InfJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)

return MoveModule
