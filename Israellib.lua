--[[
    UILib - Optimized & Refactored
    Original: memcorruptv2 style library
    
    CHANGES vs original:
    - Removed RenderStepped per-dropdown-item (replaced with event-driven coloring)
    - Deduplicated outline creation into makeOutlines() helper
    - Replaced all wait() with task.wait() / task.delay()
    - Slider uses UserInputService position instead of camera:WorldToViewportPoint
    - Single shared updateevent replaced with a proper theme observer table
    - Dropdown builder extracted into one shared _buildDropdown() function
    - Connections table per-object for future cleanup support
    - General dead code removal
--]]

-- ============================================================
-- SERVICES
-- ============================================================
local Players          = game:GetService("Players")
local UIS              = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local TextService      = game:GetService("TextService")
local CoreGui          = game:GetService("CoreGui")
local HttpService      = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Mouse  = Player:GetMouse()

-- ============================================================
-- LIBRARY ROOT
-- ============================================================
local Library = {
    flags   = {},
    items   = {},
    _themeListeners = {},   -- replaces hundreds of updateevent connections
}

-- ============================================================
-- THEME
-- ============================================================
Library.theme = {
    fontsize        = 15,
    titlesize       = 18,
    font            = Enum.Font.Code,
    background      = "rbxassetid://5553946656",
    tilesize        = 90,
    cursor          = false,   -- set true if you want Drawing cursor
    cursorimg       = "https://t0.rbxcdn.com/42f66da98c40252ee151326a82aab51f",
    backgroundcolor = Color3.fromRGB(20, 20, 20),
    tabstextcolor   = Color3.fromRGB(240, 240, 240),
    bordercolor     = Color3.fromRGB(60, 60, 60),
    accentcolor     = Color3.fromRGB(28, 56, 139),
    accentcolor2    = Color3.fromRGB(16, 31, 78),
    outlinecolor    = Color3.fromRGB(60, 60, 60),
    outlinecolor2   = Color3.fromRGB(0, 0, 0),
    sectorcolor     = Color3.fromRGB(30, 30, 30),
    toptextcolor    = Color3.fromRGB(255, 255, 255),
    topheight       = 48,
    topcolor        = Color3.fromRGB(30, 30, 30),
    topcolor2       = Color3.fromRGB(30, 30, 30),
    buttoncolor     = Color3.fromRGB(49, 49, 49),
    buttoncolor2    = Color3.fromRGB(39, 39, 39),
    itemscolor      = Color3.fromRGB(200, 200, 200),
    itemscolor2     = Color3.fromRGB(210, 210, 210),
}

-- ============================================================
-- INTERNAL HELPERS
-- ============================================================
local function tween(obj, props, duration, style, direction)
    return TweenService:Create(
        obj,
        TweenInfo.new(duration or 0.1, style or Enum.EasingStyle.Linear, direction or Enum.EasingDirection.In),
        props
    ):Play()
end

-- Register a callback to be fired whenever UpdateTheme is called.
-- Returns a disconnect function for cleanup.
local function onTheme(fn)
    table.insert(Library._themeListeners, fn)
    return function()
        for i, v in ipairs(Library._themeListeners) do
            if v == fn then table.remove(Library._themeListeners, i) break end
        end
    end
end

local function fireTheme(theme)
    for _, fn in ipairs(Library._themeListeners) do
        pcall(fn, theme)
    end
end

-- Create the triple-outline decoration used everywhere.
-- Returns { bo2, outline, bo } (outermost → innermost).
-- Parent: the instance that will contain the outlines.
-- baseSize: UDim2 of the element being outlined.
-- theme: current theme table.
local function makeOutlines(parent, baseSize, theme, zBase)
    zBase = zBase or 4
    local function make(extra, color, pos_extra)
        local f = Instance.new("Frame")
        f.Name            = "outline_auto"
        f.ZIndex          = zBase
        f.Size            = baseSize + UDim2.fromOffset(extra, extra)
        f.Position        = UDim2.fromOffset(-extra / 2, -extra / 2)
        f.BorderSizePixel = 0
        f.BackgroundColor3 = color
        f.Parent          = parent
        return f
    end

    local bo2     = make(6, theme.outlinecolor2)
    local outline = make(4, theme.outlinecolor)
    local bo      = make(2, theme.outlinecolor2)

    -- auto-resize when parent changes size
    parent:GetPropertyChangedSignal("Size"):Connect(function()
        local s = parent.Size
        bo2.Size     = s + UDim2.fromOffset(6, 6)
        outline.Size = s + UDim2.fromOffset(4, 4)
        bo.Size      = s + UDim2.fromOffset(2, 2)
    end)

    local disconnect = onTheme(function(t)
        bo2.BackgroundColor3     = t.outlinecolor2
        outline.BackgroundColor3 = t.outlinecolor
        bo.BackgroundColor3      = t.outlinecolor2
    end)

    return bo2, outline, bo, disconnect
end

-- Shorten keycode names for display.
local SHORT_KEYS = {
    LeftShift    = "LSHIFT", RightShift    = "RSHIFT",
    LeftControl  = "LCTRL",  RightControl  = "RCTRL",
    LeftAlt      = "LALT",   RightAlt      = "RALT",
}
local function keyName(kc)
    if kc == "None" then return "None" end
    local n = kc.Name or tostring(kc)
    return SHORT_KEYS[n] or n
end

-- ============================================================
-- OPTIONAL DRAWING CURSOR
-- ============================================================
if Library.theme.cursor and Drawing then
    local ok = pcall(function()
        local cur = Drawing.new("Image")
        cur.Data     = game:HttpGet(Library.theme.cursorimg)
        cur.Size     = Vector2.new(64, 64)
        cur.Visible  = UIS.MouseEnabled
        cur.Rounding = 0
        cur.Position = Vector2.new(Mouse.X - 32, Mouse.Y + 6)

        UIS.InputChanged:Connect(function(input)
            if UIS.MouseEnabled and input.UserInputType == Enum.UserInputType.MouseMovement then
                cur.Position = Vector2.new(input.Position.X - 32, input.Position.Y + 7)
            end
        end)
        RunService.RenderStepped:Connect(function()
            UIS.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.ForceHide
            cur.Visible = UIS.MouseEnabled
        end)
    end)
    if not ok then warn("[UILib] Failed to create Drawing cursor.") end
end

-- ============================================================
-- WATERMARK
-- ============================================================
function Library:CreateWatermark(name, position)
    local ok, gameName = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId).Name
    end)
    gameName = ok and gameName or "Unknown"

    local wm = { Visible = true }
    local theme = self.theme

    wm.main = Instance.new("ScreenGui")
    wm.main.Name           = "UILib_Watermark"
    wm.main.ResetOnSpawn   = false
    pcall(function() wm.main.Parent = CoreGui end)
    if not wm.main.Parent then wm.main.Parent = Player.PlayerGui end

    if getgenv and getgenv().watermark then
        pcall(function() getgenv().watermark:Destroy() end)
    end
    if getgenv then getgenv().watermark = wm.main end

    -- Main bar
    wm.bar = Instance.new("Frame")
    wm.bar.Name             = "Bar"
    wm.bar.BorderSizePixel  = 0
    wm.bar.ZIndex           = 5
    wm.bar.Position         = UDim2.new(0, position and position.X or 10, 0, position and position.Y or 10)
    wm.bar.BackgroundColor3 = theme.backgroundcolor
    wm.bar.Parent           = wm.main

    local grad = Instance.new("UIGradient")
    grad.Rotation = 90
    grad.Color    = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 10)),
    })
    grad.Parent = wm.bar

    -- Outlines
    wm.outline1 = Instance.new("Frame")
    wm.outline1.Name             = "Outline1"
    wm.outline1.ZIndex           = 4
    wm.outline1.BorderSizePixel  = 0
    wm.outline1.BackgroundColor3 = theme.outlinecolor
    wm.outline1.Position         = UDim2.fromOffset(-1, -1)
    wm.outline1.Parent           = wm.bar

    wm.outline2 = Instance.new("Frame")
    wm.outline2.Name             = "Outline2"
    wm.outline2.ZIndex           = 3
    wm.outline2.BorderSizePixel  = 0
    wm.outline2.BackgroundColor3 = theme.outlinecolor2
    wm.outline2.Position         = UDim2.fromOffset(-2, -2)
    wm.outline2.Parent           = wm.bar

    -- Label
    wm.label = Instance.new("TextLabel")
    wm.label.Name                 = "Label"
    wm.label.BackgroundTransparency = 1
    wm.label.Position             = UDim2.new(0, 0, 0, 0)
    wm.label.Font                 = theme.font
    wm.label.ZIndex               = 6
    wm.label.TextColor3           = Color3.fromRGB(255, 255, 255)
    wm.label.TextSize             = 15
    wm.label.TextStrokeTransparency = 0
    wm.label.TextXAlignment       = Enum.TextXAlignment.Left
    wm.label.Parent               = wm.bar

    -- Top accent
    wm.topbar = Instance.new("Frame")
    wm.topbar.Name            = "TopBar"
    wm.topbar.ZIndex          = 6
    wm.topbar.BackgroundColor3 = theme.accentcolor
    wm.topbar.BorderSizePixel = 0
    wm.topbar.Size            = UDim2.new(0, 0, 0, 1)
    wm.topbar.Parent          = wm.bar

    local function refresh(txt)
        wm.label.Text = " " .. txt .. " "
        local tw = wm.label.TextBounds.X + 4
        wm.bar.Size      = UDim2.new(0, tw, 0, 25)
        wm.label.Size    = UDim2.new(0, tw, 0, 25)
        wm.topbar.Size   = UDim2.new(0, tw + 2, 0, 1)
        wm.outline1.Size = UDim2.new(0, tw + 2, 0, 27)
        wm.outline2.Size = UDim2.new(0, tw + 4, 0, 29)
    end

    local hasFPS    = name:find("{fps}")
    local startTime = os.clock()
    local counter   = 0
    local lastFPS   = -1

    RunService.Heartbeat:Connect(function()
        local v = wm.Visible
        wm.bar.Visible     = v
        wm.topbar.Visible  = v
        wm.outline1.Visible = v
        wm.outline2.Visible = v
        wm.label.Visible   = v

        if hasFPS then
            counter = counter + 1
            local now = os.clock()
            if now - startTime >= 1 then
                local fps = math.floor(counter / (now - startTime))
                counter   = 0
                startTime = now
                if fps ~= lastFPS then
                    lastFPS = fps
                    refresh(name:gsub("{game}", gameName):gsub("{fps}", fps .. " FPS"))
                end
            end
        else
            refresh(name:gsub("{game}", gameName))
        end
    end)

    -- Fade on hover
    local function setAlpha(a)
        tween(wm.bar,     { BackgroundTransparency = a })
        tween(wm.topbar,  { BackgroundTransparency = a })
        tween(wm.label,   { TextTransparency = a })
        tween(wm.outline1, { BackgroundTransparency = a })
        tween(wm.outline2, { BackgroundTransparency = a })
    end
    wm.bar.MouseEnter:Connect(function() setAlpha(1) end)
    wm.bar.MouseLeave:Connect(function() setAlpha(0) end)

    onTheme(function(t)
        wm.outline1.BackgroundColor3 = t.outlinecolor
        wm.outline2.BackgroundColor3 = t.outlinecolor2
        wm.label.Font               = t.font
        wm.topbar.BackgroundColor3  = t.accentcolor
    end)

    refresh(name:gsub("{game}", gameName):gsub("{fps}", "0 FPS"))
    return wm
