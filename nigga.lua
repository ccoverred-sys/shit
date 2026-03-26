--[[
    NeonUI — Custom Roblox UI Library
    Completely original, built from scratch.
    
    Usage:
        local NeonUI = loadstring(game:HttpGet("YOUR_RAW_LINK"))()
        local Window = NeonUI:CreateWindow("My Hub", Enum.KeyCode.RightShift)
        local Tab = Window:CreateTab("Main", "rbxassetid://...")
        local Section = Tab:CreateSection("Settings")
        Section:AddToggle("God Mode", false, function(v) end)
]]

local NeonUI = {}
NeonUI.__index = NeonUI

-- ============================================================
--  Services
-- ============================================================
local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")
local CoreGui        = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ============================================================
--  Utility
-- ============================================================
local function Tween(obj, props, duration, style, direction)
    style     = style or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    local ti  = TweenInfo.new(duration or 0.25, style, direction)
    TweenService:Create(obj, ti, props):Play()
end

local function Create(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    for _, child in pairs(children or {}) do
        child.Parent = obj
    end
    return obj
end

local function Ripple(button, x, y)
    local ripple = Create("Frame", {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, x - button.AbsolutePosition.X, 0, y - button.AbsolutePosition.Y),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.7,
        ZIndex = button.ZIndex + 5,
        Parent = button,
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ripple})
    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    Tween(ripple, {
        Size = UDim2.new(0, size, 0, size),
        Position = UDim2.new(0, x - button.AbsolutePosition.X - size/2, 0, y - button.AbsolutePosition.Y - size/2),
        BackgroundTransparency = 1,
    }, 0.5)
    task.delay(0.5, function() ripple:Destroy() end)
end

-- ============================================================
--  Theme
-- ============================================================
local Theme = {
    Background    = Color3.fromRGB(13, 13, 20),
    Surface       = Color3.fromRGB(20, 20, 32),
    SurfaceHover  = Color3.fromRGB(28, 28, 44),
    Border        = Color3.fromRGB(45, 45, 70),
    Accent        = Color3.fromRGB(120, 80, 255),
    AccentDark    = Color3.fromRGB(80, 50, 200),
    AccentGlow    = Color3.fromRGB(150, 100, 255),
    Text          = Color3.fromRGB(230, 230, 245),
    TextMuted     = Color3.fromRGB(130, 130, 160),
    TextDim       = Color3.fromRGB(70, 70, 100),
    Success       = Color3.fromRGB(80, 220, 140),
    Danger        = Color3.fromRGB(255, 80, 100),
    Warning       = Color3.fromRGB(255, 180, 60),
    TabBar        = Color3.fromRGB(16, 16, 26),
    ToggleOff     = Color3.fromRGB(40, 40, 60),
    ToggleOn      = Color3.fromRGB(120, 80, 255),
    SliderFill    = Color3.fromRGB(120, 80, 255),
    SliderTrack   = Color3.fromRGB(35, 35, 55),
    SectionBg     = Color3.fromRGB(16, 16, 26),
    SectionBorder = Color3.fromRGB(38, 38, 60),
}

