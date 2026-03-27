--[[
    IsraelLib - A Modern Roblox UI Library
    Theme: Israel Flag (White & Deep Blue #0038B8)
    Version: 1.0.0
    Author: Generated Library
    
    STRUCTURE:
    - IsraelLib (root module)
      - Window
        - Tab
          - Section
            - Toggle, Button, Slider, TextBox, Dropdown, ColorPicker, Keybind
      - Config Panel
      - Notifications
--]]

local IsraelLib = {}
IsraelLib.__index = IsraelLib

-- ============================================================
-- SERVICES
-- ============================================================
local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local UserInputService= game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local CoreGui         = game:GetService("CoreGui")
local HttpService     = game:GetService("HttpService")

local LocalPlayer     = Players.LocalPlayer
local Mouse           = LocalPlayer:GetMouse()

-- ============================================================
-- THEME
-- ============================================================
local Theme = {
    Blue            = Color3.fromRGB(0, 56, 184),
    BlueDark        = Color3.fromRGB(0, 40, 140),
    BlueLight       = Color3.fromRGB(30, 90, 220),
    BlueGlow        = Color3.fromRGB(0, 56, 184),
    White           = Color3.fromRGB(255, 255, 255),
    OffWhite        = Color3.fromRGB(245, 247, 252),
    LightGray       = Color3.fromRGB(230, 234, 242),
    MidGray         = Color3.fromRGB(180, 190, 210),
    TextDark        = Color3.fromRGB(20, 30, 60),
    TextMid         = Color3.fromRGB(80, 100, 150),
    TextLight       = Color3.fromRGB(255, 255, 255),
    Stripe          = Color3.fromRGB(0, 56, 184),
    Shadow          = Color3.fromRGB(0, 20, 80),
    Success         = Color3.fromRGB(30, 180, 100),
    Warning         = Color3.fromRGB(230, 160, 0),
    Error           = Color3.fromRGB(210, 50, 50),
    ToggleOn        = Color3.fromRGB(0, 56, 184),
    ToggleOff       = Color3.fromRGB(180, 190, 210),
    SliderFill      = Color3.fromRGB(0, 56, 184),
    SliderBg        = Color3.fromRGB(220, 228, 245),
    CornerRadius    = UDim.new(0, 8),
    SmallCorner     = UDim.new(0, 5),
    TweenInfo       = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    FastTween       = TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    SlowTween       = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
}

-- ============================================================
-- UTILITY
-- ============================================================
local Util = {}

function Util.Tween(obj, props, info)
    local ti = info or Theme.TweenInfo
    local t = TweenService:Create(obj, ti, props)
    t:Play()
    return t
end

function Util.Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or Theme.CornerRadius
    c.Parent = parent
    return c
end

function Util.Stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Blue
    s.Thickness = thickness or 1.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

function Util.Padding(parent, top, right, bottom, left)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    p.Parent = parent
    return p
end

function Util.ListLayout(parent, dir, padding, ha, va)
    local l = Instance.new("UIListLayout")
    l.FillDirection        = dir or Enum.FillDirection.Vertical
    l.Padding              = UDim.new(0, padding or 6)
    l.HorizontalAlignment  = ha  or Enum.HorizontalAlignment.Left
    l.VerticalAlignment    = va  or Enum.VerticalAlignment.Top
    l.SortOrder            = Enum.SortOrder.LayoutOrder
    l.Parent = parent
    return l
end

function Util.Label(parent, text, size, color, xAlign)
    local l = Instance.new("TextLabel")
    l.Text              = text or ""
    l.TextSize          = size or 14
    l.Font              = Enum.Font.GothamMedium
    l.TextColor3        = color or Theme.TextDark
    l.BackgroundTransparency = 1
    l.TextXAlignment    = xAlign or Enum.TextXAlignment.Left
    l.Size              = UDim2.new(1, 0, 0, size and size + 4 or 18)
    l.Parent = parent
    return l
end

function Util.Frame(parent, size, pos, color, transparency)
    local f = Instance.new("Frame")
    f.Size                   = size or UDim2.new(1, 0, 0, 30)
    f.Position               = pos  or UDim2.new(0, 0, 0, 0)
    f.BackgroundColor3       = color or Theme.White
    f.BackgroundTransparency = transparency or 0
    f.BorderSizePixel        = 0
    f.Parent = parent
    return f
end

function Util.Button(parent, text, size, pos)
    local b = Instance.new("TextButton")
    b.Text              = text or ""
    b.TextSize          = 13
    b.Font              = Enum.Font.GothamMedium
    b.TextColor3        = Theme.White
    b.BackgroundColor3  = Theme.Blue
    b.Size              = size or UDim2.new(1, 0, 0, 32)
    b.Position          = pos  or UDim2.new(0, 0, 0, 0)
    b.BorderSizePixel   = 0
    b.AutoButtonColor   = false
    b.Parent = parent
    return b
end

function Util.ScrollFrame(parent, size, pos, canvasSize)
    local s = Instance.new("ScrollingFrame")
    s.Size                     = size or UDim2.new(1, 0, 1, 0)
    s.Position                 = pos  or UDim2.new(0, 0, 0, 0)
    s.BackgroundTransparency   = 1
    s.BorderSizePixel          = 0
    s.ScrollBarThickness       = 3
    s.ScrollBarImageColor3     = Theme.Blue
    s.CanvasSize               = canvasSize or UDim2.new(0, 0, 0, 0)
    s.AutomaticCanvasSize      = Enum.AutomaticSize.Y
    s.Parent = parent
    return s
end

function Util.Shadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name                  = "Shadow"
    shadow.AnchorPoint           = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position              = UDim2.new(0.5, 0, 0.5, 4)
    shadow.Size                  = UDim2.new(1, 24, 1, 24)
    shadow.ZIndex                = -1
    shadow.Image                 = "rbxassetid://7912134082"
    shadow.ImageColor3           = Theme.Shadow
    shadow.ImageTransparency     = 0.55
    shadow.ScaleType             = Enum.ScaleType.Slice
    shadow.SliceCenter           = Rect.new(12, 12, 12, 12)
    shadow.Parent = parent
    return shadow
end

function Util.MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ============================================================
-- NOTIFICATION SYSTEM
-- ============================================================
local NotifHolder

local function InitNotifHolder()
    if NotifHolder then return end
    local sg = Instance.new("ScreenGui")
    sg.Name                 = "IsraelLibNotifs"
    sg.ResetOnSpawn         = false
    sg.ZIndexBehavior       = Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset       = true
    sg.Parent               = (pcall(function() return CoreGui end)) and CoreGui or LocalPlayer.PlayerGui

    NotifHolder = Instance.new("Frame")
    NotifHolder.Name                  = "NotifHolder"
    NotifHolder.Size                  = UDim2.new(0, 300, 1, 0)
    NotifHolder.Position              = UDim2.new(1, -310, 0, 0)
    NotifHolder.BackgroundTransparency = 1
    NotifHolder.AnchorPoint           = Vector2.new(0, 0)
    NotifHolder.Parent                = sg

    Util.ListLayout(NotifHolder, Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)
    local pad = Instance.new("UIPadding")
    pad.PaddingBottom = UDim.new(0, 16)
    pad.PaddingRight  = UDim.new(0, 8)
    pad.Parent        = NotifHolder
end

function IsraelLib:Notify(opts)
    InitNotifHolder()
    opts = opts or {}
    local title   = opts.Title   or "Notification"
    local msg     = opts.Message or ""
    local duration= opts.Duration or 4
    local ntype   = opts.Type    or "info" -- info, success, warning, error

    local accentColor = ({
        info    = Theme.Blue,
        success = Theme.Success,
        warning = Theme.Warning,
        error   = Theme.Error,
    })[ntype] or Theme.Blue

    local card = Util.Frame(NotifHolder, UDim2.new(1, 0, 0, 70), nil, Theme.White)
    card.ClipsDescendants = true
    Util.Corner(card, UDim.new(0, 10))
    Util.Stroke(card, accentColor, 1.5)
    Util.Shadow(card)

    -- Left accent bar
    local bar = Util.Frame(card, UDim2.new(0, 4, 1, 0), UDim2.new(0,0,0,0), accentColor)
    Util.Corner(bar, UDim.new(0, 4))

    local inner = Util.Frame(card, UDim2.new(1, -16, 1, 0), UDim2.new(0, 12, 0, 0), Theme.White)
    Util.ListLayout(inner, Enum.FillDirection.Vertical, 2, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
    Util.Padding(inner, 10, 4, 10, 4)

    local titleLbl = Util.Label(inner, title, 13, accentColor)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.Size = UDim2.new(1, 0, 0, 16)

    local msgLbl = Util.Label(inner, msg, 12, Theme.TextMid)
    msgLbl.Size = UDim2.new(1, 0, 0, 30)
    msgLbl.TextWrapped = true

    -- Animate in
    card.Position = UDim2.new(1, 20, 0, 0)
    Util.Tween(card, {Position = UDim2.new(0, 0, 0, 0)}, Theme.TweenInfo)

    -- Progress bar
    local prog = Util.Frame(card, UDim2.new(1, 0, 0, 2), UDim2.new(0,0,1,-2), accentColor)
    Util.Tween(prog, {Size = UDim2.new(0, 0, 0, 2)}, TweenInfo.new(duration, Enum.EasingStyle.Linear))

    task.delay(duration, function()
        Util.Tween(card, {Position = UDim2.new(1, 20, 0, 0)}, Theme.TweenInfo)
        task.delay(0.3, function() card:Destroy() end)
    end)
end

-- ============================================================
-- WINDOW
-- ============================================================
local Window = {}
Window.__index = Window

function IsraelLib:CreateWindow(opts)
    opts = opts or {}
    local title    = opts.Title    or "IsraelLib"
    local subtitle = opts.Subtitle or "Modern UI Library"
    local size     = opts.Size     or UDim2.new(0, 620, 0, 460)
    local toggleKey= opts.ToggleKey or Enum.KeyCode.RightControl
    local blurBg   = opts.BlurBackground or false

    -- Screen GUI
    local sg = Instance.new("ScreenGui")
    sg.Name             = "IsraelLib_" .. title
    sg.ResetOnSpawn     = false
    sg.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset   = true
    sg.Parent           = (pcall(function() return CoreGui end)) and CoreGui or LocalPlayer.PlayerGui

    -- Blur
    local blurEffect
    if blurBg then
        local camera = workspace.CurrentCamera
        blurEffect = Instance.new("BlurEffect")
        blurEffect.Size   = 0
        blurEffect.Parent = camera
    end

    -- Main container
    local main = Util.Frame(sg, size, UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2), Theme.OffWhite)
    main.Name            = "MainWindow"
    main.ClipsDescendants= true
    Util.Corner(main, UDim.new(0, 12))
    Util.Shadow(main)

    -- Thin blue top stripe (Israel flag stripe)
    local topStripe = Util.Frame(main, UDim2.new(1, 0, 0, 3), UDim2.new(0,0,0,0), Theme.Stripe)

    -- Bottom stripe
    local botStripe = Util.Frame(main, UDim2.new(1, 0, 0, 3), UDim2.new(0,0,1,-3), Theme.Stripe)

    -- Title bar
    local titleBar = Util.Frame(main, UDim2.new(1, 0, 0, 52), UDim2.new(0,0,0,3), Theme.White)
    Util.Padding(titleBar, 0, 12, 0, 16)
    Util.MakeDraggable(main, titleBar)

    -- Logo / Title area
    local titleLeft = Util.Frame(titleBar, UDim2.new(0, 300, 1, 0), UDim2.new(0,0,0,0), Theme.White)
    Util.ListLayout(titleLeft, Enum.FillDirection.Vertical, 1, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
    Util.Padding(titleLeft, 6, 0, 6, 0)

    local titleLbl = Util.Label(titleLeft, title, 18, Theme.Blue)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.Size = UDim2.new(1, 0, 0, 22)

    local subLbl = Util.Label(titleLeft, subtitle, 11, Theme.TextMid)
    subLbl.Size  = UDim2.new(1, 0, 0, 14)

    -- Close button
    local closeBtn = Util.Button(titleBar, "✕", UDim2.new(0, 28, 0, 28), UDim2.new(1, -32, 0.5, -14))
    closeBtn.BackgroundColor3 = Theme.LightGray
    closeBtn.TextColor3       = Theme.TextMid
    closeBtn.TextSize         = 14
    Util.Corner(closeBtn, UDim.new(0, 6))

    closeBtn.MouseEnter:Connect(function()
        Util.Tween(closeBtn, {BackgroundColor3 = Theme.Error, TextColor3 = Theme.White})
    end)
    closeBtn.MouseLeave:Connect(function()
        Util.Tween(closeBtn, {BackgroundColor3 = Theme.LightGray, TextColor3 = Theme.TextMid})
    end)
    closeBtn.MouseButton1Click:Connect(function()
        Util.Tween(main, {Size = UDim2.new(0, size.X.Offset, 0, 0), Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, 0)}, Theme.TweenInfo)
        task.delay(0.25, function() sg:Destroy() end)
    end)

    -- Minimize button
    local minBtn = Util.Button(titleBar, "─", UDim2.new(0, 28, 0, 28), UDim2.new(1, -66, 0.5, -14))
    minBtn.BackgroundColor3 = Theme.LightGray
    minBtn.TextColor3       = Theme.TextMid
    minBtn.TextSize         = 14
    Util.Corner(minBtn, UDim.new(0, 6))

    local minimized = false
    minBtn.MouseEnter:Connect(function()
        Util.Tween(minBtn, {BackgroundColor3 = Theme.Blue, TextColor3 = Theme.White})
    end)
    minBtn.MouseLeave:Connect(function()
        Util.Tween(minBtn, {BackgroundColor3 = Theme.LightGray, TextColor3 = Theme.TextMid})
    end)
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Util.Tween(main, {Size = UDim2.new(0, size.X.Offset, 0, 58)}, Theme.TweenInfo)
        else
            Util.Tween(main, {Size = size}, Theme.TweenInfo)
        end
    end)

    -- Divider line under title
    local divider = Util.Frame(main, UDim2.new(1, -32, 0, 1), UDim2.new(0, 16, 0, 55), Theme.LightGray)

    -- LEFT sidebar for tabs
    local sidebar = Util.Frame(main, UDim2.new(0, 148, 1, -62), UDim2.new(0, 0, 0, 56), Theme.White)
    Util.Padding(sidebar, 8, 0, 8, 0)

    local sideScroll = Util.ScrollFrame(sidebar, UDim2.new(1, 0, 1, 0))
    Util.ListLayout(sideScroll, Enum.FillDirection.Vertical, 4)
    Util.Padding(sideScroll, 4, 6, 4, 6)

    -- Sidebar right border
    local sideBorder = Util.Frame(main, UDim2.new(0, 1, 1, -62), UDim2.new(0, 148, 0, 56), Theme.LightGray)

    -- Content area
    local contentArea = Util.Frame(main, UDim2.new(1, -152, 1, -62), UDim2.new(0, 150, 0, 56), Theme.OffWhite)

    -- Opening animation
    main.Size     = UDim2.new(0, size.X.Offset, 0, 0)
    main.Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, 0)
    Util.Tween(main, {Size = size, Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)}, Theme.SlowTween)

    -- Blur in
    if blurBg and blurEffect then
        Util.Tween(blurEffect, {Size = 16}, Theme.SlowTween)
    end

    -- Toggle visibility
    local visible = true
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == toggleKey then
            visible = not visible
            if visible then
                main.Visible = true
                Util.Tween(main, {Size = size, Position = UDim2.new(0.5,-size.X.Offset/2,0.5,-size.Y.Offset/2)}, Theme.TweenInfo)
                if blurBg and blurEffect then Util.Tween(blurEffect, {Size=16}, Theme.TweenInfo) end
            else
                Util.Tween(main, {Size = UDim2.new(0,size.X.Offset,0,0), Position = UDim2.new(0.5,-size.X.Offset/2,0.5,0)}, Theme.TweenInfo)
                task.delay(0.25, function() if not visible then main.Visible = false end end)
                if blurBg and blurEffect then Util.Tween(blurEffect, {Size=0}, Theme.TweenInfo) end
            end
        end
    end)

    -- Window object
    local win = setmetatable({
        _sg           = sg,
        _main         = main,
        _sidebar      = sideScroll,
        _contentArea  = contentArea,
        _tabs         = {},
        _activeTab    = nil,
        _configPanel  = nil,
    }, Window)

    -- Config panel
    win:_InitConfigPanel()

    return win