end

-- ============================================================
-- WINDOW
-- ============================================================
function Library:CreateWindow(name, size, hideKey)
    local win     = {}
    win.name      = name or ""
    win.size      = UDim2.fromOffset(size and size.X or 492, size and size.Y or 598)
    win.hideKey   = hideKey or Enum.KeyCode.RightShift
    win.theme     = self.theme
    win.Tabs      = {}
    win.OpenedColorPickers = {}

    -- ScreenGui
    win.Main = Instance.new("ScreenGui")
    win.Main.Name         = name
    win.Main.DisplayOrder = 15
    win.Main.ResetOnSpawn = false
    pcall(function()
        if syn then syn.protect_gui(win.Main) end
        win.Main.Parent = CoreGui
    end)
    if not win.Main.Parent then win.Main.Parent = Player.PlayerGui end

    if getgenv and getgenv().uilib then
        pcall(function() getgenv().uilib:Destroy() end)
    end
    if getgenv then getgenv().uilib = win.Main end

    -- UpdateTheme API
    function win:UpdateTheme(theme)
        win.theme = theme or Library.theme
        fireTheme(win.theme)
    end

    -- ---- Main frame ----
    win.Frame = Instance.new("TextButton")
    win.Frame.Name            = "main"
    win.Frame.Position        = UDim2.fromScale(0.5, 0.5)
    win.Frame.AnchorPoint     = Vector2.new(0.5, 0.5)
    win.Frame.BorderSizePixel = 0
    win.Frame.Size            = win.size
    win.Frame.AutoButtonColor = false
    win.Frame.Text            = ""
    win.Frame.BackgroundColor3 = win.theme.backgroundcolor
    win.Frame.Parent          = win.Main

    onTheme(function(t) win.Frame.BackgroundColor3 = t.backgroundcolor end)

    -- Triple outline on window
    do
        local function makeWinOutline(extra, color, zi)
            local f = Instance.new("Frame")
            f.Name             = "WinOutline"
            f.ZIndex           = zi
            f.Size             = win.size + UDim2.fromOffset(extra, extra)
            f.BorderSizePixel  = 0
            f.BackgroundColor3 = color
            f.Position         = UDim2.fromOffset(-extra / 2, -extra / 2)
            f.Parent           = win.Frame
        end
        makeWinOutline(2, win.theme.outlinecolor2, 1)
        makeWinOutline(4, win.theme.outlinecolor,  0)
        makeWinOutline(6, win.theme.outlinecolor2, -1)
    end

    -- ---- Dragging ----
    do
        local dragging, dragInput, dragStart, startPos
        local function dragMove(input)
            if dragging then
                local delta = input.Position - dragStart
                win.Frame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end
        local function dragBegin(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging  = true
                dragStart = input.Position
                startPos  = win.Frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end
        local function dragChange(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end
        UIS.InputChanged:Connect(function(input)
            if input == dragInput then dragMove(input) end
        end)

        -- TopBar
        win.TopBar = Instance.new("Frame")
        win.TopBar.Name            = "TopBar"
        win.TopBar.Size            = UDim2.fromOffset(win.size.X.Offset, win.theme.topheight)
        win.TopBar.BorderSizePixel = 0
        win.TopBar.BackgroundColor3 = Color3.new(1,1,1)
        win.TopBar.Parent          = win.Frame
        win.TopBar.InputBegan:Connect(dragBegin)
        win.TopBar.InputChanged:Connect(dragChange)

        onTheme(function(t)
            win.TopBar.Size = UDim2.fromOffset(win.size.X.Offset, t.topheight)
        end)

        local topGrad = Instance.new("UIGradient")
        topGrad.Rotation = 90
        topGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, win.theme.topcolor),
            ColorSequenceKeypoint.new(1, win.theme.topcolor2),
        })
        topGrad.Parent = win.TopBar
        onTheme(function(t)
            topGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, t.topcolor),
                ColorSequenceKeypoint.new(1, t.topcolor2),
            })
        end)
    end

    -- ---- Title label ----
    win.NameLabel = Instance.new("TextLabel")
    win.NameLabel.Name                = "Title"
    win.NameLabel.Text                = win.name
    win.NameLabel.TextColor3          = win.theme.toptextcolor
    win.NameLabel.TextXAlignment      = Enum.TextXAlignment.Left
    win.NameLabel.Font                = win.theme.font
    win.NameLabel.Position            = UDim2.fromOffset(4, -2)
    win.NameLabel.BackgroundTransparency = 1
    win.NameLabel.Size                = UDim2.fromOffset(190, win.TopBar.AbsoluteSize.Y / 2 - 2)
    win.NameLabel.TextSize            = win.theme.titlesize
    win.NameLabel.Parent              = win.TopBar
    onTheme(function(t)
        win.NameLabel.TextColor3 = t.toptextcolor
        win.NameLabel.Font       = t.font
        win.NameLabel.TextSize   = t.titlesize
    end)

    -- Mid-divider line
    win.MidLine = Instance.new("Frame")
    win.MidLine.Name             = "MidLine"
    win.MidLine.Size             = UDim2.fromOffset(win.size.X.Offset, 1)
    win.MidLine.Position         = UDim2.fromOffset(0, win.TopBar.AbsoluteSize.Y / 2.1)
    win.MidLine.BorderSizePixel  = 0
    win.MidLine.BackgroundColor3 = win.theme.accentcolor
    win.MidLine.Parent           = win.TopBar
    onTheme(function(t) win.MidLine.BackgroundColor3 = t.accentcolor end)

    -- TabList (bottom half of topbar)
    win.TabList = Instance.new("Frame")
    win.TabList.Name                 = "TabList"
    win.TabList.BackgroundTransparency = 1
    win.TabList.Position             = UDim2.fromOffset(0, win.TopBar.AbsoluteSize.Y / 2 + 1)
    win.TabList.Size                 = UDim2.fromOffset(win.size.X.Offset, win.TopBar.AbsoluteSize.Y / 2)
    win.TabList.BorderSizePixel      = 0
    win.TabList.Parent               = win.TopBar
    win.TabList.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- allow drag from tab area too
        end
    end)

    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.FillDirection = Enum.FillDirection.Horizontal
    tabListLayout.SortOrder     = Enum.SortOrder.LayoutOrder
    tabListLayout.Parent        = win.TabList

    -- Active tab underline
    win.ActiveLine = Instance.new("Frame")
    win.ActiveLine.Name             = "ActiveLine"
    win.ActiveLine.Size             = UDim2.fromOffset(60, 1)
    win.ActiveLine.Position         = UDim2.fromOffset(0, 0)
    win.ActiveLine.BorderSizePixel  = 0
    win.ActiveLine.BackgroundColor3 = win.theme.accentcolor
    win.ActiveLine.Parent           = win.Frame
    onTheme(function(t) win.ActiveLine.BackgroundColor3 = t.accentcolor end)

    -- Separator between topbar and content
    win.BlackLine = Instance.new("Frame")
    win.BlackLine.Name             = "BlackLine"
    win.BlackLine.Size             = UDim2.fromOffset(win.size.X.Offset, 1)
    win.BlackLine.BorderSizePixel  = 0
    win.BlackLine.ZIndex           = 9
    win.BlackLine.BackgroundColor3 = win.theme.outlinecolor2
    win.BlackLine.Position         = UDim2.fromOffset(0, win.TopBar.AbsoluteSize.Y)
    win.BlackLine.Parent           = win.Frame
    onTheme(function(t) win.BlackLine.BackgroundColor3 = t.outlinecolor2 end)

    -- Background image/tiled pattern
    win.BgImage = Instance.new("ImageLabel")
    win.BgImage.Name               = "Background"
    win.BgImage.BorderSizePixel    = 0
    win.BgImage.ScaleType          = Enum.ScaleType.Tile
    win.BgImage.Position           = win.BlackLine.Position + UDim2.fromOffset(0, 1)
    win.BgImage.Size               = UDim2.fromOffset(win.size.X.Offset, win.size.Y.Offset - win.TopBar.AbsoluteSize.Y - 1)
    win.BgImage.Image              = win.theme.background or ""
    win.BgImage.ImageTransparency  = win.BgImage.Image ~= "" and 0 or 1
    win.BgImage.ImageColor3        = Color3.new()
    win.BgImage.BackgroundColor3   = win.theme.backgroundcolor
    win.BgImage.TileSize           = UDim2.new(0, win.theme.tilesize, 0, win.theme.tilesize)
    win.BgImage.Parent             = win.Frame
    onTheme(function(t)
        win.BgImage.Image              = t.background or ""
        win.BgImage.ImageTransparency  = win.BgImage.Image ~= "" and 0 or 1
        win.BgImage.BackgroundColor3   = t.backgroundcolor
        win.BgImage.TileSize           = UDim2.new(0, t.tilesize, 0, t.tilesize)
    end)

    -- Toggle visibility
    UIS.InputBegan:Connect(function(key)
        if key.KeyCode == win.hideKey then
            win.Frame.Visible = not win.Frame.Visible
        end
    end)

    -- ============================================================
    -- CREATE TAB
    -- ============================================================
    function win:CreateTab(tabName)
        local tab     = {}
        tab.name      = tabName or ""
        tab.Sectors   = { Left = {}, Right = {} }
        local theme   = win.theme

        -- ---- Tab button ----
        local btnSize = TextService:GetTextSize(tab.name, theme.fontsize, theme.font, Vector2.new(200, 300))

        tab.TabButton = Instance.new("TextButton")
        tab.TabButton.Text                = tab.name
        tab.TabButton.TextColor3          = theme.tabstextcolor
        tab.TabButton.AutoButtonColor     = false
        tab.TabButton.Font                = theme.font
        tab.TabButton.TextYAlignment      = Enum.TextYAlignment.Center
        tab.TabButton.BackgroundTransparency = 1
        tab.TabButton.BorderSizePixel     = 0
        tab.TabButton.Size                = UDim2.fromOffset(btnSize.X + 15, win.TabList.AbsoluteSize.Y - 1)
        tab.TabButton.TextSize            = theme.fontsize
        tab.TabButton.Parent              = win.TabList

        onTheme(function(t)
            local s = TextService:GetTextSize(tab.name, t.fontsize, t.font, Vector2.new(200, 300))
            tab.TabButton.Font     = t.font
            tab.TabButton.TextSize = t.fontsize
            tab.TabButton.Size     = UDim2.fromOffset(s.X + 15, win.TabList.AbsoluteSize.Y - 1)
            tab.TabButton.TextColor3 = (tab.TabButton.Name == "SelectedTab")
                and t.accentcolor or t.tabstextcolor
        end)

        -- ---- Left / Right scroll frames ----
        local function makeSide(xOffset)
            local sf = Instance.new("ScrollingFrame")
            sf.BorderSizePixel  = 0
            sf.Size             = UDim2.fromOffset(win.size.X.Offset / 2, win.size.Y.Offset - (win.TopBar.AbsoluteSize.Y + 1))
            sf.BackgroundTransparency = 1
            sf.Visible          = false
            sf.ScrollBarThickness = 0
            sf.ScrollingDirection = Enum.ScrollingDirection.Y
            sf.Position         = win.BlackLine.Position + UDim2.fromOffset(xOffset, 1)
            sf.Parent           = win.Frame

            local ll = Instance.new("UIListLayout")
            ll.FillDirection = Enum.FillDirection.Vertical
            ll.SortOrder     = Enum.SortOrder.LayoutOrder
            ll.Padding       = UDim.new(0, 12)
            ll.Parent        = sf

            local pad = Instance.new("UIPadding")
            pad.PaddingTop   = UDim.new(0, 12)
            pad.PaddingLeft  = UDim.new(0, xOffset == 0 and 12 or 6)
            pad.PaddingRight = UDim.new(0, 12)
            pad.Parent       = sf

            return sf, ll
        end

        tab.Left,  tab.LeftLayout  = makeSide(0)
        tab.Right, tab.RightLayout = makeSide(win.size.X.Offset / 2)

        -- ---- Select tab ----
        local selectLock = false
        function tab:SelectTab()
            if selectLock then return end
            selectLock = true

            for _, t in ipairs(win.Tabs) do
                if t ~= tab then
                    t.TabButton.TextColor3 = Color3.fromRGB(230, 230, 230)
                    t.TabButton.Name       = "Tab"
                    t.Left.Visible         = false
                    t.Right.Visible        = false
                end
            end

            tab.TabButton.TextColor3 = win.theme.accentcolor
            tab.TabButton.Name       = "SelectedTab"
            tab.Left.Visible         = true
            tab.Right.Visible        = true

            -- Animate underline
            local btnSz = TextService:GetTextSize(tab.name, win.theme.fontsize, win.theme.font, Vector2.new(200,300))
            win.ActiveLine:TweenSizeAndPosition(
                UDim2.fromOffset(btnSz.X + 15, 1),
                UDim2.new(0, tab.TabButton.AbsolutePosition.X - win.Frame.AbsolutePosition.X, 0, 0)
                    + (win.BlackLine.Position - UDim2.fromOffset(0, 1)),
                Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.15
            )
            task.delay(0.2, function() selectLock = false end)
        end

        tab.TabButton.MouseButton1Down:Connect(function() tab:SelectTab() end)

        if #win.Tabs == 0 then tab:SelectTab() end
        table.insert(win.Tabs, tab)

        -- ============================================================
        -- SHARED DROPDOWN BUILDER
        -- Called by sector:AddDropdown, colorpicker:AddDropdown, toggle:AddDropdown
        -- ============================================================
        local function _buildDropdown(opts)
            --[[
            opts = {
                parent          Frame/TextButton  (where the dropdown goes)
                sector          sector object      (for FixSize and ScrollingEnabled)
                text            string             (label above the box; nil = no label row)
                items           { string }
                default         string | nil
                multichoice     bool
                callback        fn
                flag            string
                yOffset         number             (vertical offset of the main box; default 0)
            }
            --]]
            local dd = {}
            dd.defaultitems = opts.items or {}
            dd.default      = opts.default
            dd.callback     = opts.callback or function() end
            dd.multichoice  = opts.multichoice or false
            dd.values       = {}
            dd.flag         = opts.flag or ""
            dd.items        = {}

            local theme    = win.theme
            local sector   = opts.sector
            local yOff     = opts.yOffset or 0
            local sectorW  = sector.Main.Size.X.Offset - 12

            -- Optional label row
            if opts.text then
                local lbl = Instance.new("TextLabel")
                lbl.BackgroundTransparency = 1
                lbl.Size       = UDim2.fromOffset(sectorW, 10)
                lbl.Font       = theme.font
                lbl.Text       = opts.text
                lbl.ZIndex     = 4
                lbl.TextColor3 = theme.itemscolor
                lbl.TextSize   = 15
                lbl.TextStrokeTransparency = 1
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent     = opts.parent
                onTheme(function(t) lbl.Font = t.font; lbl.TextColor3 = t.itemscolor end)
                yOff = yOff + 17
            end

            -- Main button
            dd.Main = Instance.new("TextButton")
            dd.Main.Name             = "dropdown"
            dd.Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            dd.Main.BorderSizePixel  = 0
            dd.Main.Size             = UDim2.fromOffset(sectorW, 16)
            dd.Main.Position         = UDim2.fromOffset(0, yOff)
            dd.Main.ZIndex           = 5
            dd.Main.AutoButtonColor  = false
            dd.Main.Font             = theme.font
            dd.Main.Text             = ""
            dd.Main.TextColor3       = Color3.fromRGB(255, 255, 255)
            dd.Main.TextSize         = 15
            dd.Main.TextXAlignment   = Enum.TextXAlignment.Left
            dd.Main.Parent           = opts.parent
            onTheme(function(t) dd.Main.Font = t.font end)

            local grad = Instance.new("UIGradient")
            grad.Rotation = 90
            grad.Color    = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(49, 49, 49)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(39, 39, 39)),
            })
            grad.Parent = dd.Main

            dd.SelectedLabel = Instance.new("TextLabel")
            dd.SelectedLabel.BackgroundTransparency = 1
            dd.SelectedLabel.Position   = UDim2.fromOffset(5, 2)
            dd.SelectedLabel.Size       = UDim2.fromOffset(sectorW - 20, 13)
            dd.SelectedLabel.Font       = theme.font
            dd.SelectedLabel.Text       = opts.text or ""
            dd.SelectedLabel.ZIndex     = 5
            dd.SelectedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            dd.SelectedLabel.TextSize   = 15
            dd.SelectedLabel.TextStrokeTransparency = 1
            dd.SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
            dd.SelectedLabel.Parent     = dd.Main
            onTheme(function(t) dd.SelectedLabel.Font = t.font end)

            dd.Nav = Instance.new("ImageButton")
            dd.Nav.BackgroundTransparency = 1
            dd.Nav.Position  = UDim2.fromOffset(sectorW - 14, 5)
            dd.Nav.Rotation  = 90
            dd.Nav.ZIndex    = 5
            dd.Nav.Size      = UDim2.fromOffset(8, 8)
            dd.Nav.Image     = "rbxassetid://4918373417"
            dd.Nav.ImageColor3 = Color3.fromRGB(210, 210, 210)
            dd.Nav.Parent    = dd.Main

            -- Outlines on main
            local bo2 = Instance.new("Frame")
            bo2.Name             = "outline"
            bo2.ZIndex           = 4
            bo2.Size             = dd.Main.Size + UDim2.fromOffset(6, 6)
            bo2.BorderSizePixel  = 0
            bo2.BackgroundColor3 = theme.outlinecolor2
            bo2.Position         = UDim2.fromOffset(-3, -3)
            bo2.Parent           = dd.Main
            onTheme(function(t) bo2.BackgroundColor3 = t.outlinecolor2 end)

            -- Items scrolling frame
            dd.ItemsFrame = Instance.new("ScrollingFrame")
            dd.ItemsFrame.BorderSizePixel  = 0
            dd.ItemsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            dd.ItemsFrame.Position         = UDim2.fromOffset(0, dd.Main.Size.Y.Offset + 8)
            dd.ItemsFrame.ScrollBarThickness = 2
            dd.ItemsFrame.ZIndex           = 8
            dd.ItemsFrame.ScrollingDirection = Enum.ScrollingDirection.Y
            dd.ItemsFrame.Visible          = false
            dd.ItemsFrame.Size             = UDim2.fromOffset(0, 0)
            dd.ItemsFrame.CanvasSize       = UDim2.fromOffset(sectorW, 0)
            dd.ItemsFrame.Parent           = dd.Main

            local ddLL = Instance.new("UIListLayout")
            ddLL.FillDirection = Enum.FillDirection.Vertical
            ddLL.SortOrder     = Enum.SortOrder.LayoutOrder
            ddLL.Parent        = dd.ItemsFrame

            local ddPad = Instance.new("UIPadding")
            ddPad.PaddingTop    = UDim.new(0, 2)
            ddPad.PaddingBottom = UDim.new(0, 2)
            ddPad.PaddingLeft   = UDim.new(0, 2)
            ddPad.PaddingRight  = UDim.new(0, 2)
            ddPad.Parent        = dd.ItemsFrame

            -- Outline frames for items box
            local bo2i = Instance.new("Frame")
            bo2i.ZIndex           = 7
            bo2i.BorderSizePixel  = 0
            bo2i.BackgroundColor3 = theme.outlinecolor2
            bo2i.Visible          = false
            bo2i.Parent           = dd.Main
            onTheme(function(t) bo2i.BackgroundColor3 = t.outlinecolor2 end)

            local function _syncItemBoxOutlines()
                local s = dd.ItemsFrame.Size
                bo2i.Size     = s + UDim2.fromOffset(6, 6)
                bo2i.Position = dd.ItemsFrame.Position + UDim2.fromOffset(-3, -3)
            end

            if library.flags and dd.flag ~= "" then
                Library.flags[dd.flag] = dd.multichoice
                    and { dd.default or dd.defaultitems[1] or "" }
                    or (dd.default or dd.defaultitems[1] or "")
            end

            function dd:isSelected(item)
                for _, v in ipairs(dd.values) do if v == item then return true end end
                return false
            end

            function dd:updateText(text)
                if #text >= 27 then text = text:sub(1, 25) .. ".." end
                dd.SelectedLabel.Text = text
            end

            dd.Changed = Instance.new("BindableEvent")
            function dd:Set(value)
                if type(value) == "table" then
                    dd.values = value
                    dd:updateText(table.concat(value, ", "))
                else
                    dd:updateText(value)
                    dd.values = { value }
                end
                dd.Changed:Fire(value)
                if dd.flag ~= "" then
                    Library.flags[dd.flag] = dd.multichoice and dd.values or dd.values[1]
                end
                pcall(dd.callback, value)
                -- Refresh item highlight colors (event-driven, no RenderStepped)
                for _, child in ipairs(dd.ItemsFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        local sel = dd.multichoice and dd:isSelected(child.Name) or dd.values[1] == child.Name
                        child.BackgroundColor3 = sel and Color3.fromRGB(64, 64, 64) or Color3.fromRGB(40, 40, 40)
                        child.TextColor3       = sel and win.theme.accentcolor or Color3.fromRGB(255, 255, 255)
                        child.Text             = sel and (" " .. child.Name) or child.Name
                    end
                end
            end

            function dd:Get()
                return dd.multichoice and dd.values or dd.values[1]
            end

            function dd:Add(v)
                local item = Instance.new("TextButton")
                item.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                item.TextColor3       = Color3.fromRGB(255, 255, 255)
                item.BorderSizePixel  = 0
                item.Size             = UDim2.fromOffset(sectorW - 4, 20)
                item.ZIndex           = 9
                item.Text             = v
                item.Name             = v
                item.AutoButtonColor  = false
                item.Font             = theme.font
                item.TextSize         = 15
                item.TextXAlignment   = Enum.TextXAlignment.Left
                item.TextStrokeTransparency = 1
                item.Parent           = dd.ItemsFrame

                table.insert(dd.items, v)
                local h = #dd.items * item.AbsoluteSize.Y
                dd.ItemsFrame.Size       = UDim2.fromOffset(sectorW, math.clamp(h, 20, 156) + 4)
                dd.ItemsFrame.CanvasSize = UDim2.fromOffset(sectorW, h + 4)
                _syncItemBoxOutlines()
                bo2i.Size     = dd.ItemsFrame.Size + UDim2.fromOffset(6, 6)
                bo2i.Position = dd.ItemsFrame.Position + UDim2.fromOffset(-3, -3)

                item.MouseButton1Down:Connect(function()
                    if dd.multichoice then
                        if dd:isSelected(v) then
                            for i2, v2 in ipairs(dd.values) do
                                if v2 == v then table.remove(dd.values, i2); break end
                            end
                            dd:Set(dd.values)
                        else
                            table.insert(dd.values, v)
                            dd:Set(dd.values)
                        end
                    else
                        dd:Set(v)
                        -- Close
                        dd.Nav.Rotation       = 90
                        dd.ItemsFrame.Visible = false
                        dd.ItemsFrame.Active  = false
                        bo2i.Visible          = false
                        if sector then sector.Main.Parent.ScrollingEnabled = true end
                    end
                end)
            end

            function dd:Remove(value)
                local item = dd.ItemsFrame:FindFirstChild(value)
                if not item then return end
                for i, v in ipairs(dd.items) do
                    if v == value then table.remove(dd.items, i); break end
                end
                local h = #dd.items * item.AbsoluteSize.Y
                dd.ItemsFrame.Size       = UDim2.fromOffset(sectorW, math.clamp(h, 20, 156) + 4)
                dd.ItemsFrame.CanvasSize = UDim2.fromOffset(sectorW, h + 4)
                _syncItemBoxOutlines()
                item:Destroy()
            end

            -- Populate defaults
            for _, v in ipairs(dd.defaultitems) do dd:Add(v) end
            if dd.default then dd:Set(dd.default) end

            -- Open / close toggle
            local function toggleOpen()
                if dd.Nav.Rotation == 90 then
                    tween(dd.Nav, { Rotation = -90 })
                    if #dd.items > 0 then
                        if sector then sector.Main.Parent.ScrollingEnabled = false end
                        dd.ItemsFrame.ScrollingEnabled = true
                        dd.ItemsFrame.Visible = true
                        dd.ItemsFrame.Active  = true
                        bo2i.Visible = true
                    end
                else
                    tween(dd.Nav, { Rotation = 90 })
                    if sector then sector.Main.Parent.ScrollingEnabled = true end
                    dd.ItemsFrame.ScrollingEnabled = false
                    dd.ItemsFrame.Visible = false
                    dd.ItemsFrame.Active  = false
                    bo2i.Visible = false
                end
            end
            dd.Main.MouseButton1Down:Connect(toggleOpen)
            dd.Nav.MouseButton1Down:Connect(toggleOpen)

            bo2.MouseEnter:Connect(function() bo2.BackgroundColor3 = win.theme.accentcolor end)
            bo2.MouseLeave:Connect(function() bo2.BackgroundColor3 = win.theme.outlinecolor2 end)

            sector:FixSize()
            table.insert(Library.items, dd)
            return dd
        end

        -- ============================================================
        -- CREATE SECTOR
        -- ============================================================
        function tab:CreateSector(sectorName, side)
            local sector     = {}
            sector.name      = sectorName or ""
            sector.side      = (side or "left"):lower()

            local parentFrame = sector.side == "left" and tab.Left or tab.Right
            local sectorW     = win.size.X.Offset / 2 - 17

            sector.Main = Instance.new("Frame")
            sector.Main.Name             = sector.name:gsub(" ", "") .. "Sector"
            sector.Main.BorderSizePixel  = 0
            sector.Main.ZIndex           = 4
            sector.Main.Size             = UDim2.fromOffset(sectorW, 20)
            sector.Main.BackgroundColor3 = win.theme.sectorcolor
            sector.Main.Parent           = parentFrame
            onTheme(function(t) sector.Main.BackgroundColor3 = t.sectorcolor end)

            -- Top accent line
            sector.Line = Instance.new("Frame")
            sector.Line.Name             = "Line"
            sector.Line.ZIndex           = 4
            sector.Line.Size             = UDim2.fromOffset(sectorW + 4, 1)
            sector.Line.BorderSizePixel  = 0
            sector.Line.Position         = UDim2.fromOffset(-2, -2)
            sector.Line.BackgroundColor3 = win.theme.accentcolor
            sector.Line.Parent           = sector.Main
            onTheme(function(t) sector.Line.BackgroundColor3 = t.accentcolor end)

            -- Auto-resizing outlines
            local sbo2 = Instance.new("Frame")
            sbo2.Name             = "Outline3"
            sbo2.ZIndex           = 1
            sbo2.BorderSizePixel  = 0
            sbo2.BackgroundColor3 = win.theme.outlinecolor2
            sbo2.Position         = UDim2.fromOffset(-3, -3)
            sbo2.Parent           = sector.Main
            local sbo1 = Instance.new("Frame")
            sbo1.Name             = "Outline2"
            sbo1.ZIndex           = 2
            sbo1.BorderSizePixel  = 0
            sbo1.BackgroundColor3 = win.theme.outlinecolor
            sbo1.Position         = UDim2.fromOffset(-2, -2)
            sbo1.Parent           = sector.Main
            local sbo0 = Instance.new("Frame")
            sbo0.Name             = "Outline1"
            sbo0.ZIndex           = 3
            sbo0.BorderSizePixel  = 0
            sbo0.BackgroundColor3 = win.theme.outlinecolor2
            sbo0.Position         = UDim2.fromOffset(-1, -1)
            sbo0.Parent           = sector.Main

            local function syncSectorOutlines()
                local s = sector.Main.Size
                sbo2.Size = s + UDim2.fromOffset(6, 6)
                sbo1.Size = s + UDim2.fromOffset(4, 4)
                sbo0.Size = s + UDim2.fromOffset(2, 2)
            end
            sector.Main:GetPropertyChangedSignal("Size"):Connect(syncSectorOutlines)
            syncSectorOutlines()
            onTheme(function(t)
                sbo2.BackgroundColor3 = t.outlinecolor2
                sbo1.BackgroundColor3 = t.outlinecolor
                sbo0.BackgroundColor3 = t.outlinecolor2
            end)

            -- Sector title
            local tsz = TextService:GetTextSize(sector.name, 15, win.theme.font, Vector2.new(2000, 2000))
            sector.Label = Instance.new("TextLabel")
            sector.Label.AnchorPoint     = Vector2.new(0, 0.5)
            sector.Label.Position        = UDim2.fromOffset(12, -1)
            sector.Label.Size            = UDim2.fromOffset(math.min(tsz.X + 13, sectorW), tsz.Y)
            sector.Label.BackgroundTransparency = 1
            sector.Label.ZIndex          = 6
            sector.Label.Text            = sector.name
            sector.Label.TextColor3      = Color3.new(1, 1, 2552/255)
            sector.Label.TextStrokeTransparency = 1
            sector.Label.Font            = win.theme.font
            sector.Label.TextSize        = 15
            sector.Label.Parent          = sector.Main
            onTheme(function(t) sector.Label.Font = t.font end)

            -- Label background
            sector.LabelBg = Instance.new("Frame")
            sector.LabelBg.ZIndex           = 5
            sector.LabelBg.Size             = UDim2.fromOffset(sector.Label.Size.X.Offset, 10)
            sector.LabelBg.BorderSizePixel  = 0
            sector.LabelBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            sector.LabelBg.Position         = UDim2.fromOffset(sector.Label.Position.X.Offset, sbo2.Position.Y.Offset)
            sector.LabelBg.Parent           = sector.Main

            -- Items container
            sector.Items = Instance.new("Frame")
            sector.Items.Name                = "Items"
            sector.Items.ZIndex              = 2
            sector.Items.BackgroundTransparency = 1
            sector.Items.Size                = UDim2.fromOffset(sectorW, 0)
            sector.Items.AutomaticSize       = Enum.AutomaticSize.Y
            sector.Items.BorderSizePixel     = 0
            sector.Items.Parent              = sector.Main

            local itemsLayout = Instance.new("UIListLayout")
            itemsLayout.FillDirection = Enum.FillDirection.Vertical
            itemsLayout.SortOrder     = Enum.SortOrder.LayoutOrder
            itemsLayout.Padding       = UDim.new(0, 12)
            itemsLayout.Parent        = sector.Items

            local itemsPad = Instance.new("UIPadding")
            itemsPad.PaddingTop   = UDim.new(0, 15)
            itemsPad.PaddingLeft  = UDim.new(0, 6)
            itemsPad.PaddingRight = UDim.new(0, 6)
            itemsPad.Parent       = sector.Items

            table.insert(tab.Sectors[sector.side == "left" and "Left" or "Right"], sector)

            function sector:FixSize()
                sector.Main.Size = UDim2.fromOffset(sectorW, itemsLayout.AbsoluteContentSize.Y + 22)
                local sizeL, sizeR = 0, 0
                for _, s in ipairs(tab.Sectors.Left) do
                    sizeL = sizeL + s.Main.AbsoluteSize.Y
                end
                for _, s in ipairs(tab.Sectors.Right) do
                    sizeR = sizeR + s.Main.AbsoluteSize.Y
                end
                tab.Left.CanvasSize  = UDim2.fromOffset(tab.Left.AbsoluteSize.X,
                    sizeL + (#tab.Sectors.Left - 1) * 12 + 20)
                tab.Right.CanvasSize = UDim2.fromOffset(tab.Right.AbsoluteSize.X,
                    sizeR + (#tab.Sectors.Right - 1) * 12 + 20)
            end

            -- --------------------------------------------------------
            -- BUTTON
            -- --------------------------------------------------------
            function sector:AddButton(text, callback)
                local btn = {}
                btn.text     = text or ""
                btn.callback = callback or function() end

                btn.Main = Instance.new("TextButton")
                btn.Main.BorderSizePixel  = 0
                btn.Main.Text             = ""
                btn.Main.AutoButtonColor  = false
                btn.Main.ZIndex           = 5
                btn.Main.Size             = UDim2.fromOffset(sectorW - 12, 14)
                btn.Main.BackgroundColor3 = Color3.new(1,1,1)
                btn.Main.Parent           = sector.Items

                local g = Instance.new("UIGradient")
                g.Rotation = 90
                g.Color    = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, win.theme.buttoncolor),
                    ColorSequenceKeypoint.new(1, win.theme.buttoncolor2),
                })
                g.Parent = btn.Main
                onTheme(function(t)
                    g.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, t.buttoncolor),
                        ColorSequenceKeypoint.new(1, t.buttoncolor2),
                    })
                end)

                local bo2b, _, _ = makeOutlines(btn.Main, btn.Main.Size, win.theme, 4)

                btn.Label = Instance.new("TextLabel")
                btn.Label.BackgroundTransparency = 1
                btn.Label.Position  = UDim2.new(0, -1, 0, 0)
                btn.Label.ZIndex    = 5
                btn.Label.Size      = btn.Main.Size
                btn.Label.Font      = win.theme.font
                btn.Label.Text      = btn.text
                btn.Label.TextColor3 = win.theme.itemscolor2
                btn.Label.TextSize  = 15
                btn.Label.TextStrokeTransparency = 1
                btn.Label.TextXAlignment = Enum.TextXAlignment.Center
                btn.Label.Parent    = btn.Main
                onTheme(function(t)
                    btn.Label.Font       = t.font
                    btn.Label.TextColor3 = t.itemscolor
                end)

                btn.Main.MouseButton1Down:Connect(btn.callback)
                bo2b.MouseEnter:Connect(function() bo2b.BackgroundColor3 = win.theme.accentcolor end)
                bo2b.MouseLeave:Connect(function() bo2b.BackgroundColor3 = win.theme.outlinecolor2 end)

                sector:FixSize()
                return btn
            end

            -- --------------------------------------------------------
            -- LABEL
            -- --------------------------------------------------------
            function sector:AddLabel(text)
                local lbl = {}
                lbl.Main = Instance.new("TextLabel")
                lbl.Main.BackgroundTransparency = 1
                lbl.Main.ZIndex    = 4
                lbl.Main.AutomaticSize = Enum.AutomaticSize.XY
                lbl.Main.Font      = win.theme.font
                lbl.Main.Text      = text or ""
                lbl.Main.TextColor3 = win.theme.itemscolor
                lbl.Main.TextSize  = 15
                lbl.Main.TextStrokeTransparency = 1
                lbl.Main.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Main.Parent    = sector.Items
                onTheme(function(t)
                    lbl.Main.Font       = t.font
                    lbl.Main.TextColor3 = t.itemscolor
                end)

                function lbl:Set(v) lbl.Main.Text = v end

                sector:FixSize()
                return lbl
            end

            -- --------------------------------------------------------
            -- SEPARATOR
            -- --------------------------------------------------------
            function sector:AddSeparator(text)
                local sep = {}
                sep.text = text or ""

                sep.Main = Instance.new("Frame")
                sep.Main.ZIndex           = 5
                sep.Main.Size             = UDim2.fromOffset(sectorW - 12, 10)
                sep.Main.BorderSizePixel  = 0
                sep.Main.BackgroundTransparency = 1
                sep.Main.Parent           = sector.Items

                sep.Line = Instance.new("Frame")
                sep.Line.ZIndex           = 7
                sep.Line.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                sep.Line.BorderSizePixel  = 0
                sep.Line.Size             = UDim2.fromOffset(sectorW - 26, 1)
                sep.Line.Position         = UDim2.fromOffset(7, 5)
                sep.Line.Parent           = sep.Main

                sep.LineOutline = Instance.new("Frame")
                sep.LineOutline.ZIndex           = 6
                sep.LineOutline.BorderSizePixel  = 0
                sep.LineOutline.BackgroundColor3 = win.theme.outlinecolor2
                sep.LineOutline.Position         = UDim2.fromOffset(-1, -1)
                sep.LineOutline.Size             = sep.Line.Size + UDim2.fromOffset(2, 2)
                sep.LineOutline.Parent           = sep.Line
                onTheme(function(t) sep.LineOutline.BackgroundColor3 = t.outlinecolor2 end)

                sep.Label = Instance.new("TextLabel")
                sep.Label.BackgroundTransparency = 1
                sep.Label.Size     = sep.Main.Size
                sep.Label.Font     = win.theme.font
                sep.Label.ZIndex   = 8
                sep.Label.Text     = sep.text
                sep.Label.TextColor3 = Color3.fromRGB(255,255,255)
                sep.Label.TextSize = win.theme.fontsize
                sep.Label.TextStrokeTransparency = 1
                sep.Label.TextXAlignment = Enum.TextXAlignment.Center
                sep.Label.Parent   = sep.Main
                onTheme(function(t)
                    sep.Label.Font     = t.font
                    sep.Label.TextSize = t.fontsize
                end)

                local tSz = TextService:GetTextSize(sep.text, win.theme.fontsize, win.theme.font, Vector2.new(2000, 2000))
                sep.LabelBg = Instance.new("Frame")
                sep.LabelBg.ZIndex           = 7
                sep.LabelBg.Size             = UDim2.fromOffset(tSz.X + 12, 10)
                sep.LabelBg.BorderSizePixel  = 0
                sep.LabelBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                sep.LabelBg.Position         = UDim2.new(0.5, -(tSz.X / 2) - 6, 0, 0)
                sep.LabelBg.Parent           = sep.Main

                sector:FixSize()
                return sep
            end

            -- --------------------------------------------------------
            -- SLIDER
            -- --------------------------------------------------------
            function sector:AddSlider(text, minVal, defaultVal, maxVal, decimals, callback, flag)
                local sl = {}
                sl.text     = text or ""
                sl.callback = callback or function() end
                sl.min      = minVal   or 0
                sl.max      = maxVal   or 100
                sl.decimals = decimals or 1
                sl.default  = defaultVal or sl.min
                sl.flag     = flag or text or ""
                sl.value    = sl.default

                local dragging = false
                local theme    = win.theme

                sl.MainBack = Instance.new("Frame")
                sl.MainBack.ZIndex           = 7
                sl.MainBack.Size             = UDim2.fromOffset(sectorW - 12, 25)
                sl.MainBack.BorderSizePixel  = 0
                sl.MainBack.BackgroundTransparency = 1
                sl.MainBack.Parent           = sector.Items

                sl.Label = Instance.new("TextLabel")
                sl.Label.BackgroundTransparency = 1
                sl.Label.Size       = UDim2.fromOffset(sectorW - 12, 6)
                sl.Label.Font       = theme.font
                sl.Label.Text       = sl.text .. ":"
                sl.Label.TextColor3 = theme.itemscolor
                sl.Label.TextSize   = 15
                sl.Label.ZIndex     = 4
                sl.Label.TextStrokeTransparency = 1
                sl.Label.TextXAlignment = Enum.TextXAlignment.Left
                sl.Label.Parent     = sl.MainBack
                onTheme(function(t)
                    sl.Label.Font       = t.font
                    sl.Label.TextColor3 = t.itemscolor
                end)

                local lblW = TextService:GetTextSize(sl.Label.Text, 15, theme.font, Vector2.new(200, 300)).X

                sl.ValueBox = Instance.new("TextBox")
                sl.ValueBox.BackgroundTransparency = 1
                sl.ValueBox.ClearTextOnFocus = false
                sl.ValueBox.Size       = UDim2.fromOffset(sectorW - lblW - 15, 12)
                sl.ValueBox.Font       = theme.font
                sl.ValueBox.Text       = tostring(sl.default)
                sl.ValueBox.TextColor3 = theme.itemscolor
                sl.ValueBox.Position   = UDim2.fromOffset(lblW + 3, -3)
                sl.ValueBox.TextSize   = 15
                sl.ValueBox.ZIndex     = 4
                sl.ValueBox.TextStrokeTransparency = 1
                sl.ValueBox.TextXAlignment = Enum.TextXAlignment.Left
                sl.ValueBox.Parent     = sl.MainBack
                onTheme(function(t)
                    sl.ValueBox.Font       = t.font
                    sl.ValueBox.TextColor3 = t.itemscolor
                end)

                sl.Track = Instance.new("TextButton")
                sl.Track.Name            = "SliderTrack"
                sl.Track.BackgroundColor3 = Color3.new(1,1,1)
                sl.Track.Position        = UDim2.fromOffset(0, 15)
                sl.Track.BorderSizePixel = 0
                sl.Track.Size            = UDim2.fromOffset(sectorW - 12, 12)
                sl.Track.AutoButtonColor = false
                sl.Track.Text            = ""
                sl.Track.ZIndex          = 5
                sl.Track.Parent          = sl.MainBack

                local tg = Instance.new("UIGradient")
                tg.Rotation = 90
                tg.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(49, 49, 49)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(41, 41, 41)),
                })
                tg.Parent = sl.Track

                local bo2s, _, _ = makeOutlines(sl.Track, sl.Track.Size, win.theme, 4)

                sl.Fill = Instance.new("Frame")
                sl.Fill.BackgroundColor3 = Color3.new(1,1,1)
                sl.Fill.ZIndex           = 5
                sl.Fill.BorderSizePixel  = 0
                sl.Fill.Size             = UDim2.fromOffset(0, sl.Track.Size.Y.Offset)
                sl.Fill.Parent           = sl.Track

                local fg = Instance.new("UIGradient")
                fg.Rotation = 90
                fg.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, win.theme.accentcolor),
                    ColorSequenceKeypoint.new(1, win.theme.accentcolor2),
                })
                fg.Parent = sl.Fill
                onTheme(function(t)
                    fg.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, t.accentcolor),
                        ColorSequenceKeypoint.new(1, t.accentcolor2),
                    })
                end)

                bo2s.MouseEnter:Connect(function() bo2s.BackgroundColor3 = win.theme.accentcolor end)
                bo2s.MouseLeave:Connect(function() bo2s.BackgroundColor3 = win.theme.outlinecolor2 end)

                if sl.flag ~= "" then Library.flags[sl.flag] = sl.default end

                function sl:Set(value)
                    sl.value = math.clamp(
                        math.round(value * sl.decimals) / sl.decimals,
                        sl.min, sl.max
                    )
                    local pct = (sl.value - sl.min) / (sl.max - sl.min)
                    if sl.flag ~= "" then Library.flags[sl.flag] = sl.value end
                    sl.Fill:TweenSize(
                        UDim2.fromOffset(pct * sl.Track.AbsoluteSize.X, sl.Track.AbsoluteSize.Y),
                        Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.05
                    )
                    sl.ValueBox.Text = tostring(sl.value)
                    pcall(sl.callback, sl.value)
                end
                sl:Set(sl.default)

                -- FIX: use UIS position directly, not camera:WorldToViewportPoint
                local function refresh()
                    local absX  = sl.Track.AbsolutePosition.X
                    local width = sl.Track.AbsoluteSize.X
                    local mouseX = UIS:GetMouseLocation().X
                    local pct  = math.clamp((mouseX - absX) / width, 0, 1)
                    local val  = math.floor((sl.min + (sl.max - sl.min) * pct) * sl.decimals) / sl.decimals
                    sl:Set(math.clamp(val, sl.min, sl.max))
                end

                sl.Track.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true; refresh()
                    end
                end)
                sl.Track.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                sl.Fill.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true; refresh()
                    end
                end)
                sl.Fill.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                UIS.InputChanged:Connect(function(i)
                    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then refresh() end
                end)

                sl.ValueBox.FocusLost:Connect(function(ret)
                    if not ret then return end
                    local n = tonumber(sl.ValueBox.Text)
                    if n then sl:Set(n) else sl.ValueBox.Text = tostring(sl.value) end
                end)

                function sl:Get() return sl.value end

                sector:FixSize()
                table.insert(Library.items, sl)
                return sl
            end

            -- --------------------------------------------------------
            -- TOGGLE
            -- --------------------------------------------------------
            function sector:AddToggle(text, default, callback, flag)
                local tog = {}
                tog.text     = text or ""
                tog.callback = callback or function() end
                tog.flag     = flag or text or ""
                tog.value    = default or false

                local theme = win.theme

                tog.Main = Instance.new("TextButton")
                tog.Main.Name            = "toggle"
                tog.Main.BackgroundColor3 = Color3.new(1,1,1)
                tog.Main.BorderSizePixel = 0
                tog.Main.Size            = UDim2.fromOffset(8, 8)
                tog.Main.AutoButtonColor = false
                tog.Main.ZIndex          = 5
                tog.Main.Text            = ""
                tog.Main.Parent          = sector.Items

                local tg2 = Instance.new("UIGradient")
                tg2.Rotation = 22.5 * 13
                tg2.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(30,30,30)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(45,45,45)),
                })
                tg2.Parent = tog.Main

                local bo2t, _, _ = makeOutlines(tog.Main, tog.Main.Size, theme, 4)

                -- Checked fill
                tog.CheckedFrame = Instance.new("Frame")
                tog.CheckedFrame.ZIndex           = 5
                tog.CheckedFrame.BorderSizePixel  = 0
                tog.CheckedFrame.BackgroundColor3 = Color3.new(1,1,1)
                tog.CheckedFrame.Size             = tog.Main.Size
                tog.CheckedFrame.Visible          = false
                tog.CheckedFrame.Parent           = tog.Main

                local cg = Instance.new("UIGradient")
                cg.Rotation = 22.5 * 13
                cg.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, theme.accentcolor2),
                    ColorSequenceKeypoint.new(1, theme.accentcolor),
                })
                cg.Parent = tog.CheckedFrame
                onTheme(function(t)
                    cg.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, t.accentcolor2),
                        ColorSequenceKeypoint.new(1, t.accentcolor),
                    })
                end)

                -- Label
                tog.Label = Instance.new("TextButton")
                tog.Label.AutoButtonColor    = false
                tog.Label.BackgroundTransparency = 1
                tog.Label.Position           = UDim2.fromOffset(tog.Main.AbsoluteSize.X + 10, -2)
                tog.Label.Size               = UDim2.fromOffset(sectorW - 71, 14)
                tog.Label.Font               = theme.font
                tog.Label.ZIndex             = 5
                tog.Label.Text               = tog.text
                tog.Label.TextColor3         = theme.itemscolor
                tog.Label.TextSize           = 15
                tog.Label.TextStrokeTransparency = 1
                tog.Label.TextXAlignment     = Enum.TextXAlignment.Left
                tog.Label.Parent             = tog.Main
                onTheme(function(t)
                    tog.Label.Font       = t.font
                    tog.Label.TextColor3 = tog.value and t.itemscolor2 or t.itemscolor
                end)

                -- Extra items row (keybind, colorpicker inline)
                tog.Items = Instance.new("Frame")
                tog.Items.Name               = "ExtraItems"
                tog.Items.ZIndex             = 4
                tog.Items.Size               = UDim2.fromOffset(60, 14)
                tog.Items.BorderSizePixel    = 0
                tog.Items.BackgroundTransparency = 1
                tog.Items.Position           = UDim2.fromOffset(sectorW - 71, 0)
                tog.Items.Parent             = tog.Main

                local extLayout = Instance.new("UIListLayout")
                extLayout.FillDirection      = Enum.FillDirection.Horizontal
                extLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                extLayout.SortOrder          = Enum.SortOrder.LayoutOrder
                extLayout.Padding            = UDim.new(0.04, 6)
                extLayout.Parent             = tog.Items

                if tog.flag ~= "" then Library.flags[tog.flag] = tog.value end

                function tog:Set(value, silent)
                    tog.value = value
                    tog.CheckedFrame.Visible = value
                    tog.Label.TextColor3 = value and win.theme.itemscolor2 or win.theme.itemscolor
                    if tog.flag ~= "" then Library.flags[tog.flag] = value end
                    if not silent then pcall(tog.callback, value) end
                end
                function tog:Get() return tog.value end
                tog:Set(tog.value, true)

                -- Click handlers
                tog.Main.MouseButton1Down:Connect(function() tog:Set(not tog.value) end)
                tog.Label.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then tog:Set(not tog.value) end
                end)
                bo2t.MouseEnter:Connect(function() bo2t.BackgroundColor3 = win.theme.accentcolor end)
                bo2t.MouseLeave:Connect(function() bo2t.BackgroundColor3 = win.theme.outlinecolor2 end)
                tog.Label.MouseEnter:Connect(function() bo2t.BackgroundColor3 = win.theme.accentcolor end)
                tog.Label.MouseLeave:Connect(function() bo2t.BackgroundColor3 = win.theme.outlinecolor2 end)

                -- ---- Keybind on toggle ----
                function tog:AddKeybind(defaultKey, kflag)
                    local kb = {}
                    kb.default = defaultKey or "None"
                    kb.value   = kb.default
                    kb.flag    = kflag or (tog.text .. "_kb")

                    local dispText = "[" .. keyName(kb.default) .. "]"
                    local kSz = TextService:GetTextSize(dispText, 15, win.theme.font, Vector2.new(2000, 2000))

                    kb.Main = Instance.new("TextButton")
                    kb.Main.BackgroundTransparency = 1
                    kb.Main.BorderSizePixel  = 0
                    kb.Main.ZIndex           = 5
                    kb.Main.Size             = UDim2.fromOffset(kSz.X + 2, kSz.Y - 7)
                    kb.Main.Text             = dispText
                    kb.Main.Font             = win.theme.font
                    kb.Main.TextColor3       = Color3.fromRGB(136, 136, 136)
                    kb.Main.TextSize         = 15
                    kb.Main.TextXAlignment   = Enum.TextXAlignment.Right
                    kb.Main.Parent           = tog.Items
                    onTheme(function(t)
                        kb.Main.Font = t.font
                        kb.Main.TextColor3 = kb.Main.Text == "[...]"
                            and t.accentcolor or Color3.fromRGB(136, 136, 136)
                    end)

                    if kb.flag ~= "" then Library.flags[kb.flag] = kb.default end

                    function kb:Set(key)
                        kb.value = key
                        kb.Main.Text = "[" .. keyName(key) .. "]"
                        if kb.flag ~= "" then Library.flags[kb.flag] = key end
                    end
                    function kb:Get() return kb.value end

                    kb.Main.MouseButton1Down:Connect(function()
                        kb.Main.Text      = "[...]"
                        kb.Main.TextColor3 = win.theme.accentcolor
                    end)

                    UIS.InputBegan:Connect(function(input, gp)
                        if gp then return end
                        if kb.Main.Text == "[...]" then
                            kb.Main.TextColor3 = Color3.fromRGB(136, 136, 136)
                            kb:Set(input.UserInputType == Enum.UserInputType.Keyboard
                                and input.KeyCode or "None")
                        elseif kb.value ~= "None" and input.KeyCode == kb.value then
                            tog:Set(not tog.value)
                        end
                    end)

                    table.insert(Library.items, kb)
                    return kb
                end

                -- ---- Colorpicker inline on toggle ----
                function tog:AddColorpicker(defaultColor, callback, cpFlag)
                    return sector:_makeColorpicker(tog.Items, defaultColor, callback, cpFlag, true)
                end

                -- ---- Slider attached to toggle ----
                function tog:AddSlider(minVal, defaultVal, maxVal, decimals, callback, slFlag)
                    return sector:AddSlider("", minVal, defaultVal, maxVal, decimals, callback, slFlag)
                end

                -- ---- Dropdown attached to toggle ----
                function tog:AddDropdown(items, default, multichoice, callback, ddFlag)
                    return _buildDropdown({
                        parent     = sector.Items,
                        sector     = sector,
                        text       = nil,
                        items      = items,
                        default    = default,
                        multichoice = multichoice,
                        callback   = callback,
                        flag       = ddFlag or tog.text .. "_dd",
                    })
                end

                -- ---- Textbox attached to toggle ----
                function tog:AddTextbox(default, callback, tbFlag)
                    return sector:_makeTextbox(sector.Items, default, callback, tbFlag)
                end

                sector:FixSize()
                table.insert(Library.items, tog)
                return tog
            end

            -- --------------------------------------------------------
            -- TEXTBOX (sector level)
            -- --------------------------------------------------------
            function sector:_makeTextbox(parent, default, callback, flag)
                local tb = {}
                tb.callback = callback or function() end
                tb.default  = default
                tb.value    = ""
                tb.flag     = flag or ""

                tb.Holder = Instance.new("Frame")
                tb.Holder.ZIndex           = 5
                tb.Holder.Size             = UDim2.fromOffset(sectorW - 12, 14)
                tb.Holder.BorderSizePixel  = 0
                tb.Holder.BackgroundColor3 = Color3.new(1,1,1)
                tb.Holder.Parent           = parent

                local hg = Instance.new("UIGradient")
                hg.Rotation = 90
                hg.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(49,49,49)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(39,39,39)),
                })
                hg.Parent = tb.Holder

                tb.Box = Instance.new("TextBox")
                tb.Box.PlaceholderText       = ""
                tb.Box.Text                  = ""
                tb.Box.BackgroundTransparency = 1
                tb.Box.Font                  = win.theme.font
                tb.Box.MultiLine             = false
                tb.Box.ClearTextOnFocus      = false
                tb.Box.ZIndex                = 5
                tb.Box.TextScaled            = true
                tb.Box.Size                  = tb.Holder.Size
                tb.Box.TextSize              = 15
                tb.Box.TextColor3            = Color3.fromRGB(255,255,255)
                tb.Box.BorderSizePixel       = 0
                tb.Box.TextXAlignment        = Enum.TextXAlignment.Left
                tb.Box.Parent                = tb.Holder
                onTheme(function(t) tb.Box.Font = t.font end)

                local bo2tb = makeOutlines(tb.Box, tb.Box.Size, win.theme, 4)

                if tb.flag ~= "" then Library.flags[tb.flag] = tb.default or "" end

                function tb:Set(text)
                    tb.value    = text
                    tb.Box.Text = text
                    if tb.flag ~= "" then Library.flags[tb.flag] = text end
                    pcall(tb.callback, text)
                end
                function tb:Get() return tb.value end

                if tb.default then tb:Set(tb.default) end
                tb.Box.FocusLost:Connect(function() tb:Set(tb.Box.Text) end)

                bo2tb.MouseEnter:Connect(function() bo2tb.BackgroundColor3 = win.theme.accentcolor end)
                bo2tb.MouseLeave:Connect(function() bo2tb.BackgroundColor3 = win.theme.outlinecolor2 end)

                sector:FixSize()
                table.insert(Library.items, tb)
                return tb
            end

            function sector:AddTextbox(text, default, callback, flag)
                local lbl = Instance.new("TextLabel")
                lbl.BackgroundTransparency = 1
                lbl.Size       = UDim2.fromOffset(sectorW - 12, 0)
                lbl.Font       = win.theme.font
                lbl.Text       = text or ""
                lbl.ZIndex     = 5
                lbl.TextColor3 = win.theme.itemscolor
                lbl.TextSize   = 15
                lbl.TextStrokeTransparency = 1
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent     = sector.Items
                onTheme(function(t) lbl.Font = t.font end)

                return sector:_makeTextbox(sector.Items, default, callback, flag)
            end

            -- --------------------------------------------------------
            -- COLOR PICKER (sector level)
            -- --------------------------------------------------------
            function sector:_makeColorpicker(parent, defaultColor, callback, flag, inline)
                local cp = {}
                cp.callback = callback or function() end
                cp.default  = defaultColor or Color3.fromRGB(255,255,255)
                cp.value    = cp.default
                cp.flag     = flag or ""
                cp.color    = 0   -- current hue

                -- Swatch
                cp.Swatch = Instance.new("Frame")
                cp.Swatch.ZIndex           = 6
                cp.Swatch.BorderSizePixel  = 0
                cp.Swatch.BackgroundColor3 = Color3.new(1,1,1)
                cp.Swatch.Size             = UDim2.fromOffset(16, 10)
                cp.Swatch.Parent           = parent

                local swg = Instance.new("UIGradient")
                swg.Rotation = 90
                swg.Parent   = cp.Swatch

                local sbo2 = Instance.new("Frame")
                sbo2.Name             = "outline"
                sbo2.ZIndex           = 4
                sbo2.Size             = cp.Swatch.Size + UDim2.fromOffset(6,6)
                sbo2.BorderSizePixel  = 0
                sbo2.BackgroundColor3 = win.theme.outlinecolor2
                sbo2.Position         = UDim2.fromOffset(-3,-3)
                sbo2.Parent           = cp.Swatch
                onTheme(function(t)
                    sbo2.BackgroundColor3 = win.OpenedColorPickers[cp.Picker] and t.accentcolor or t.outlinecolor2
                end)

                -- Picker popup
                cp.Picker = Instance.new("TextButton")
                cp.Picker.Name            = "ColorPicker"
                cp.Picker.ZIndex          = 100
                cp.Picker.Visible         = false
                cp.Picker.AutoButtonColor = false
                cp.Picker.Text            = ""
                cp.Picker.Size            = UDim2.fromOffset(180, 196)
                cp.Picker.BorderSizePixel = 0
                cp.Picker.BackgroundColor3 = Color3.fromRGB(40,40,40)
                cp.Picker.Rotation        = 0.000000000000001
                cp.Picker.Position        = UDim2.fromOffset(-180 + 16, 17)
                cp.Picker.Parent          = cp.Swatch
                win.OpenedColorPickers[cp.Picker] = false

                -- Hue selector
                cp.Hue = Instance.new("ImageLabel")
                cp.Hue.ZIndex           = 101
                cp.Hue.Position         = UDim2.new(0, 3, 0, 3)
                cp.Hue.Size             = UDim2.new(0, 172, 0, 172)
                cp.Hue.Image            = "rbxassetid://4155801252"
                cp.Hue.ScaleType        = Enum.ScaleType.Stretch
                cp.Hue.BackgroundColor3 = Color3.new(1, 0, 0)
                cp.Hue.BorderColor3     = win.theme.outlinecolor2
                cp.Hue.Parent           = cp.Picker
                onTheme(function(t) cp.Hue.BorderColor3 = t.outlinecolor2 end)

                cp.HuePointer = Instance.new("ImageLabel")
                cp.HuePointer.ZIndex           = 101
                cp.HuePointer.BackgroundTransparency = 1
                cp.HuePointer.BorderSizePixel  = 0
                cp.HuePointer.Size             = UDim2.fromOffset(7, 7)
                cp.HuePointer.Image            = "rbxassetid://6885856475"
                cp.HuePointer.Parent           = cp.Picker

                -- Hue bar
                cp.Bar = Instance.new("TextLabel")
                cp.Bar.ZIndex           = 100
                cp.Bar.Position         = UDim2.new(0, 3, 0, 181)
                cp.Bar.Size             = UDim2.new(0, 173, 0, 10)
                cp.Bar.BackgroundColor3 = Color3.new(1,1,1)
                cp.Bar.BorderColor3     = win.theme.outlinecolor2
                cp.Bar.Text             = ""
                cp.Bar.Parent           = cp.Picker
                onTheme(function(t) cp.Bar.BorderColor3 = t.outlinecolor2 end)

                local barGrad = Instance.new("UIGradient")
                barGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0,    Color3.new(1,0,0)),
                    ColorSequenceKeypoint.new(0.17, Color3.new(1,0,1)),
                    ColorSequenceKeypoint.new(0.33, Color3.new(0,0,1)),
                    ColorSequenceKeypoint.new(0.50, Color3.new(0,1,1)),
                    ColorSequenceKeypoint.new(0.67, Color3.new(0,1,0)),
                    ColorSequenceKeypoint.new(0.83, Color3.new(1,1,0)),
                    ColorSequenceKeypoint.new(1.00, Color3.new(1,0,0)),
                })
                barGrad.Parent = cp.Bar

                cp.BarPointer = Instance.new("Frame")
                cp.BarPointer.ZIndex           = 101
                cp.BarPointer.BackgroundColor3 = Color3.fromRGB(40,40,40)
                cp.BarPointer.Position         = UDim2.new(0,0,0,0)
                cp.BarPointer.Size             = UDim2.new(0,2,0,10)
                cp.BarPointer.BorderColor3     = Color3.fromRGB(255,255,255)
                cp.BarPointer.Parent           = cp.Bar

                if cp.flag ~= "" then Library.flags[cp.flag] = cp.default end

                function cp:Set(value)
                    local c = Color3.new(
                        math.clamp(value.r, 0, 1),
                        math.clamp(value.g, 0, 1),
                        math.clamp(value.b, 0, 1)
                    )
                    cp.value = c
                    if cp.flag ~= "" then Library.flags[cp.flag] = c end
                    local dark = Color3.new(
                        math.clamp(c.R / 1.7, 0, 1),
                        math.clamp(c.G / 1.7, 0, 1),
                        math.clamp(c.B / 1.7, 0, 1)
                    )
                    swg.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, c),
                        ColorSequenceKeypoint.new(1, dark),
                    })
                    pcall(cp.callback, c)
                end
                function cp:Get() return cp.value end

                local function refreshHue()
                    local mousePos = UIS:GetMouseLocation()
                    local x = (mousePos.X - cp.Hue.AbsolutePosition.X) / cp.Hue.AbsoluteSize.X
                    local y = (mousePos.Y - cp.Hue.AbsolutePosition.Y) / cp.Hue.AbsoluteSize.Y
                    cp.HuePointer:TweenPosition(
                        UDim2.new(
                            math.clamp(x, 0, 0.952), 0,
                            math.clamp(y, 0, 0.885), 0
                        ),
                        Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.05
                    )
                    cp:Set(Color3.fromHSV(
                        cp.color,
                        math.clamp(x, 0, 1),
                        1 - math.clamp(y, 0, 1)
                    ))
                end

                local function refreshBar()
                    local mousePos = UIS:GetMouseLocation()
                    local pos = math.clamp(
                        (mousePos.X - cp.Bar.AbsolutePosition.X) / cp.Bar.AbsoluteSize.X,
                        0, 1
                    )
                    cp.color = 1 - pos
                    cp.BarPointer:TweenPosition(UDim2.new(pos, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.05)
                    cp.Hue.BackgroundColor3 = Color3.fromHSV(cp.color, 1, 1)
                    local hpX = (cp.HuePointer.AbsolutePosition.X - cp.Hue.AbsolutePosition.X) / cp.Hue.AbsoluteSize.X
                    local hpY = (cp.HuePointer.AbsolutePosition.Y - cp.Hue.AbsolutePosition.Y) / cp.Hue.AbsoluteSize.Y
                    cp:Set(Color3.fromHSV(cp.color, math.clamp(hpX,0,1), 1 - math.clamp(hpY,0,1)))
                end

                local dragHue, dragBar = false, false
                cp.Hue.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragHue = true; refreshHue() end
                end)
                cp.Hue.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragHue = false end
                end)
                cp.Bar.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragBar = true; refreshBar() end
                end)
                cp.Bar.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragBar = false end
                end)
                UIS.InputChanged:Connect(function(i)
                    if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                    if dragHue then refreshHue() end
                    if dragBar then refreshBar() end
                end)

                local function togglePicker(input)
                    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                    for picker, open in pairs(win.OpenedColorPickers) do
                        if open and picker ~= cp.Picker then
                            picker.Visible = false
                            win.OpenedColorPickers[picker] = false
                        end
                    end
                    cp.Picker.Visible = not cp.Picker.Visible
                    win.OpenedColorPickers[cp.Picker] = cp.Picker.Visible
                    sbo2.BackgroundColor3 = cp.Picker.Visible and win.theme.accentcolor or win.theme.outlinecolor2
                end
                cp.Swatch.InputBegan:Connect(togglePicker)
                sbo2.InputBegan:Connect(togglePicker)
                sbo2.MouseEnter:Connect(function()
                    if not win.OpenedColorPickers[cp.Picker] then
                        sbo2.BackgroundColor3 = win.theme.accentcolor
                    end
                end)
                sbo2.MouseLeave:Connect(function()
                    if not win.OpenedColorPickers[cp.Picker] then
                        sbo2.BackgroundColor3 = win.theme.outlinecolor2
                    end
                end)

                cp:Set(cp.default)
                sector:FixSize()
                table.insert(Library.items, cp)
                return cp
            end

            function sector:AddColorpicker(text, defaultColor, callback, flag)
                local row = Instance.new("TextLabel")
                row.BackgroundTransparency = 1
                row.Size       = UDim2.fromOffset(156, 10)
                row.ZIndex     = 4
                row.Font       = win.theme.font
                row.Text       = text or ""
                row.TextColor3 = win.theme.itemscolor
                row.TextSize   = 15
                row.TextStrokeTransparency = 1
                row.TextXAlignment = Enum.TextXAlignment.Left
                row.Parent     = sector.Items
                onTheme(function(t)
                    row.Font       = t.font
                    row.TextColor3 = t.itemscolor
                end)

                local cp = sector:_makeColorpicker(row, defaultColor, callback, flag, false)
                cp.Swatch.Position = UDim2.fromOffset(sectorW - 29, 0)
                sector:FixSize()
                return cp
            end

            -- --------------------------------------------------------
            -- KEYBIND (sector level)
            -- --------------------------------------------------------
            function sector:AddKeybind(text, default, onNewKey, onPress, flag)
                local kb = {}
                kb.text       = text or ""
                kb.default    = default or "None"
                kb.callback   = onPress or function() end
                kb.newKeyCallback = onNewKey or function() end
                kb.flag       = flag or text or ""
                kb.value      = kb.default

                kb.Main = Instance.new("TextLabel")
                kb.Main.BackgroundTransparency = 1
                kb.Main.Size       = UDim2.fromOffset(156, 10)
                kb.Main.ZIndex     = 4
                kb.Main.Font       = win.theme.font
                kb.Main.Text       = kb.text
                kb.Main.TextColor3 = win.theme.itemscolor
                kb.Main.TextSize   = 15
                kb.Main.TextStrokeTransparency = 1
                kb.Main.TextXAlignment = Enum.TextXAlignment.Left
                kb.Main.Parent     = sector.Items
                onTheme(function(t)
                    kb.Main.Font       = t.font
                    kb.Main.TextColor3 = t.itemscolor
                end)

                kb.Bind = Instance.new("TextButton")
                kb.Bind.BackgroundTransparency = 1
                kb.Bind.BorderSizePixel  = 0
                kb.Bind.ZIndex           = 5
                kb.Bind.Font             = win.theme.font
                kb.Bind.TextColor3       = Color3.fromRGB(136, 136, 136)
                kb.Bind.TextSize         = 15
                kb.Bind.TextXAlignment   = Enum.TextXAlignment.Right
                kb.Bind.Parent           = kb.Main
                onTheme(function(t)
                    kb.Bind.Font = t.font
                    kb.Bind.TextColor3 = kb.Bind.Text == "[...]"
                        and t.accentcolor or Color3.fromRGB(136,136,136)
                end)

                if kb.flag ~= "" then Library.flags[kb.flag] = kb.default end

                local function updateBindSize()
                    local sz = TextService:GetTextSize(kb.Bind.Text, 15, kb.Bind.Font, Vector2.new(2000,2000))
                    kb.Bind.Size     = UDim2.fromOffset(sz.X, sz.Y)
                    kb.Bind.Position = UDim2.fromOffset(sectorW - 10 - sz.X, 0)
                end

                function kb:Set(value)
                    kb.value = value
                    kb.Bind.Text = "[" .. keyName(value) .. "]"
                    if kb.flag ~= "" then Library.flags[kb.flag] = value end
                    updateBindSize()
                    pcall(kb.newKeyCallback, value)
                end
                function kb:Get() return kb.value end
                kb:Set(kb.default)

                kb.Bind.MouseButton1Down:Connect(function()
                    kb.Bind.Text      = "[...]"
                    kb.Bind.TextColor3 = win.theme.accentcolor
                    updateBindSize()
                end)

                UIS.InputBegan:Connect(function(input, gp)
                    if gp then return end
                    if kb.Bind.Text == "[...]" then
                        kb.Bind.TextColor3 = Color3.fromRGB(136,136,136)
                        kb:Set(input.UserInputType == Enum.UserInputType.Keyboard
                            and input.KeyCode or "None")
                    elseif kb.value ~= "None" and input.KeyCode == kb.value then
                        pcall(kb.callback)
                    end
                end)

                sector:FixSize()
                table.insert(Library.items, kb)
                return kb
            end

            -- --------------------------------------------------------
            -- DROPDOWN (sector level) — uses shared builder
            -- --------------------------------------------------------
            function sector:AddDropdown(text, items, default, multichoice, callback, flag)
                local holder = Instance.new("Frame")
                holder.Name                 = "DDHolder"
                holder.ZIndex               = 7
                holder.Size                 = UDim2.fromOffset(sectorW - 12, 34)
                holder.BorderSizePixel      = 0
                holder.BackgroundTransparency = 1
                holder.Parent               = sector.Items

                return _buildDropdown({
                    parent      = holder,
                    sector      = sector,
                    text        = text,
                    items       = items,
                    default     = default,
                    multichoice = multichoice,
                    callback    = callback,
                    flag        = flag or text or "",
                    yOffset     = 0,
                })
            end

            return sector
        end -- CreateSector

        -- ============================================================
        -- CONFIG SYSTEM (inside CreateTab)
        -- ============================================================
        function tab:CreateConfigSystem(side)
            local cs = {}
            cs.folder = win.name .. "/" .. tostring(game.PlaceId)

            pcall(function()
                if not isfolder(cs.folder) then makefolder(cs.folder) end
            end)

            cs.sector = tab:CreateSector("Configs", side or "left")

            local configNameTB = cs.sector:AddTextbox("Config Name", "", function() end, "")
            
            local existingFiles = {}
            pcall(function()
                for _, f in ipairs(listfiles(cs.folder)) do
                    if f:find(".txt") then
                        table.insert(existingFiles, f:gsub(cs.folder .. "\\", ""):gsub(".txt",""))
                    end
                end
            end)

            local configDD = cs.sector:AddDropdown(
                "Configs", existingFiles,
                existingFiles[1] or nil, false, function() end, ""
            )

            local function refreshList()
                for _, v in ipairs(configDD.items) do configDD:Remove(v) end
                pcall(function()
                    for _, f in ipairs(listfiles(cs.folder)) do
                        if f:find(".txt") then
                            configDD:Add(f:gsub(cs.folder .. "\\", ""):gsub(".txt",""))
                        end
                    end
                end)
            end

            local function serializeFlags()
                local out = {}
                for k, v in pairs(Library.flags) do
                    if v ~= nil and v ~= "" then
                        if typeof(v) == "Color3" then
                            out[k] = { v.R, v.G, v.B }
                        elseif typeof(v) == "EnumItem" and tostring(v):find("KeyCode") then
                            out[k] = "Enum.KeyCode." .. v.Name
                        elseif typeof(v) == "table" then
                            out[k] = { v }
                        else
                            out[k] = v
                        end
                    end
                end
                return HttpService:JSONEncode(out)
            end

            cs.Create = cs.sector:AddButton("Create", function()
                local cname = configNameTB:Get()
                if cname == "" then return end
                pcall(function()
                    writefile(cs.folder .. "/" .. cname .. ".txt", serializeFlags())
                end)
                refreshList()
            end)

            cs.Save = cs.sector:AddButton("Save", function()
                local cname = configDD:Get()
                if not cname or cname == "" then return end
                pcall(function()
                    writefile(cs.folder .. "/" .. cname .. ".txt", serializeFlags())
                end)
            end)

            cs.Load = cs.sector:AddButton("Load", function()
                local cname = configDD:Get()
                if not cname or cname == "" then return end
                pcall(function()
                    local raw  = readfile(cs.folder .. "/" .. cname .. ".txt")
                    local data = HttpService:JSONDecode(raw)
                    local newFlags = {}

                    for k, v in pairs(data) do
                        if typeof(v) == "table" then
                            if typeof(v[1]) == "number" then
                                newFlags[k] = Color3.new(v[1], v[2], v[3])
                            elseif typeof(v[1]) == "table" then
                                newFlags[k] = v[1]
                            end
                        elseif type(v) == "string" and v:find("Enum.KeyCode.") then
                            newFlags[k] = Enum.KeyCode[v:gsub("Enum.KeyCode.", "")]
                        else
                            newFlags[k] = v
                        end
                    end

                    Library.flags = newFlags

                    for flagKey, flagVal in pairs(Library.flags) do
                        for _, item in ipairs(Library.items) do
                            if item.flag and item.flag == flagKey then
                                pcall(item.Set, item, flagVal)
                            end
                        end
                    end
                end)
            end)

            cs.Delete = cs.sector:AddButton("Delete", function()
                local cname = configDD:Get()
                if not cname or cname == "" then return end
                pcall(function()
                    if isfile(cs.folder .. "/" .. cname .. ".txt") then
                        delfile(cs.folder .. "/" .. cname .. ".txt")
                    end
                end)
                refreshList()
            end)

            return cs
        end

        return tab
    end -- CreateTab

    return win
end -- CreateWindow

return Library
