while not game:IsLoaded() do
    task.wait()
end

local function LoadScript()
    local rs = cloneref(game:GetService("ReplicatedStorage"))
    local players = cloneref(game:GetService("Players"))
    local workspace = cloneref(game:GetService("Workspace"))
    local runservice = cloneref(game:GetService("RunService"))
    local uis = game:GetService("UserInputService")
    local tweenService = game:GetService("TweenService")
    local coreGui = game:GetService("CoreGui")
    local lplr = players.LocalPlayer
    local gun = require(lplr.PlayerScripts.Modules.ItemTypes.Gun)
    local util = require(rs.Modules.Utility)
    local enums = require(rs.Modules.EnumLibrary)
    local fighter = require(lplr.PlayerScripts.Controllers.FighterController)
    local ray_params = RaycastParams.new()
    local vec = Vector3.new

    local offsets = {
        vec(0, 12, 0),
        vec(0, 16, 0),
        vec(0, 20, 0),
        vec(0, 24, 0),
        vec(0, 28, 0),
        vec(0, 32, 0),
        vec(0, 36, 0),
        vec(0, 40, 0)
    }

    local autoWinEnabled = false
    local autoQueueEnabled = false
    local targetSlot = 3
    local uiVisible = false
    local TeleportCheck = false

    local function saveSettings()
        local HttpService = game:GetService("HttpService")
        local data = {
            autoWinEnabled = autoWinEnabled,
            autoQueueEnabled = autoQueueEnabled
        }
        local json = HttpService:JSONEncode(data)
        writefile("Arctic.json", json)
    end

    local function loadSettings()
        if isfile("Arctic.json") then
            local HttpService = game:GetService("HttpService")
            local json = readfile("Arctic.json")
            local data = HttpService:JSONDecode(json)
            if data.autoWinEnabled ~= nil then
                autoWinEnabled = data.autoWinEnabled
            end
            if data.autoQueueEnabled ~= nil then
                autoQueueEnabled = data.autoQueueEnabled
            end
        end
    end

    lplr.OnTeleport:Connect(function(State)
        if not TeleportCheck and queue_on_teleport then
            TeleportCheck = true
            queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/Tio30533/Arctic/refs/heads/main/Main.lua'))()")
        end
    end)

    local manipulation = {}
    do
        manipulation.get_closest = function()
            if not lplr.Character or not lplr.Character:FindFirstChild("HumanoidRootPart") then
                return nil, nil
            end

            local target, char, dist = nil, nil, math.huge
            for i, v in next, players:GetPlayers() do
                if v ~= lplr and v.Character and v.Character:FindFirstChild("Head") then
                    local mag = (lplr.Character.HumanoidRootPart.Position - v.Character.Head.Position).Magnitude
                    if mag < dist then
                        dist = mag
                        target = v.Character.Head
                        char = v.Character
                    end
                end
            end
            return target, char
        end

        manipulation.calculate_point = function(origin, target_pos, target_char)
            ray_params.FilterDescendantsInstances = {lplr.Character, target_char}
            ray_params.FilterType = Enum.RaycastFilterType.Exclude

            if not workspace:Raycast(origin, target_pos - origin, ray_params) then
                return origin, nil
            end

            for i, offset in next, offsets do
                local scan_pos = origin + offset
                if not workspace:Raycast(scan_pos, target_pos - scan_pos, ray_params) then
                    return scan_pos, offset.Y
                end
            end

            return nil, nil
        end
    end

    local function quickFist()
        if not fighter or not fighter.LocalFighter then return end
        if not fighter.LocalFighter:IsAlive() then return end
        pcall(function()
            fighter.LocalFighter:EquipItem(targetSlot)
        end)
    end

    local function makeLayDown(character)
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = true
            task.wait(0.1)
            humanoid.PlatformStand = false
            humanoid.Sit = true
        end
    end

    local function teleportUnderPlayer()
        if not lplr.Character or not lplr.Character:FindFirstChild("HumanoidRootPart") then
            return false
        end
        
        local target_part, target_char = manipulation.get_closest()
        if not target_part or not target_char then
            return false
        end
        
        local targetRoot = target_char:FindFirstChild("HumanoidRootPart")
        if not targetRoot then
            return false
        end
        
        local underPosition = targetRoot.Position - Vector3.new(0, 5, 0)
        local lookAt = CFrame.lookAt(underPosition, targetRoot.Position)
        
        lplr.Character.HumanoidRootPart.CFrame = lookAt
        
        makeLayDown(lplr.Character)
        
        return true
    end

    local function joinQueue()
        local Event = rs.Remotes.Matchmaking.JoinQueue
        Event:InvokeServer("1v1")
    end

    local teleportConnection
    local function startTeleportLoop()
        if teleportConnection then
            teleportConnection:Disconnect()
        end
        
        teleportConnection = runservice.Heartbeat:Connect(function()
            if autoWinEnabled then
                teleportUnderPlayer()
                quickFist()
            end
        end)
    end

    local queueConnection
    local function startQueueLoop()
        if queueConnection then
            queueConnection:Disconnect()
        end
        
        queueConnection = runservice.Heartbeat:Connect(function()
            if autoQueueEnabled then
                joinQueue()
            end
        end)
    end

    loadSettings()

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Arctic"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = coreGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 170, 0, 62)
    mainFrame.Position = UDim2.new(0.5, -85, 0, -70)
    mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    mainFrame.BackgroundTransparency = 1
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = false
    mainFrame.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 6)
    mainCorner.Parent = mainFrame

    local border = Instance.new("UIStroke")
    border.Thickness = 0.5
    border.Color = Color3.fromRGB(60, 60, 60)
    border.Transparency = 1
    border.Parent = mainFrame

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 3, 1, 0)
    accent.BackgroundColor3 = Color3.fromRGB(145, 120, 255)
    accent.BorderSizePixel = 0
    accent.Parent = mainFrame

    local accentGradient = Instance.new("UIGradient")
    accentGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(145, 120, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 155, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(145, 120, 255))
    })
    accentGradient.Parent = accent

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -30, 0, 18)
    titleLabel.Position = UDim2.new(0, 12, 0, 4)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "arctic"
    titleLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
    titleLabel.TextSize = 12
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTransparency = 1
    titleLabel.Parent = mainFrame

    local function createToggle(name, yPos, state, callback)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 100, 0, 16)
        label.Position = UDim2.new(0, 14, 0, yPos)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(140, 140, 140)
        label.TextSize = 11
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextTransparency = 1
        label.Parent = mainFrame

        local toggleHitbox = Instance.new("TextButton")
        toggleHitbox.Size = UDim2.new(0, 32, 0, 14)
        toggleHitbox.Position = UDim2.new(1, -42, 0, yPos + 1)
        toggleHitbox.BackgroundTransparency = 1
        toggleHitbox.Text = ""
        toggleHitbox.TextTransparency = 1
        toggleHitbox.Parent = mainFrame

        local toggleBg = Instance.new("Frame")
        toggleBg.Size = UDim2.new(1, 0, 1, 0)
        toggleBg.BackgroundColor3 = state and Color3.fromRGB(145, 120, 255) or Color3.fromRGB(40, 40, 40)
        toggleBg.BackgroundTransparency = 1
        toggleBg.BorderSizePixel = 0
        toggleBg.Parent = toggleHitbox

        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = UDim.new(1, 0)
        bgCorner.Parent = toggleBg

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 10, 0, 10)
        dot.Position = state and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
        dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dot.BackgroundTransparency = 1
        dot.BorderSizePixel = 0
        dot.Parent = toggleBg

        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot

        local glow = Instance.new("Frame")
        glow.Size = UDim2.new(0, 20, 0, 20)
        glow.Position = UDim2.new(0.5, -10, 0.5, -10)
        glow.BackgroundColor3 = Color3.fromRGB(145, 120, 255)
        glow.BackgroundTransparency = 1
        glow.BorderSizePixel = 0
        glow.ZIndex = 0
        glow.Parent = toggleBg

        local glowCorner = Instance.new("UICorner")
        glowCorner.CornerRadius = UDim.new(1, 0)
        glowCorner.Parent = glow

        local toggled = state
        
        local function updateVisual(instant)
            local tweenInfo = instant and TweenInfo.new(0, Enum.EasingStyle.Linear) or TweenInfo.new(0.15, Enum.EasingStyle.Quad)
            
            local bgTween = tweenService:Create(toggleBg, tweenInfo, {
                BackgroundColor3 = toggled and Color3.fromRGB(145, 120, 255) or Color3.fromRGB(40, 40, 40)
            })
            bgTween:Play()
            
            local dotTween = tweenService:Create(dot, tweenInfo, {
                Position = toggled and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
            })
            dotTween:Play()

            local glowTween = tweenService:Create(glow, tweenInfo, {
                BackgroundTransparency = toggled and 0.85 or 1
            })
            glowTween:Play()
        end

        toggleHitbox.MouseButton1Click:Connect(function()
            toggled = not toggled
            updateVisual()
            callback(toggled)
        end)

        return {
            setState = function(newState)
                toggled = newState
                updateVisual(true)
            end
        }
    end

    local autoWinToggle = createToggle("Auto Win", 24, autoWinEnabled, function(state)
        autoWinEnabled = state
        saveSettings()
    end)

    local autoQueueToggle = createToggle("Auto Queue", 42, autoQueueEnabled, function(state)
        autoQueueEnabled = state
        saveSettings()
    end)

    local function setUIVisibility(visible)
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
        
        local targetBgTransparency = visible and 0.1 or 1
        local targetPosition = visible and UDim2.new(0.5, -85, 0, 16) or UDim2.new(0.5, -85, 0, -70)
        local targetTextTransparency = visible and 0 or 1
        local targetStrokeTransparency = visible and 0.5 or 1
        local targetToggleTransparency = visible and 0 or 1
        
        local frameTween = tweenService:Create(mainFrame, tweenInfo, {
            BackgroundTransparency = targetBgTransparency,
            Position = targetPosition
        })
        frameTween:Play()
        
        local strokeTween = tweenService:Create(border, tweenInfo, {
            Transparency = targetStrokeTransparency
        })
        strokeTween:Play()
        
        for _, child in ipairs(mainFrame:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                local textTween = tweenService:Create(child, tweenInfo, {
                    TextTransparency = targetTextTransparency
                })
                textTween:Play()
            elseif child:IsA("Frame") and child ~= accent and child.Parent ~= accent then
                if child.Name ~= "MainFrame" then
                    local childTween = tweenService:Create(child, tweenInfo, {
                        BackgroundTransparency = targetToggleTransparency
                    })
                    childTween:Play()
                end
            end
        end
    end

    uis.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            uiVisible = not uiVisible
            setUIVisibility(uiVisible)
        end
    end)

    local dragging = false
    local dragStart = Vector2.new()
    local startPos = Vector2.new()

    titleLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    uis.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    runservice.Heartbeat:Connect(function()
        if not autoWinEnabled then return end
        if not lplr.Character then return end

        local root = lplr.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end

        if not fighter or not fighter.LocalFighter then return end

        local item = fighter.LocalFighter.EquippedItem
        if not item then return end

        local target_part, target_char = manipulation.get_closest()
        if not target_part or not target_char then return end

        local cam = workspace.CurrentCamera.CFrame
        local manip, height = manipulation.calculate_point(cam.Position, target_part.Position, target_char)

        if not manip then return end

        local shoot_pos = (height == nil and manip) or cam.Position

        local cameradata = {}
        cameradata[utf8.char(1)] = {
            [utf8.char(0)] = util:EncodeCFrame(CFrame.new(shoot_pos.X, shoot_pos.Y + (height or 0), shoot_pos.Z) * CFrame.Angles(CFrame.lookAt(shoot_pos, target_part.Position):ToOrientation())),
            [utf8.char(1)] = height and util:EncodeCFrame(CFrame.new(target_part.Position) * CFrame.Angles(CFrame.lookAt(shoot_pos, target_part.Position):ToOrientation())) or util:EncodeCFrame(CFrame.new(shoot_pos.X, shoot_pos.Y + (height or 0), shoot_pos.Z) * CFrame.Angles(CFrame.lookAt(shoot_pos, target_part.Position):ToOrientation())),
            [utf8.char(2)] = target_part,
            [utf8.char(3)] = util:EncodeCFrame(target_part.CFrame:ToObjectSpace(CFrame.new(target_part.Position)))
        }

        rs.Remotes.Replication.Fighter.UseItem:FireServer(item:Get("ObjectID"), enums:ToEnum("StartShooting"), cameradata, nil)
    end)

    startTeleportLoop()
    startQueueLoop()
end

LoadScript()