end

function Window:_InitConfigPanel()
    -- Config tab button in sidebar (always last)
    local cfgBtn = Util.Button(self._sidebar, "⚙  Config", UDim2.new(1, 0, 0, 36))
    cfgBtn.BackgroundColor3 = Theme.OffWhite
    cfgBtn.TextColor3       = Theme.TextMid
    cfgBtn.TextSize         = 13
    cfgBtn.TextXAlignment   = Enum.TextXAlignment.Left
    cfgBtn.LayoutOrder      = 999
    Util.Corner(cfgBtn, UDim.new(0, 7))
    Util.Padding(cfgBtn, 0, 0, 0, 12)

    -- Config panel frame (hidden initially)
    local cfgPanel = Util.Frame(self._contentArea, UDim2.new(1, 0, 1, 0), UDim2.new(0,0,0,0), Theme.OffWhite)
    cfgPanel.Visible = false
    cfgPanel.Name    = "ConfigPanel"
    Util.Padding(cfgPanel, 16, 16, 16, 16)

    local cfgScroll = Util.ScrollFrame(cfgPanel, UDim2.new(1, 0, 1, 0))
    Util.ListLayout(cfgScroll, Enum.FillDirection.Vertical, 10)

    -- Title
    local hdr = Util.Label(cfgScroll, "Configuration Manager", 16, Theme.Blue)
    hdr.Font  = Enum.Font.GothamBold
    hdr.Size  = UDim2.new(1, 0, 0, 22)

    local sub = Util.Label(cfgScroll, "Save, load and manage your settings", 12, Theme.TextMid)
    sub.Size  = UDim2.new(1, 0, 0, 16)

    local div1 = Util.Frame(cfgScroll, UDim2.new(1, 0, 0, 1), nil, Theme.LightGray)

    -- Config name input row
    local nameRow = Util.Frame(cfgScroll, UDim2.new(1, 0, 0, 36), nil, Theme.White)
    Util.Corner(nameRow)
    Util.Stroke(nameRow, Theme.LightGray, 1.5)
    Util.Padding(nameRow, 0, 10, 0, 10)

    local nameBox = Instance.new("TextBox")
    nameBox.PlaceholderText       = "Config name..."
    nameBox.Text                  = ""
    nameBox.TextSize              = 13
    nameBox.Font                  = Enum.Font.Gotham
    nameBox.TextColor3            = Theme.TextDark
    nameBox.PlaceholderColor3     = Theme.MidGray
    nameBox.BackgroundTransparency= 1
    nameBox.Size                  = UDim2.new(1, 0, 1, 0)
    nameBox.TextXAlignment        = Enum.TextXAlignment.Left
    nameBox.ClearTextOnFocus      = false
    nameBox.Parent                = nameRow

    nameBox.Focused:Connect(function() Util.Tween(nameRow, {BackgroundColor3 = Theme.OffWhite}) end)
    nameBox.FocusLost:Connect(function() Util.Tween(nameRow, {BackgroundColor3 = Theme.White}) end)

    -- Button row
    local btnRow = Util.Frame(cfgScroll, UDim2.new(1, 0, 0, 36), nil, Theme.OffWhite)
    Util.ListLayout(btnRow, Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

    local function MakeCfgBtn(text, color)
        local b = Util.Button(btnRow, text, UDim2.new(0, 100, 1, 0))
        b.BackgroundColor3 = color or Theme.Blue
        b.TextSize         = 12
        b.LayoutOrder      = 1
        Util.Corner(b, UDim.new(0, 7))
        b.MouseEnter:Connect(function()
            Util.Tween(b, {BackgroundColor3 = Color3.fromRGB(
                math.clamp(color.R*255+20,0,255),
                math.clamp(color.G*255+20,0,255),
                math.clamp(color.B*255+20,0,255)
            )})
        end)
        b.MouseLeave:Connect(function() Util.Tween(b, {BackgroundColor3 = color}) end)
        return b
    end

    local saveBtn   = MakeCfgBtn("💾 Save",   Theme.Blue)
    local loadBtn   = MakeCfgBtn("📂 Load",   Theme.BlueLight)
    local deleteBtn = MakeCfgBtn("🗑 Delete", Theme.Error)

    -- Config list label
    local listHdr = Util.Label(cfgScroll, "Saved Configs", 13, Theme.TextDark)
    listHdr.Font  = Enum.Font.GothamBold
    listHdr.Size  = UDim2.new(1, 0, 0, 18)

    -- Config list holder
    local cfgListHolder = Util.Frame(cfgScroll, UDim2.new(1, 0, 0, 120), nil, Theme.White)
    Util.Corner(cfgListHolder)
    Util.Stroke(cfgListHolder, Theme.LightGray, 1.5)
    local cfgListScroll = Util.ScrollFrame(cfgListHolder, UDim2.new(1, 0, 1, 0))
    Util.ListLayout(cfgListScroll, Enum.FillDirection.Vertical, 2)
    Util.Padding(cfgListScroll, 4, 6, 4, 6)

    local selectedConfig = nil

    local function RefreshConfigList()
        for _, c in ipairs(cfgListScroll:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end

        local files = {}
        pcall(function()
            local raw = listfiles and listfiles("IsraelLib_Configs") or {}
            files = raw
        end)

        if #files == 0 then
            local empty = Util.Label(cfgListScroll, "No configs saved yet", 12, Theme.MidGray)
            empty.TextXAlignment = Enum.TextXAlignment.Center
            empty.Size = UDim2.new(1,0,0,30)
            return
        end

        for _, path in ipairs(files) do
            local name = path:match("([^/\\]+)%.json$") or path
            local row  = Util.Button(cfgListScroll, name, UDim2.new(1, -4, 0, 28))
            row.BackgroundColor3 = Theme.OffWhite
            row.TextColor3       = Theme.TextDark
            row.TextXAlignment   = Enum.TextXAlignment.Left
            Util.Corner(row, UDim.new(0, 6))
            Util.Padding(row, 0, 0, 0, 10)

            row.MouseButton1Click:Connect(function()
                selectedConfig = name
                nameBox.Text   = name
                for _, r in ipairs(cfgListScroll:GetChildren()) do
                    if r:IsA("TextButton") then
                        Util.Tween(r, {BackgroundColor3 = Theme.OffWhite, TextColor3 = Theme.TextDark})
                    end
                end
                Util.Tween(row, {BackgroundColor3 = Theme.Blue, TextColor3 = Theme.White})
            end)
        end
    end

    -- Save
    saveBtn.MouseButton1Click:Connect(function()
        local cname = nameBox.Text
        if cname == "" then
            IsraelLib:Notify({Title="Config Error", Message="Enter a config name first!", Type="error"})
            return
        end
        local data = {}
        if self._configData then
            data = self._configData
        end
        local ok, err = pcall(function()
            if not isfolder("IsraelLib_Configs") then
                makefolder("IsraelLib_Configs")
            end
            writefile("IsraelLib_Configs/" .. cname .. ".json", HttpService:JSONEncode(data))
        end)
        if ok then
            IsraelLib:Notify({Title="Config Saved", Message='Saved as "'..cname..'"', Type="success"})
            RefreshConfigList()
        else
            IsraelLib:Notify({Title="Save Failed", Message=tostring(err), Type="error"})
        end
    end)

    -- Load
    loadBtn.MouseButton1Click:Connect(function()
        local cname = nameBox.Text
        if cname == "" then
            IsraelLib:Notify({Title="Config Error", Message="Enter or select a config name!", Type="error"})
            return
        end
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile("IsraelLib_Configs/" .. cname .. ".json"))
        end)
        if ok and type(data) == "table" then
            if self._onConfigLoad then self._onConfigLoad(data) end
            IsraelLib:Notify({Title="Config Loaded", Message='Loaded "'..cname..'"', Type="success"})
        else
            IsraelLib:Notify({Title="Load Failed", Message="Config not found or corrupted", Type="error"})
        end
    end)

    -- Delete
    deleteBtn.MouseButton1Click:Connect(function()
        local cname = nameBox.Text
        if cname == "" then return end
        pcall(function() delfile("IsraelLib_Configs/" .. cname .. ".json") end)
        IsraelLib:Notify({Title="Config Deleted", Message='Deleted "'..cname..'"', Type="warning"})
        nameBox.Text = ""
        selectedConfig = nil
        RefreshConfigList()
    end)

    RefreshConfigList()

    cfgBtn.MouseButton1Click:Connect(function()
        -- Hide all tab contents
        for _, tab in ipairs(self._tabs) do
            tab._content.Visible = false
            Util.Tween(tab._btn, {BackgroundColor3 = Theme.OffWhite, TextColor3 = Theme.TextMid})
        end
        cfgPanel.Visible = true
        Util.Tween(cfgBtn, {BackgroundColor3 = Theme.Blue, TextColor3 = Theme.White})
        self._activeTab = nil
        RefreshConfigList()
    end)

    self._cfgBtn   = cfgBtn
    self._cfgPanel = cfgPanel
    self._configData = {}
    self._onConfigLoad = nil
