local TweenService = game:GetService("TweenService")

local Notifications = {}
Notifications.__index = Notifications

function Notifications.new()
    local self = setmetatable({}, Notifications)
    self.notifications = {}
    
    local player = game.Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    local characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+[]{}|;:,.<>?/~`"
    local screenGuiName = ""
    for i = 1, math.random(30, 60) do
        screenGuiName = screenGuiName .. string.sub(characters, math.random(#characters), math.random(#characters))
    end
    
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = screenGuiName
    self.screenGui.Parent = playerGui
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.screenGui.Enabled = true
    
    return self
end

function Notifications:updatePositions()
    for i, notif in ipairs(self.notifications) do
        local yOffset = 60 + ((#self.notifications - i) * 50)
        notif.Frame.Position = UDim2.new(0.5, 0, 1, -yOffset)
    end
end

function Notifications:Notify(text)
    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 0, 0, 40)
    notifFrame.Position = UDim2.new(0.5, 0, 1, 60)
    notifFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    notifFrame.BorderSizePixel = 0
    notifFrame.BackgroundTransparency = 0
    notifFrame.AnchorPoint = Vector2.new(0.5, 0)
    notifFrame.ClipsDescendants = true
    notifFrame.Parent = self.screenGui

    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 8)
    notifCorner.Parent = notifFrame

    local notifStroke = Instance.new("UIStroke")
    notifStroke.Color = Color3.fromRGB(255, 255, 255)
    notifStroke.Thickness = 1
    notifStroke.Transparency = 0
    notifStroke.Parent = notifFrame

    local notifText = Instance.new("TextLabel")
    notifText.Size = UDim2.new(0, 230, 1, 0)
    notifText.Position = UDim2.new(0, 10, 0, 0)
    notifText.BackgroundTransparency = 1
    notifText.Text = text
    notifText.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifText.TextSize = 14
    notifText.Font = Enum.Font.GothamBold
    notifText.TextXAlignment = Enum.TextXAlignment.Left
    notifText.TextTransparency = 0
    notifText.Parent = notifFrame

    local notifTextStroke = Instance.new("UIStroke")
    notifTextStroke.Color = Color3.fromRGB(0, 0, 0)
    notifTextStroke.Thickness = 1.5
    notifTextStroke.Transparency = 0
    notifTextStroke.Parent = notifText

    table.insert(self.notifications, {
        Frame = notifFrame,
        Stroke = notifStroke,
        Text = notifText,
        TextStroke = notifTextStroke
    })

    local expandIn = TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 250, 0, 40)})
    expandIn:Play()

    self:updatePositions()

    task.delay(3, function()
        local expandOut = TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 40)})

        expandOut:Play()

        expandOut.Completed:Connect(function()
            for i, notif in ipairs(self.notifications) do
                if notif.Frame == notifFrame then
                    notif.Frame:Destroy()
                    table.remove(self.notifications, i)
                    self:updatePositions()
                    break
                end
            end
        end)
    end)
end

return Notifications.new()