-- ============================================================
--  NeonUI:CreateWindow
-- ============================================================
function NeonUI:CreateWindow(title, keybind)
    keybind = keybind or Enum.KeyCode.RightShift

    -- Root ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "NeonUI_" .. title,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = (pcall(function() return CoreGui end) and CoreGui) or LocalPlayer.PlayerGui,
    })

    -- Main window frame
    local Main = Create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 580, 0, 420),
        Position = UDim2.new(0.5, -290, 0.5, -210),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = ScreenGui,
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Main})

    -- Outer glow border
    local Stroke = Create("UIStroke", {
        Color = Theme.Accent,
        Thickness = 1.2,
        Transparency = 0.5,
        Parent = Main,
    })

    -- Animated gradient glow on border
    task.spawn(function()
        local t = 0
        while Main.Parent do
            t += 0.02
            local r = 120 + math.sin(t) * 40
            local b = 255 + math.sin(t + 2) * 0
            Stroke.Color = Color3.fromRGB(r, 80, 255)
            task.wait(0.03)
        end
    end)

    -- Top bar
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Parent = Main,
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = TopBar})
    -- Fix bottom corners of topbar
    Create("Frame", {
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Parent = TopBar,
    })

    -- Accent line under topbar
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Parent = TopBar,
    })

    -- Logo dot
    local LogoDot = Create("Frame", {
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new(0, 14, 0.5, -5),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = TopBar,
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = LogoDot})

    -- Pulse the logo dot
    task.spawn(function()
        while Main.Parent do
            Tween(LogoDot, {BackgroundColor3 = Theme.AccentGlow}, 0.8)
            task.wait(0.8)
            Tween(LogoDot, {BackgroundColor3 = Theme.AccentDark}, 0.8)
            task.wait(0.8)
        end
    end)

    -- Title
    Create("TextLabel", {
        Text = title,
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 30, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar,
    })

    -- Keybind label
    local KeyLabel = Create("TextLabel", {
        Text = "[" .. keybind.Name .. "]",
        Size = UDim2.new(0, 80, 1, 0),
        Position = UDim2.new(1, -90, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = TopBar,
    })

    -- Dragging
    local dragging, dragStart, startPos = false, nil, nil
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Toggle visibility with keybind
    local visible = true
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == keybind then
            visible = not visible
            if visible then
                Main.Visible = true
                Tween(Main, {Size = UDim2.new(0, 580, 0, 420)}, 0.3, Enum.EasingStyle.Back)
            else
                Tween(Main, {Size = UDim2.new(0, 580, 0, 0)}, 0.2)
                task.delay(0.22, function() Main.Visible = false end)
            end
        end
    end)

    -- Tab bar (left side)
    local TabBar = Create("Frame", {
        Name = "TabBar",
        Size = UDim2.new(0, 120, 1, -44),
        Position = UDim2.new(0, 0, 0, 44),
        BackgroundColor3 = Theme.TabBar,
        BorderSizePixel = 0,
        Parent = Main,
    })
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = TabBar,
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        Parent = TabBar,
    })

    -- Accent line on right side of tab bar
    Create("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Parent = TabBar,
    })

    -- Content area
    local ContentArea = Create("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -120, 1, -44),
        Position = UDim2.new(0, 120, 0, 44),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = Main,
    })

    -- Window object
    local WindowObj = {
        _gui = ScreenGui,
        _main = Main,
        _tabBar = TabBar,
        _contentArea = ContentArea,
        _tabs = {},
        _activeTab = nil,
    }

    -- --------------------------------------------------------
    --  WindowObj:CreateTab
    -- --------------------------------------------------------
    function WindowObj:CreateTab(name, icon)
        -- Tab button
        local TabBtn = Create("TextButton", {
            Name = name,
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Theme.Surface,
            BackgroundTransparency = 1,
            Text = "",
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Parent = self._tabBar,
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = TabBtn})

        -- Tab indicator bar
        local TabIndicator = Create("Frame", {
            Size = UDim2.new(0, 3, 0, 18),
            Position = UDim2.new(0, -3, 0.5, -9),
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = TabBtn,
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = TabIndicator})

        -- Tab label
        local TabLabel = Create("TextLabel", {
            Text = name,
            Size = UDim2.new(1, -10, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            TextColor3 = Theme.TextMuted,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabBtn,
        })

        -- Tab page (scrollable)
        local TabPage = Create("ScrollingFrame", {
            Name = name .. "_Page",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = self._contentArea,
        })
        Create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            Parent = TabPage,
        })
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = TabPage,
        })

        local TabObj = {
            _btn = TabBtn,
            _page = TabPage,
            _indicator = TabIndicator,
            _label = TabLabel,
            _windowObj = self,
        }

        -- Select tab
        local function SelectTab()
            -- Deactivate all
            for _, t in pairs(self._tabs) do
                t._page.Visible = false
                Tween(t._btn, {BackgroundTransparency = 1}, 0.2)
                Tween(t._indicator, {BackgroundTransparency = 1}, 0.2)
                Tween(t._label, {TextColor3 = Theme.TextMuted}, 0.2)
            end
            -- Activate this one
            TabPage.Visible = true
            Tween(TabBtn, {BackgroundTransparency = 0.85}, 0.2)
            Tween(TabIndicator, {BackgroundTransparency = 0}, 0.2)
            Tween(TabLabel, {TextColor3 = Theme.Text}, 0.2)
            self._activeTab = TabObj
        end

        TabBtn.MouseEnter:Connect(function()
            if self._activeTab ~= TabObj then
                Tween(TabBtn, {BackgroundTransparency = 0.9}, 0.15)
                Tween(TabLabel, {TextColor3 = Color3.fromRGB(180, 180, 210)}, 0.15)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if self._activeTab ~= TabObj then
                Tween(TabBtn, {BackgroundTransparency = 1}, 0.15)
                Tween(TabLabel, {TextColor3 = Theme.TextMuted}, 0.15)
            end
        end)
        TabBtn.MouseButton1Click:Connect(function()
            SelectTab()
        end)

        table.insert(self._tabs, TabObj)
        if #self._tabs == 1 then SelectTab() end

        -- --------------------------------------------------------
        --  TabObj:CreateSection
        -- --------------------------------------------------------
        function TabObj:CreateSection(title)
            local Section = Create("Frame", {
                Name = title,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.SectionBg,
                BorderSizePixel = 0,
                Parent = self._page,
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Section})
            Create("UIStroke", {Color = Theme.SectionBorder, Thickness = 1, Parent = Section})
            Create("UIPadding", {
                PaddingTop = UDim.new(0, 36),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10),
                Parent = Section,
            })

            local SectionList = Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6),
                Parent = Section,
            })

            -- Section header
            local SectionHeader = Create("Frame", {
                Name = "Header",
                Size = UDim2.new(1, 0, 0, 30),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 2,
                Parent = Section,
            })
            -- Accent line
            Create("Frame", {
                Size = UDim2.new(0, 3, 0, 14),
                Position = UDim2.new(0, 10, 0.5, -7),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                Parent = SectionHeader,
            }):FindFirstChildOfClass("UICorner") or Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = SectionHeader:FindFirstChild("Frame") or SectionHeader})
            local accentLine = SectionHeader:FindFirstChildWhichIsA("Frame")
            if accentLine then Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = accentLine}) end

            Create("TextLabel", {
                Text = title:upper(),
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 20, 0, 0),
                BackgroundTransparency = 1,
                TextColor3 = Theme.TextMuted,
                Font = Enum.Font.GothamBold,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                LetterSpacing = 2,
                Parent = SectionHeader,
            })

            local SectionObj = { _section = Section }

            -- Helper: row frame
            local function MakeRow(height)
                height = height or 32
                return Create("Frame", {
                    Size = UDim2.new(1, 0, 0, height),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = Section,
                })
            end

            -- ------------------------------------------------
            --  Toggle
            -- ------------------------------------------------
            function SectionObj:AddToggle(label, default, callback)
                local state = default or false
                local Row = MakeRow(32)

                Create("TextLabel", {
                    Text = label,
                    Size = UDim2.new(1, -56, 1, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Row,
                })

                local Track = Create("Frame", {
                    Size = UDim2.new(0, 40, 0, 20),
                    Position = UDim2.new(1, -44, 0.5, -10),
                    BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff,
                    BorderSizePixel = 0,
                    Parent = Row,
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Track})

                local Knob = Create("Frame", {
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Parent = Track,
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Knob})

                local Btn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = Row,
                })

                local ToggleObj = {}

                local function SetState(s)
                    state = s
                    Tween(Track, {BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff}, 0.2)
                    Tween(Knob, {
                        Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
                    }, 0.2, Enum.EasingStyle.Quart)
                    if callback then callback(state) end
                end

                Btn.MouseButton1Click:Connect(function()
                    SetState(not state)
                end)

                function ToggleObj:Set(v) SetState(v) end
                function ToggleObj:Get() return state end
                return ToggleObj
            end

            -- ------------------------------------------------
            --  Button
            -- ------------------------------------------------
            function SectionObj:AddButton(label, callback)
                local Row = MakeRow(34)

                local Btn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Theme.Surface,
                    BorderSizePixel = 0,
                    Text = label,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 13,
                    AutoButtonColor = false,
                    ClipsDescendants = true,
                    Parent = Row,
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Btn})
                Create("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = Btn})

                Btn.MouseEnter:Connect(function()
                    Tween(Btn, {BackgroundColor3 = Theme.SurfaceHover}, 0.15)
                end)
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, {BackgroundColor3 = Theme.Surface}, 0.15)
                end)
                Btn.MouseButton1Click:Connect(function(x, y)
                    Ripple(Btn, x, y)
                    if callback then callback() end
                end)
            end

            -- ------------------------------------------------
            --  Slider
            -- ------------------------------------------------
            function SectionObj:AddSlider(label, min, max, default, increment, callback)
                local value = math.clamp(default or min, min, max)
                increment = increment or 1
                local Row = MakeRow(48)

                local Header = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Parent = Row,
                })
                Create("TextLabel", {
                    Text = label,
                    Size = UDim2.new(1, -50, 1, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Header,
                })
                local ValLabel = Create("TextLabel", {
                    Text = tostring(value),
                    Size = UDim2.new(0, 46, 1, 0),
                    Position = UDim2.new(1, -46, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Theme.Accent,
                    Font = Enum.Font.GothamBold,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = Header,
                })

                local Track = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 5),
                    Position = UDim2.new(0, 0, 1, -8),
                    BackgroundColor3 = Theme.SliderTrack,
                    BorderSizePixel = 0,
                    Parent = Row,
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Track})

                local Fill = Create("Frame", {
                    Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = Theme.SliderFill,
                    BorderSizePixel = 0,
                    Parent = Track,
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Fill})

                local Knob = Create("Frame", {
                    Size = UDim2.new(0, 13, 0, 13),
                    Position = UDim2.new((value - min) / (max - min), -6, 0.5, -6),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Parent = Track,
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Knob})

                local draggingSlider = false
                local function Update(inputX)
                    local rel = math.clamp((inputX - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    local raw = min + (max - min) * rel
                    local snapped = math.round(raw / increment) * increment
                    snapped = math.clamp(snapped, min, max)
                    value = snapped
                    local pct = (value - min) / (max - min)
                    Fill.Size = UDim2.new(pct, 0, 1, 0)
                    Knob.Position = UDim2.new(pct, -6, 0.5, -6)
                    ValLabel.Text = tostring(value)
                    if callback then callback(value) end
                end

                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = true
                        Update(input.Position.X)
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                        Update(input.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = false
                    end
                end)

                local SliderObj = {}
                function SliderObj:Set(v)
                    value = math.clamp(v, min, max)
                    local pct = (value - min) / (max - min)
                    Fill.Size = UDim2.new(pct, 0, 1, 0)
                    Knob.Position = UDim2.new(pct, -6, 0.5, -6)
                    ValLabel.Text = tostring(value)
                    if callback then callback(value) end
                end
                function SliderObj:Get() return value end
                return SliderObj
            end

            -- ------------------------------------------------
            --  Dropdown
            -- ------------------------------------------------
            function SectionObj:AddDropdown(label, options, default, callback)
                local selected = default or options[1]
                local open = false
                local Row = MakeRow(32)

                Create("TextLabel", {
                    Text = label,
                    Size = UDim2.new(0.45, 0, 1, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Row,
                })

                local DropBtn = Create("TextButton", {
                    Size = UDim2.new(0.52, 0, 0, 26),
                    Position = UDim2.new(0.48, 0, 0.5, -13),
                    BackgroundColor3 = Theme.Surface,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = Row,
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = DropBtn})
                Create("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = DropBtn})

                local SelLabel = Create("TextLabel", {
                    Text = selected,
                    Size = UDim2.new(1, -24, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DropBtn,
                })

                -- Arrow icon
                local Arrow = Create("TextLabel", {
                    Text = "▾",
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -22, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Theme.TextMuted,
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    Parent = DropBtn,
                })

                -- Dropdown list
                local List = Create("Frame", {
                    Size = UDim2.new(0.52, 0, 0, 0),
                    Position = UDim2.new(0.48, 0, 1, 4),
                    BackgroundColor3 = Theme.Surface,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    ZIndex = 10,
                    Visible = false,
                    Parent = Row,
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = List})
                Create("UIStroke", {Color = Theme.Border, Thickness = 1, ZIndex = 11, Parent = List})
                Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = List})

                local itemHeight = 26
                for _, opt in ipairs(options) do
                    local Item = Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, itemHeight),
                        BackgroundTransparency = 1,
                        Text = opt,
                        TextColor3 = opt == selected and Theme.Accent or Theme.TextMuted,
                        Font = Enum.Font.Gotham,
                        TextSize = 12,
                        ZIndex = 12,
                        AutoButtonColor = false,
                        Parent = List,
                    })
                    Item.MouseEnter:Connect(function()
                        Tween(Item, {BackgroundTransparency = 0.85, TextColor3 = Theme.Text}, 0.1)
                        Item.BackgroundColor3 = Theme.SurfaceHover
                    end)
                    Item.MouseLeave:Connect(function()
                        Tween(Item, {BackgroundTransparency = 1, TextColor3 = opt == selected and Theme.Accent or Theme.TextMuted}, 0.1)
                    end)
                    Item.MouseButton1Click:Connect(function()
                        selected = opt
                        SelLabel.Text = opt
                        -- Reset all colours
                        for _, c in ipairs(List:GetChildren()) do
                            if c:IsA("TextButton") then
                                c.TextColor3 = Theme.TextMuted
                            end
                        end
                        Item.TextColor3 = Theme.Accent
                        open = false
                        Tween(List, {Size = UDim2.new(0.52, 0, 0, 0)}, 0.2)
                        Tween(Arrow, {Rotation = 0}, 0.2)
                        task.delay(0.22, function() List.Visible = false end)
                        if callback then callback(selected) end
                    end)
                end

                DropBtn.MouseButton1Click:Connect(function()
                    open = not open
                    List.Visible = true
                    local targetH = open and (#options * itemHeight) or 0
                    Tween(List, {Size = UDim2.new(0.52, 0, 0, targetH)}, 0.2, Enum.EasingStyle.Quart)
                    Tween(Arrow, {Rotation = open and 180 or 0}, 0.2)
                    if not open then task.delay(0.22, function() List.Visible = false end) end
                end)

                local DropObj = {}
                function DropObj:Set(v) SelLabel.Text = v; selected = v end
                function DropObj:Get() return selected end
                return DropObj
            end

            -- ------------------------------------------------
            --  Textbox
            -- ------------------------------------------------
            function SectionObj:AddTextbox(label, placeholder, callback)
                local Row = MakeRow(32)

                Create("TextLabel", {
                    Text = label,
                    Size = UDim2.new(0.4, 0, 1, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Row,
                })

                local Box = Create("TextBox", {
                    Size = UDim2.new(0.57, 0, 0, 26),
                    Position = UDim2.new(0.43, 0, 0.5, -13),
                    BackgroundColor3 = Theme.Surface,
                    BorderSizePixel = 0,
                    Text = "",
                    PlaceholderText = placeholder or "...",
                    TextColor3 = Theme.Text,
                    PlaceholderColor3 = Theme.TextDim,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    ClearTextOnFocus = false,
                    Parent = Row,
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = Box})
                local BoxStroke = Create("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = Box})
                Create("UIPadding", {PaddingLeft = UDim.new(0, 8), Parent = Box})

                Box.Focused:Connect(function()
                    Tween(BoxStroke, {Color = Theme.Accent}, 0.2)
                end)
                Box.FocusLost:Connect(function(enter)
                    Tween(BoxStroke, {Color = Theme.Border}, 0.2)
                    if callback then callback(Box.Text, enter) end
                end)
            end

            -- ------------------------------------------------
            --  Label
            -- ------------------------------------------------
            function SectionObj:AddLabel(text)
                local Row = MakeRow(24)
                Create("TextLabel", {
                    Text = text,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Theme.TextMuted,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Row,
                })
                local LabelObj = {}
                function LabelObj:Set(t)
                    Row:FindFirstChildWhichIsA("TextLabel").Text = t
                end
                return LabelObj
            end

            -- ------------------------------------------------
            --  Separator
            -- ------------------------------------------------
            function SectionObj:AddSeparator()
                local Row = MakeRow(12)
                Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    BackgroundColor3 = Theme.Border,
                    BorderSizePixel = 0,
                    Parent = Row,
                })
            end

            return SectionObj
        end

        return TabObj
    end

    -- --------------------------------------------------------
    --  WindowObj:Notify  (toast notification)
    -- --------------------------------------------------------
    function WindowObj:Notify(title, message, duration, notifType)
        duration = duration or 3
        notifType = notifType or "info"
        local color = notifType == "success" and Theme.Success
                   or notifType == "error"   and Theme.Danger
                   or notifType == "warning" and Theme.Warning
                   or Theme.Accent

        local NotifFrame = Create("Frame", {
            Size = UDim2.new(0, 260, 0, 0),
            Position = UDim2.new(1, -270, 1, -10),
            BackgroundColor3 = Theme.Surface,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            ZIndex = 100,
            Parent = ScreenGui,
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = NotifFrame})
        Create("UIStroke", {Color = color, Thickness = 1, Transparency = 0.5, ZIndex = 101, Parent = NotifFrame})

        -- Accent left bar
        local Bar = Create("Frame", {
            Size = UDim2.new(0, 3, 1, 0),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            ZIndex = 101,
            Parent = NotifFrame,
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = Bar})

        Create("TextLabel", {
            Text = title,
            Size = UDim2.new(1, -16, 0, 20),
            Position = UDim2.new(0, 12, 0, 8),
            BackgroundTransparency = 1,
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 102,
            Parent = NotifFrame,
        })
        Create("TextLabel", {
            Text = message,
            Size = UDim2.new(1, -16, 0, 30),
            Position = UDim2.new(0, 12, 0, 28),
            BackgroundTransparency = 1,
            TextColor3 = Theme.TextMuted,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            ZIndex = 102,
            Parent = NotifFrame,
        })

        -- Progress bar
        local Progress = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            ZIndex = 103,
            Parent = NotifFrame,
        })

        -- Slide in
        Tween(NotifFrame, {Size = UDim2.new(0, 260, 0, 66)}, 0.3, Enum.EasingStyle.Back)
        -- Progress drain
        task.delay(0.3, function()
            Tween(Progress, {Size = UDim2.new(0, 0, 0, 2)}, duration, Enum.EasingStyle.Linear)
        end)
        -- Slide out
        task.delay(duration + 0.3, function()
            Tween(NotifFrame, {Size = UDim2.new(0, 260, 0, 0), Position = UDim2.new(1, -270, 1, -10)}, 0.25)
            task.delay(0.3, function() NotifFrame:Destroy() end)
        end)
    end

    -- --------------------------------------------------------
    --  WindowObj:Destroy
    -- --------------------------------------------------------
    function WindowObj:Destroy()
        ScreenGui:Destroy()
    end

    -- Entrance animation
    Main.Size = UDim2.new(0, 580, 0, 0)
    Tween(Main, {Size = UDim2.new(0, 580, 0, 420)}, 0.4, Enum.EasingStyle.Back)

    return WindowObj
end

return NeonUI
