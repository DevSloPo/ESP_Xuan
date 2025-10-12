local cloneref = cloneref or function(a) return a end
local Players = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local RunService = cloneref(game:GetService("RunService"))

local LP = Players.LocalPlayer
local Character = LP.Character or LP.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

local Library = {
    ESP = {},
    Tags = {},
    Connections = {},
    ESPFolder = Instance.new("Folder", CoreGui),
    TagSettings = {},
    DefaultSettings = {
        Name = "Unnamed",
        Color = Color3.new(1, 1, 1),
        TextSize = 17,
        Tag = "DefaultTag",
        ShowTextLabel = true,
        ShowHighlight = true,
        ShowDistance = true,
        MaxDistance = math.huge,
        ShowTracer = true,
        TracerPosition = "Bottom",
        TracerThickness = 1,
        TracerTransparency = 1,
        TargetName = nil,
        CheckForHumanoid = false,
        ParentFolder = workspace
    }
}

Library.ESPFolder.Name = "ESPFolder"

function GetDistance(position)
    if RootPart then
        return (RootPart.Position - position).Magnitude
    elseif Camera then
        return (Camera.CFrame.Position - position).Magnitude
    end
    return 9e9
end

function FindPrimaryPart(instance)
    if instance:IsA("Model") and instance.PrimaryPart then
        return instance.PrimaryPart
    elseif instance:IsA("BasePart") then
        return instance
    else
        local part = instance:FindFirstChildWhichIsA("BasePart") or
            instance:FindFirstChildWhichIsA("UnionOperation") or
            instance:FindFirstChildOfClass("Part")
        return part or instance
    end
end

function Library:ScanAndCreateESP(settings)
    local function isValidTarget(obj)
        if not obj:IsDescendantOf(settings.ParentFolder) then return false end
        if obj.Name ~= settings.TargetName then return false end
        if settings.CheckForHumanoid and obj:IsA("Model") and not obj:FindFirstChild("Humanoid") then return false end
        return true
    end

    for _, obj in pairs(settings.ParentFolder:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("BasePart")) and isValidTarget(obj) then
            if not self.ESP[obj] then
                self:CreateESP(obj, settings)
            end
        end
    end
end