end

function Window:OnConfigLoad(callback)
    self._onConfigLoad = callback
end

function Window:SetConfigData(data)
    self._configData = data or {}
end

function Window:AddTab(opts)
    opts = opts or {}
    local tabName = opts.Name or "Tab"
    local icon    = opts.Icon or ""

    -- Sidebar button
    local btn = Util.Button(self._sidebar, (icon ~= "" and icon.." " or "") .. tabName, UDim2.new(1, 0, 0, 36))
    btn.BackgroundColor3 = Theme.OffWhite
    btn.TextColor3       = Theme.TextMid
    btn.TextSize         = 13
    btn.TextXAlignment   = Enum.TextXAlignment.Left
    btn.LayoutOrder      = #self._tabs + 1
    Util.Corner(btn, UDim.new(0, 7))
    Util.Padding(btn, 0, 0, 0, 12)

    -- Content frame
    local content = Util.Frame(self._contentArea, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), Theme.OffWhite)
    content.Visible = false
    content.ClipsDescendants = true

    local scroll = Util.ScrollFrame(content, UDim2.new(1,0,1,0))
    Util.ListLayout(scroll, Enum.FillDirection.Vertical, 10)
    Util.Padding(scroll, 14, 14, 14, 14)

    -- Hover
    btn.MouseEnter:Connect(function()
        if self._activeTab ~= tabObj then
            Util.Tween(btn, {BackgroundColor3 = Theme.LightGray})
        end
    end)
    btn.MouseLeave:Connect(function()
        if self._activeTab ~= tabObj then
            Util.Tween(btn, {BackgroundColor3 = Theme.OffWhite, TextColor3 = Theme.TextMid})
        end
    end)

    local tabObj = {_btn = btn, _content = content, _scroll = scroll, _sections = {}}

    btn.MouseButton1Click:Connect(function()
        if self._activeTab == tabObj then return end
        -- Deactivate all
        for _, t in ipairs(self._tabs) do
            t._content.Visible = false
            Util.Tween(t._btn, {BackgroundColor3 = Theme.OffWhite, TextColor3 = Theme.TextMid})
        end
        self._cfgPanel.Visible = false
        Util.Tween(self._cfgBtn, {BackgroundColor3 = Theme.OffWhite, TextColor3 = Theme.TextMid})
        -- Activate this
        self._activeTab = tabObj
        content.Visible = true
        Util.Tween(btn, {BackgroundColor3 = Theme.Blue, TextColor3 = Theme.White})
    end)

    table.insert(self._tabs, tabObj)

    -- Auto-select first tab
    if #self._tabs == 1 then
        self._activeTab = tabObj
        content.Visible = true
        Util.Tween(btn, {BackgroundColor3 = Theme.Blue, TextColor3 = Theme.White})
    end

    -- Tab API
    local Tab = {}
    Tab.__index = Tab

    function Tab:AddSection(secOpts)
        secOpts = secOpts or {}
        local secName = secOpts.Name or "Section"

        local secFrame = Util.Frame(scroll, UDim2.new(1, 0, 0, 0), nil, Theme.White)
        secFrame.AutomaticSize = Enum.AutomaticSize.Y
        secFrame.ClipsDescendants = false
        Util.Corner(secFrame)
        Util.Stroke(secFrame, Theme.LightGray, 1)

        -- Section header
        local header = Util.Frame(secFrame, UDim2.new(1, 0, 0, 34), nil, Theme.White)
        Util.Corner(header, UDim.new(0, 8))

        -- Blue left accent on section title
        local titleAccent = Util.Frame(header, UDim2.new(0, 3, 0, 18), UDim2.new(0, 12, 0.5, -9), Theme.Blue)
        Util.Corner(titleAccent, UDim.new(1, 0))

        local secLabel = Util.Label(header, secName, 12, Theme.TextDark)
        secLabel.Font   = Enum.Font.GothamBold
        secLabel.Position = UDim2.new(0, 22, 0, 0)
        secLabel.Size   = UDim2.new(1, -22, 1, 0)

        -- Section divider
        local secDiv = Util.Frame(secFrame, UDim2.new(1, -24, 0, 1), UDim2.new(0, 12, 0, 34), Theme.LightGray)

        -- Components holder
        local compHolder = Util.Frame(secFrame, UDim2.new(1, 0, 0, 0), UDim2.new(0,0,0,36), Theme.White)
        compHolder.AutomaticSize = Enum.AutomaticSize.Y
        Util.ListLayout(compHolder, Enum.FillDirection.Vertical, 0)
        Util.Padding(compHolder, 0, 10, 8, 10)

        local Section = {}
        Section.__index = Section

        -- --------------------------------------------------------
        -- TOGGLE
        -- --------------------------------------------------------
        function Section:AddToggle(topts)
            topts    = topts or {}
            local lbl    = topts.Name    or "Toggle"
            local desc   = topts.Description
            local val    = topts.Default or false
            local cb     = topts.Callback or function() end
            local flag   = topts.Flag

            local row = Util.Frame(compHolder, UDim2.new(1,0,0,40), nil, Theme.White)
            Util.Padding(row, 4, 0, 4, 0)

            local textCol = Util.Frame(row, UDim2.new(1,-54,1,0), UDim2.new(0,0,0,0), Theme.White)
            Util.ListLayout(textCol, Enum.FillDirection.Vertical, 1, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

            local nameLbl = Util.Label(textCol, lbl, 13, Theme.TextDark)
            nameLbl.Size  = UDim2.new(1,0,0,16)

            if desc then
                local descLbl = Util.Label(textCol, desc, 11, Theme.TextMid)
                descLbl.Size  = UDim2.new(1,0,0,14)
            end

            -- Toggle track
            local track = Util.Frame(row, UDim2.new(0,42,0,22), UDim2.new(1,-46,0.5,-11), val and Theme.ToggleOn or Theme.ToggleOff)
            Util.Corner(track, UDim.new(1,0))

            -- Toggle thumb
            local thumb = Util.Frame(track, UDim2.new(0,16,0,16), UDim2.new(0, val and 22 or 3, 0.5, -8), Theme.White)
            Util.Corner(thumb, UDim.new(1,0))
            Util.Shadow(thumb)

            local state = val

            local function SetToggle(v, silent)
                state = v
                Util.Tween(track, {BackgroundColor3 = v and Theme.ToggleOn or Theme.ToggleOff})
                Util.Tween(thumb, {Position = UDim2.new(0, v and 23 or 3, 0.5, -8)})
                if not silent then
                    cb(v)
                    if flag and win._configData then win._configData[flag] = v end
                end
            end

            track.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    SetToggle(not state)
                end
            end)
            row.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    SetToggle(not state)
                end
            end)

            -- Hover
            row.MouseEnter:Connect(function() Util.Tween(row, {BackgroundColor3 = Theme.OffWhite}) end)
            row.MouseLeave:Connect(function() Util.Tween(row, {BackgroundColor3 = Theme.White}) end)

            return {
                Set = function(_, v) SetToggle(v, false) end,
                Get = function(_) return state end,
            }
        end

        -- --------------------------------------------------------
        -- BUTTON
        -- --------------------------------------------------------
        function Section:AddButton(bopts)
            bopts  = bopts or {}
            local lbl    = bopts.Name    or "Button"
            local desc   = bopts.Description
            local cb     = bopts.Callback or function() end

            local row = Util.Frame(compHolder, UDim2.new(1,0,0,40), nil, Theme.White)
            Util.Padding(row, 4, 0, 4, 0)

            local textCol = Util.Frame(row, UDim2.new(1,-60,1,0), UDim2.new(0,0,0,0), Theme.White)
            Util.ListLayout(textCol, Enum.FillDirection.Vertical, 1, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

            local nameLbl = Util.Label(textCol, lbl, 13, Theme.TextDark)
            nameLbl.Size  = UDim2.new(1,0,0,16)
            if desc then
                local d = Util.Label(textCol, desc, 11, Theme.TextMid)
                d.Size  = UDim2.new(1,0,0,14)
            end

            local btn = Util.Button(row, "Run", UDim2.new(0,50,0,26), UDim2.new(1,-52,0.5,-13))
            btn.BackgroundColor3 = Theme.Blue
            btn.TextSize         = 12
            Util.Corner(btn, UDim.new(0,6))

            btn.MouseEnter:Connect(function() Util.Tween(btn, {BackgroundColor3 = Theme.BlueLight}) end)
            btn.MouseLeave:Connect(function() Util.Tween(btn, {BackgroundColor3 = Theme.Blue}) end)
            btn.MouseButton1Click:Connect(function()
                Util.Tween(btn, {BackgroundColor3 = Theme.BlueDark})
                cb()
                task.delay(0.15, function() Util.Tween(btn, {BackgroundColor3 = Theme.Blue}) end)
            end)

            row.MouseEnter:Connect(function() Util.Tween(row, {BackgroundColor3 = Theme.OffWhite}) end)
            row.MouseLeave:Connect(function() Util.Tween(row, {BackgroundColor3 = Theme.White}) end)
        end

        -- --------------------------------------------------------
        -- SLIDER
        -- --------------------------------------------------------
        function Section:AddSlider(sopts)
            sopts    = sopts or {}
            local lbl    = sopts.Name    or "Slider"
            local desc   = sopts.Description
            local min_   = sopts.Min     or 0
            local max_   = sopts.Max     or 100
            local val    = sopts.Default or min_
            local suffix = sopts.Suffix  or ""
            local cb     = sopts.Callback or function() end
            local flag   = sopts.Flag

            local row = Util.Frame(compHolder, UDim2.new(1,0,0,50), nil, Theme.White)
            Util.Padding(row, 4, 0, 4, 0)

            -- Top row: name + value
            local topRow = Util.Frame(row, UDim2.new(1,0,0,18), nil, Theme.White)
            local nameLbl = Util.Label(topRow, lbl, 13, Theme.TextDark)
            nameLbl.Size  = UDim2.new(0.7,0,1,0)

            local valLbl  = Util.Label(topRow, tostring(val)..suffix, 12, Theme.Blue)
            valLbl.Size   = UDim2.new(0.3,0,1,0)
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.Font   = Enum.Font.GothamBold

            -- Slider track
            local track = Util.Frame(row, UDim2.new(1,0,0,6), UDim2.new(0,0,0,28), Theme.SliderBg)
            Util.Corner(track, UDim.new(1,0))

            -- Fill
            local pct = (val - min_) / (max_ - min_)
            local fill = Util.Frame(track, UDim2.new(pct,0,1,0), nil, Theme.SliderFill)
            Util.Corner(fill, UDim.new(1,0))

            -- Thumb
            local thumb = Instance.new("Frame")
            thumb.Size            = UDim2.new(0,14,0,14)
            thumb.Position        = UDim2.new(pct,0,0.5,-7)
            thumb.AnchorPoint     = Vector2.new(0.5,0)
            thumb.BackgroundColor3= Theme.Blue
            thumb.BorderSizePixel = 0
            thumb.Parent          = track
            Util.Corner(thumb, UDim.new(1,0))
            Util.Shadow(thumb)

            local state = val
            local dragging = false

            local function UpdateSlider(absX)
                local rel = math.clamp((absX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                state = math.floor(min_ + rel * (max_ - min_))
                valLbl.Text = tostring(state) .. suffix
                Util.Tween(fill,  {Size = UDim2.new(rel,0,1,0)}, Theme.FastTween)
                Util.Tween(thumb, {Position = UDim2.new(rel,0,0.5,-7)}, Theme.FastTween)
                cb(state)
                if flag and win._configData then win._configData[flag] = state end
            end

            track.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    UpdateSlider(i.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider(i.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            row.MouseEnter:Connect(function() Util.Tween(row, {BackgroundColor3 = Theme.OffWhite}) end)
            row.MouseLeave:Connect(function() Util.Tween(row, {BackgroundColor3 = Theme.White}) end)

            return {
                Set = function(_, v)
                    v = math.clamp(v, min_, max_)
                    local r = (v - min_) / (max_ - min_)
                    state = v
                    valLbl.Text = tostring(v) .. suffix
                    fill.Size   = UDim2.new(r,0,1,0)
                    thumb.Position = UDim2.new(r,0,0.5,-7)
                end,
                Get = function(_) return state end,
            }
        end

        -- --------------------------------------------------------
        -- TEXTBOX
        -- --------------------------------------------------------
        function Section:AddTextBox(topts)
            topts    = topts or {}
            local lbl    = topts.Name        or "TextBox"
            local ph     = topts.Placeholder or "Type here..."
            local val    = topts.Default     or ""
            local cb     = topts.Callback    or function() end
            local flag   = topts.Flag

            local row = Util.Frame(compHolder, UDim2.new(1,0,0,48), nil, Theme.White)
            Util.Padding(row, 4, 0, 4, 0)

            local nameLbl = Util.Label(row, lbl, 13, Theme.TextDark)
            nameLbl.Size  = UDim2.new(1,0,0,16)

            local inputFrame = Util.Frame(row, UDim2.new(1,0,0,24), UDim2.new(0,0,0,20), Theme.OffWhite)
            Util.Corner(inputFrame, UDim.new(0,6))
            Util.Stroke(inputFrame, Theme.LightGray, 1.5)
            Util.Padding(inputFrame, 0, 8, 0, 8)

            local box = Instance.new("TextBox")
            box.Text                  = val
            box.PlaceholderText       = ph
            box.TextSize              = 12
            box.Font                  = Enum.Font.Gotham
            box.TextColor3            = Theme.TextDark
            box.PlaceholderColor3     = Theme.MidGray
            box.BackgroundTransparency= 1
            box.Size                  = UDim2.new(1,0,1,0)
            box.TextXAlignment        = Enum.TextXAlignment.Left
            box.ClearTextOnFocus      = false
            box.Parent                = inputFrame

            box.Focused:Connect(function()
                Util.Tween(inputFrame, {BackgroundColor3 = Theme.White})
                Util.Stroke(inputFrame, Theme.Blue, 1.5)
            end)
            box.FocusLost:Connect(function(enter)
                Util.Tween(inputFrame, {BackgroundColor3 = Theme.OffWhite})
                Util.Stroke(inputFrame, Theme.LightGray, 1.5)
                if enter then
                    cb(box.Text)
                    if flag and win._configData then win._configData[flag] = box.Text end
                end
            end)

            row.MouseEnter:Connect(function() Util.Tween(row, {BackgroundColor3 = Theme.OffWhite}) end)
            row.MouseLeave:Connect(function() Util.Tween(row, {BackgroundColor3 = Theme.White}) end)

            return {
                Set = function(_, v) box.Text = v end,
                Get = function(_) return box.Text end,
            }
        end

        -- --------------------------------------------------------
        -- DROPDOWN
        -- --------------------------------------------------------
        function Section:AddDropdown(dopts)
            dopts    = dopts or {}
            local lbl    = dopts.Name    or "Dropdown"
            local items  = dopts.Items   or {}
            local val    = dopts.Default or items[1] or ""
            local cb     = dopts.Callback or function() end
            local flag   = dopts.Flag

            local wrapper = Util.Frame(compHolder, UDim2.new(1,0,0,48), nil, Theme.White)
            wrapper.ClipsDescendants = false
            Util.Padding(wrapper, 4,0,4,0)

            local nameLbl = Util.Label(wrapper, lbl, 13, Theme.TextDark)
            nameLbl.Size  = UDim2.new(1,0,0,16)

            local dropBtn = Util.Button(wrapper, val, UDim2.new(1,0,0,26), UDim2.new(0,0,0,20))
            dropBtn.BackgroundColor3 = Theme.OffWhite
            dropBtn.TextColor3       = Theme.TextDark
            dropBtn.TextXAlignment   = Enum.TextXAlignment.Left
            dropBtn.TextSize         = 12
            Util.Corner(dropBtn, UDim.new(0,6))
            Util.Stroke(dropBtn, Theme.LightGray, 1.5)
            Util.Padding(dropBtn, 0, 26, 0, 8)

            local arrow = Util.Label(dropBtn, "▾", 14, Theme.Blue)
            arrow.Size  = UDim2.new(0,22,1,0)
            arrow.Position = UDim2.new(1,-22,0,0)
            arrow.TextXAlignment = Enum.TextXAlignment.Center

            -- Dropdown list
            local listFrame = Util.Frame(wrapper, UDim2.new(1,0,0,0), UDim2.new(0,0,0,48), Theme.White)
            listFrame.ZIndex         = 10
            listFrame.ClipsDescendants = true
            listFrame.Visible        = false
            Util.Corner(listFrame, UDim.new(0,6))
            Util.Stroke(listFrame, Theme.Blue, 1.5)
            Util.Shadow(listFrame)

            local listScroll = Util.ScrollFrame(listFrame, UDim2.new(1,0,1,0))
            listScroll.ZIndex = 10
            Util.ListLayout(listScroll, Enum.FillDirection.Vertical, 2)
            Util.Padding(listScroll, 4, 4, 4, 4)

            local state   = val
            local open    = false
            local itemH   = 26
            local maxVisible = 5

            local function CloseDropdown()
                open = false
                Util.Tween(listFrame, {Size = UDim2.new(1,0,0,0)}, Theme.FastTween)
                task.delay(0.15, function() listFrame.Visible = false end)
                Util.Tween(arrow, {Rotation = 0})
            end

            local function Populate()
                for _, c in ipairs(listScroll:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for _, item in ipairs(items) do
                    local opt = Util.Button(listScroll, item, UDim2.new(1,-4,0,itemH))
                    opt.BackgroundColor3 = item == state and Theme.Blue or Theme.White
                    opt.TextColor3       = item == state and Theme.White or Theme.TextDark
                    opt.TextXAlignment   = Enum.TextXAlignment.Left
                    opt.TextSize         = 12
                    opt.ZIndex           = 11
                    Util.Corner(opt, UDim.new(0,5))
                    Util.Padding(opt, 0,0,0,8)

                    opt.MouseEnter:Connect(function()
                        if item ~= state then Util.Tween(opt, {BackgroundColor3 = Theme.OffWhite}) end
                    end)
                    opt.MouseLeave:Connect(function()
                        if item ~= state then Util.Tween(opt, {BackgroundColor3 = Theme.White}) end
                    end)
                    opt.MouseButton1Click:Connect(function()
                        state = item
                        dropBtn.Text = item
                        cb(item)
                        if flag and win._configData then win._configData[flag] = item end
                        CloseDropdown()
                        Populate()
                    end)
                end
            end
            Populate()

            dropBtn.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    listFrame.Visible = true
                    local targetH = math.min(#items * (itemH+2) + 8, maxVisible * (itemH+2) + 8)
                    Util.Tween(listFrame, {Size = UDim2.new(1,0,0,targetH)}, Theme.FastTween)
                    Util.Tween(arrow, {Rotation = 180})
                else
                    CloseDropdown()
                end
            end)

            wrapper.MouseEnter:Connect(function() Util.Tween(wrapper, {BackgroundColor3 = Theme.OffWhite}) end)
            wrapper.MouseLeave:Connect(function() Util.Tween(wrapper, {BackgroundColor3 = Theme.White}) end)

            return {
                Set = function(_, v) state = v; dropBtn.Text = v; Populate() end,
                Get = function(_) return state end,
                SetItems = function(_, newItems) items = newItems; Populate() end,
            }
        end

        -- --------------------------------------------------------
        -- COLOR PICKER
        -- --------------------------------------------------------
        function Section:AddColorPicker(copts)
            copts   = copts or {}
            local lbl   = copts.Name    or "Color Picker"
            local val   = copts.Default or Color3.fromRGB(0, 56, 184)
            local cb    = copts.Callback or function() end
            local flag  = copts.Flag

            local row = Util.Frame(compHolder, UDim2.new(1,0,0,40), nil, Theme.White)
            Util.Padding(row, 4,0,4,0)

            local nameLbl = Util.Label(row, lbl, 13, Theme.TextDark)
            nameLbl.Size  = UDim2.new(1,-54,1,0)

            -- Preview swatch
            local swatch = Util.Frame(row, UDim2.new(0,36,0,24), UDim2.new(1,-40,0.5,-12), val)
            Util.Corner(swatch, UDim.new(0,6))
            Util.Stroke(swatch, Theme.LightGray, 1.5)

            -- Picker popup
            local popup = Util.Frame(compHolder, UDim2.new(1,0,0,0), nil, Theme.White)
            popup.ClipsDescendants = true
            popup.Visible          = false
            Util.Corner(popup, UDim.new(0,8))
            Util.Stroke(popup, Theme.Blue, 1.5)

            local pickerInner = Util.Frame(popup, UDim2.new(1,0,0,0), nil, Theme.White)
            pickerInner.AutomaticSize = Enum.AutomaticSize.Y
            Util.Padding(pickerInner, 8,8,8,8)
            Util.ListLayout(pickerInner, Enum.FillDirection.Vertical, 6)

            -- R G B sliders
            local state = val
            local channels = {
                {name="R", key="R", color=Color3.fromRGB(210,50,50)},
                {name="G", key="G", color=Color3.fromRGB(30,180,100)},
                {name="B", key="B", color=Color3.fromRGB(0,100,220)},
            }

            local channelSliders = {}

            for _, ch in ipairs(channels) do
                local chRow = Util.Frame(pickerInner, UDim2.new(1,0,0,22), nil, Theme.White)
                local chLbl = Util.Label(chRow, ch.name, 11, ch.color)
                chLbl.Font  = Enum.Font.GothamBold
                chLbl.Size  = UDim2.new(0,14,1,0)

                local chTrack = Util.Frame(chRow, UDim2.new(1,-20,0,6), UDim2.new(0,18,0.5,-3), Theme.SliderBg)
                Util.Corner(chTrack, UDim.new(1,0))

                local initVal = ch.key == "R" and val.R or ch.key == "G" and val.G or val.B
                local chFill  = Util.Frame(chTrack, UDim2.new(initVal,0,1,0), nil, ch.color)
                Util.Corner(chFill, UDim.new(1,0))

                local chThumb = Instance.new("Frame")
                chThumb.Size             = UDim2.new(0,12,0,12)
                chThumb.Position         = UDim2.new(initVal,0,0.5,-6)
                chThumb.AnchorPoint      = Vector2.new(0.5,0)
                chThumb.BackgroundColor3 = ch.color
                chThumb.BorderSizePixel  = 0
                chThumb.Parent           = chTrack
                Util.Corner(chThumb, UDim.new(1,0))

                local valLbl = Util.Label(chRow, tostring(math.floor(initVal*255)), 10, Theme.TextMid)
                valLbl.Size  = UDim2.new(0,24,1,0)
                valLbl.Position = UDim2.new(1,-24,0,0)
                valLbl.TextXAlignment = Enum.TextXAlignment.Right

                local dragging = false
                local function UpdateCh(absX)
                    local rel = math.clamp((absX - chTrack.AbsolutePosition.X) / chTrack.AbsoluteSize.X,0,1)
                    chFill.Size     = UDim2.new(rel,0,1,0)
                    chThumb.Position= UDim2.new(rel,0,0.5,-6)
                    valLbl.Text     = tostring(math.floor(rel*255))
                    channelSliders[ch.key] = rel
                    state = Color3.new(
                        channelSliders["R"] or state.R,
                        channelSliders["G"] or state.G,
                        channelSliders["B"] or state.B
                    )
                    swatch.BackgroundColor3 = state
                    cb(state)
                    if flag and win._configData then win._configData[flag] = {state.R, state.G, state.B} end
                end

                channelSliders[ch.key] = initVal

                chTrack.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true; UpdateCh(i.Position.X)
                    end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then UpdateCh(i.Position.X) end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
            end

            local popupOpen = false
            swatch.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    popupOpen = not popupOpen
                    if popupOpen then
                        popup.Visible = true
                        Util.Tween(popup, {Size = UDim2.new(1,0,0,90)}, Theme.FastTween)
                    else
                        Util.Tween(popup, {Size = UDim2.new(1,0,0,0)}, Theme.FastTween)
                        task.delay(0.15, function() popup.Visible = false end)
                    end
                end
            end)

            row.MouseEnter:Connect(function() Util.Tween(row, {BackgroundColor3 = Theme.OffWhite}) end)
            row.MouseLeave:Connect(function() Util.Tween(row, {BackgroundColor3 = Theme.White}) end)

            return {
                Set = function(_, v)
                    state = v
                    swatch.BackgroundColor3 = v
                    channelSliders["R"] = v.R
                    channelSliders["G"] = v.G
                    channelSliders["B"] = v.B
                end,
                Get = function(_) return state end,
            }
        end

        -- --------------------------------------------------------
        -- KEYBIND
        -- --------------------------------------------------------
        function Section:AddKeybind(kopts)
            kopts    = kopts or {}
            local lbl    = kopts.Name    or "Keybind"
            local desc   = kopts.Description
            local val    = kopts.Default or Enum.KeyCode.Unknown
            local cb     = kopts.Callback or function() end
            local flag   = kopts.Flag

            local row = Util.Frame(compHolder, UDim2.new(1,0,0,40), nil, Theme.White)
            Util.Padding(row, 4,0,4,0)

            local textCol = Util.Frame(row, UDim2.new(1,-80,1,0), UDim2.new(0,0,0,0), Theme.White)
            Util.ListLayout(textCol, Enum.FillDirection.Vertical, 1, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

            local nameLbl = Util.Label(textCol, lbl, 13, Theme.TextDark)
            nameLbl.Size  = UDim2.new(1,0,0,16)
            if desc then
                local d = Util.Label(textCol, desc, 11, Theme.TextMid)
                d.Size  = UDim2.new(1,0,0,14)
            end

            local state  = val
            local binding= false

            local keyBtn = Util.Button(row, state == Enum.KeyCode.Unknown and "None" or state.Name, UDim2.new(0,72,0,26), UDim2.new(1,-74,0.5,-13))
            keyBtn.BackgroundColor3 = Theme.OffWhite
            keyBtn.TextColor3       = Theme.Blue
            keyBtn.TextSize         = 11
            keyBtn.Font             = Enum.Font.GothamBold
            Util.Corner(keyBtn, UDim.new(0,6))
            Util.Stroke(keyBtn, Theme.LightGray, 1.5)

            keyBtn.MouseButton1Click:Connect(function()
                if binding then return end
                binding = true
                keyBtn.Text      = "..."
                keyBtn.TextColor3= Theme.TextMid
                Util.Tween(keyBtn, {BackgroundColor3 = Theme.LightGray})

                local conn
                conn = UserInputService.InputBegan:Connect(function(i, gp)
                    if gp then return end
                    if i.UserInputType == Enum.UserInputType.Keyboard then
                        state = i.KeyCode
                        keyBtn.Text       = i.KeyCode.Name
                        keyBtn.TextColor3 = Theme.Blue
                        Util.Tween(keyBtn, {BackgroundColor3 = Theme.OffWhite})
                        cb(state)
                        if flag and win._configData then win._configData[flag] = state.Name end
                        binding = false
                        conn:Disconnect()
                    end
                end)
            end)

            keyBtn.MouseEnter:Connect(function() Util.Tween(keyBtn, {BackgroundColor3 = Theme.LightGray}) end)
            keyBtn.MouseLeave:Connect(function()
                if not binding then Util.Tween(keyBtn, {BackgroundColor3 = Theme.OffWhite}) end
            end)
            row.MouseEnter:Connect(function() Util.Tween(row, {BackgroundColor3 = Theme.OffWhite}) end)
            row.MouseLeave:Connect(function() Util.Tween(row, {BackgroundColor3 = Theme.White}) end)

            -- Listen for the key to fire callback globally
            UserInputService.InputBegan:Connect(function(i, gp)
                if gp then return end
                if not binding and i.KeyCode == state then cb(state) end
            end)

            return {
                Set = function(_, v) state = v; keyBtn.Text = v.Name end,
                Get = function(_) return state end,
            }
        end

        -- Auto-resize section
        local layout = compHolder:FindFirstChildWhichIsA("UIListLayout")
        if layout then
            local function UpdateHeight()
                secFrame.Size = UDim2.new(1, 0, 0, 35 + compHolder.AbsoluteSize.Y + 4)
            end
            layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateHeight)
            UpdateHeight()
        end

        return setmetatable(Section, Section)
    end

    return setmetatable(Tab, Tab)
end

-- ============================================================
-- EXPORT
-- ============================================================
return IsraelLib