function Library:CreateESP(obj, settings)
    if self.ESP[obj] then return end

    local ESP = {
        Object = obj,
        Settings = settings,
        Folder = Instance.new("Folder"),
        Destroyed = false
    }

    ESP.Folder.Name = settings.Tag
    ESP.Folder.Parent = self.ESPFolder

    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "Billboard"
    Billboard.Size = UDim2.new(0, 200, 0, 50)
    Billboard.AlwaysOnTop = true
    Billboard.Enabled = true
    Billboard.StudsOffset = Vector3.new(0, 1, 0)
    Billboard.Parent = ESP.Folder
    ESP.Billboard = Billboard

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = settings.Color
    Label.TextSize = settings.TextSize
    Label.Font = Enum.Font.RobotoCondensed
    Label.TextStrokeTransparency = 0.5
    Label.RichText = true
    Label.Parent = Billboard
    ESP.Label = Label

    local UIStroke = Instance.new("UIStroke", Label)
    UIStroke.Thickness = 1
    UIStroke.Color = Color3.new(0, 0, 0)

    local Highlight = Instance.new("Highlight")
    Highlight.FillColor = settings.Color
    Highlight.OutlineColor = settings.Color
    Highlight.FillTransparency = 0.65
    Highlight.OutlineTransparency = 0
    Highlight.Parent = ESP.Folder
    ESP.Highlight = Highlight

    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Color = settings.Color
    Tracer.Thickness = settings.TracerThickness
    Tracer.Transparency = settings.TracerTransparency
    ESP.Tracer = Tracer

    function ESP:Destroy()
        if self.Destroyed then return end
        self.Destroyed = true
        
        if self.Tracer then 
            self.Tracer:Remove() 
        end
        if self.Folder then 
            self.Folder:Destroy() 
        end
        
        Library.ESP[self.Object] = nil
    end

    function ESP:Update()
        if self.Destroyed or not self.Object or not self.Object.Parent then
            self:Destroy()
            return false
        end

        local modelRoot = FindPrimaryPart(self.Object)
        if not modelRoot then
            self:ToggleVisibility(false)
            return true
        end

        local pos = modelRoot.Position
        local dist = GetDistance(pos)
        if dist > self.Settings.MaxDistance then
            self:ToggleVisibility(false)
            return true
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
        self:ToggleVisibility(onScreen and Library.Tags[self.Settings.Tag])

        if self.Billboard and self.Billboard.Enabled then
            self.Billboard.Adornee = modelRoot
            if self.Settings.ShowDistance then
                self.Label.Text = string.format("%s\n[%.1fm]", self.Settings.Name, dist)
            else
                self.Label.Text = self.Settings.Name
            end
        end

        if self.Tracer and self.Tracer.Visible then
            local fromY = Camera.ViewportSize.Y
            if self.Settings.TracerPosition == "Top" then
                fromY = 0
            elseif self.Settings.TracerPosition == "Center" then
                fromY = Camera.ViewportSize.Y / 2
            end
            self.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, fromY)
            self.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
        end

        return true
    end

    function ESP:ToggleVisibility(value)
        if self.Billboard then
            self.Billboard.Enabled = value and self.Settings.ShowTextLabel
        end
        if self.Highlight then
            self.Highlight.Adornee = (value and self.Settings.ShowHighlight) and self.Object or nil
        end
        if self.Tracer then
            self.Tracer.Visible = value and self.Settings.ShowTracer or false
        end
    end

    self.ESP[obj] = ESP
    return ESP
end

function Library:EnableTag(tag, settings)
    if self.TagSettings[tag] then return end
    
    for k, v in pairs(self.DefaultSettings) do
        if settings[k] == nil then
            settings[k] = v
        end
    end
    
    self.TagSettings[tag] = settings
    self.Tags[tag] = true
    
    self:ScanAndCreateESP(settings)
    
    local connectionAdded = settings.ParentFolder.DescendantAdded:Connect(function(obj)
        if (obj:IsA("Model") or obj:IsA("BasePart")) and obj.Name == settings.TargetName then
            if not settings.CheckForHumanoid or (obj:IsA("Model") and obj:FindFirstChild("Humanoid")) then
                wait(0.1)
                self:CreateESP(obj, settings)
            end
        end
    end)
    
    local connectionRemoved = settings.ParentFolder.DescendantRemoving:Connect(function(obj)
        if self.ESP[obj] then
            self.ESP[obj]:Destroy()
        end
    end)
    
    self.Connections[tag] = {
        Added = connectionAdded,
        Removed = connectionRemoved
    }
end

function Library:DisableTag(tag)
    if self.Connections[tag] then
        self.Connections[tag].Added:Disconnect()
        self.Connections[tag].Removed:Disconnect()
        self.Connections[tag] = nil
    end
    
    for obj, esp in pairs(self.ESP) do
        if esp.Settings.Tag == tag then
            esp:Destroy()
        end
    end
    
    self.Tags[tag] = false
    self.TagSettings[tag] = nil
end

function Library:SetEnabled(tag, value)
    if value then
        if self.TagSettings[tag] then
            self.Tags[tag] = true
        end
    else
        self.Tags[tag] = false
        for obj, esp in pairs(self.ESP) do
            if esp.Settings.Tag == tag then
                esp:ToggleVisibility(false)
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    for obj, esp in pairs(Library.ESP) do
        if not esp.Destroyed then
            esp:Update()
        end
    end
end)

LP.CharacterAdded:Connect(function(newChar)
    Character = newChar
    RootPart = newChar:WaitForChild("HumanoidRootPart")
end)

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = workspace.CurrentCamera
end)

getgenv().ESPLibrary = Library
return Library