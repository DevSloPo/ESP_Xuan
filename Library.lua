local cloneref = cloneref or function(a) return a end
local Players = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local RunService = cloneref(game:GetService("RunService"))

local LP = Players.LocalPlayer
local Character = LP.Character or LP.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

local ObjectTrackers = {}

local function GetDistance(position)
    if RootPart then
        return (RootPart.Position - position).Magnitude
    elseif Camera then
        return (Camera.CFrame.Position - position).Magnitude
    end
    return 9e9
end

local function FindPrimaryPart(instance)
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

local function findReplacementObject(oldObject)
    if not oldObject then return nil end
    
    local objectName = oldObject.Name
    if oldObject.Parent then
        return oldObject.Parent:FindFirstChild(objectName)
    end
    
    return workspace:FindFirstChild(objectName)
end

local function scanForObjects(settings)
    local foundObjects = {}
    
    if settings.ObjectFinder then
        local result = settings.ObjectFinder()
        if type(result) == "table" then
            for _, obj in pairs(result) do
                if obj and obj:IsA("Instance") then
                    table.insert(foundObjects, obj)
                end
            end
        elseif result and result:IsA("Instance") then
            table.insert(foundObjects, result)
        end
    else
        local function scanFolder(folder)
            for _, item in ipairs(folder:GetDescendants()) do
                if (item:IsA("Model") or item:IsA("BasePart")) and item.Name == settings.TargetName then
                    if not settings.CheckForHumanoid or (item:IsA("Model") and item:FindFirstChild("Humanoid")) then
                        table.insert(foundObjects, item)
                    end
                end
            end
        end
        
        scanFolder(workspace)
    end
    
    return foundObjects
end

local Library = {
    ESP = {},
    Tags = {},
    Connections = {},
    ESPFolder = Instance.new("Folder", CoreGui),
    DefaultSettings = {
        Name = "Unnamed",
        Color = Color3.new(1, 1, 1),
        TextSize = 20,
        Tag = "DefaultTag",
        ShowTextLabel = true,
        ShowHighlight = true,
        ShowDistance = true,
        MaxDistance = math.huge,
        ShowTracer = true,
        TracerPosition = "Bottom",
        TracerThickness = 1,
        TracerTransparency = 1,
        AutoRefresh = true,
        RefreshDelay = 0.5,
        ObjectFinder = nil,
        TargetName = nil,
        CheckForHumanoid = false,
        ParentFolder = workspace
    }
}

Library.ESPFolder.Name = "ESPFolder"

Library.GlobalSettings = setmetatable({}, {
    __newindex = function(_, key, value)
        Library.DefaultSettings[key] = value
        for _, ESP in pairs(Library.ESP) do
            if ESP.Settings then
                ESP.Settings[key] = value
                ESP:UpdateVisuals()
            end
        end
    end
})

local function setupObjectTracking(ESP, originalObject)
    if not ESP.Settings.AutoRefresh then return end
    
    local tracker = {
        ESP = ESP,
        OriginalObject = originalObject,
        LastValidObject = originalObject,
        Connections = {}
    }
    
    local function refreshObject()
        if not ESP or not ESP.Settings then return end
        
        local currentObject = ESP.Settings.Object
        if not currentObject or not currentObject.Parent then
            local newObject = nil
            
            if ESP.Settings.ObjectFinder then
                newObject = ESP.Settings.ObjectFinder(originalObject)
            elseif ESP.Settings.TargetName then
                newObject = workspace:FindFirstChild(ESP.Settings.TargetName)
            else
                newObject = findReplacementObject(originalObject)
            end
            
            if newObject and newObject ~= originalObject then
                ESP.Settings.Object = newObject
                tracker.LastValidObject = newObject
                setupObjectTracking(ESP, newObject)
            else
                if ESP.Destroy then
                    ESP:Destroy()
                end
                ObjectTrackers[originalObject] = nil
            end
        end
    end
    
    local function onObjectDestroyed()
        wait(ESP.Settings.RefreshDelay)
        refreshObject()
    end
    
    local function onAncestryChanged()
        if not originalObject or not originalObject.Parent then
            onObjectDestroyed()
        end
    end
    
    if originalObject:IsA("Instance") then
        tracker.Connections.destroyed = originalObject.Destroying:Connect(onObjectDestroyed)
        tracker.Connections.ancestry = originalObject.AncestryChanged:Connect(onAncestryChanged)
    end
    
    tracker.Connections.heartbeat = RunService.Heartbeat:Connect(function()
        refreshObject()
    end)
    
    ObjectTrackers[originalObject] = tracker
end

Library.AddMultiple = function(settings)
    assert(settings.TargetName or settings.ObjectFinder, "Missing TargetName or ObjectFinder")
    
    local objects = scanForObjects(settings)
    local ESPs = {}
    
    for _, obj in pairs(objects) do
        local espSettings = table.clone(settings)
        espSettings.Object = obj
        espSettings.Name = settings.CustomText or obj.Name
        
        for k, v in pairs(Library.DefaultSettings) do
            if espSettings[k] == nil then
                espSettings[k] = v
            end
        end
        
        local ESP = Library.Add(espSettings)
        table.insert(ESPs, ESP)
    end
    
    return ESPs
end

Library.Add = function(settings)
    assert(settings.Object, "Missing ESP Object")
    for k, v in pairs(Library.DefaultSettings) do
        if settings[k] == nil then
            settings[k] = v
        end
    end

    for _, old in pairs(Library.ESP) do
        if old.Settings and old.Settings.Object == settings.Object then
            old:Destroy()
        end
    end

    local ESP = {
        Settings = settings,
        Folder = Instance.new("Folder"),
    }

    ESP.Folder.Name = settings.Tag
    ESP.Folder.Parent = Library.ESPFolder

    if Library.Tags[settings.Tag] == nil then
        Library.Tags[settings.Tag] = true
    end

    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "Billboard"
    Billboard.Size = UDim2.new(0, 200, 0, 50)
    Billboard.AlwaysOnTop = true
    Billboard.Enabled = true
    Billboard.StudsOffset = Vector3.new(0, 3, 0)
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
    UIStroke.Thickness = 1.5
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
        if self.Tracer then 
            self.Tracer:Remove() 
            self.Tracer = nil
        end
        if self.Folder then 
            self.Folder:Destroy() 
            self.Folder = nil
        end
        if self.Highlight then
            self.Highlight:Destroy()
            self.Highlight = nil
        end
        Library.ESP[self] = nil
    end

    function ESP:UpdateVisuals()
        self.Label.TextColor3 = self.Settings.Color
        self.Highlight.FillColor = self.Settings.Color
        self.Highlight.OutlineColor = self.Settings.Color
        if self.Tracer then
            self.Tracer.Color = self.Settings.Color
        end
    end

    function ESP:ToggleVisibility(value)
        if self.Billboard then
            self.Billboard.Enabled = value and self.Settings.ShowTextLabel
        end
        if self.Highlight then
            self.Highlight.Adornee = (value and self.Settings.ShowHighlight) and self.Settings.Object or nil
        end
        if self.Tracer then
            self.Tracer.Visible = value and self.Settings.ShowTracer or false
        end
    end

    setupObjectTracking(ESP, settings.Object)
    
    Library.ESP[ESP] = ESP
    return ESP
end

Library.SetEnabled = function(tag, value)
    Library.Tags[tag] = value
    for _, ESP in pairs(Library.ESP) do
        if ESP.Settings.Tag == tag then
            ESP:ToggleVisibility(value)
        end
    end
end

Library.ClearAll = function()
    for _, ESP in pairs(Library.ESP) do
        ESP:Destroy()
    end
    Library.ESP = {}
    Library.Tags = {}
end

RunService.RenderStepped:Connect(function()
    for _, ESP in pairs(Library.ESP) do
        local obj = ESP.Settings.Object
        if not obj or not obj.Parent then
            ESP:ToggleVisibility(false)
            continue
        end

        local modelRoot = FindPrimaryPart(obj)
        if not modelRoot then
            ESP:ToggleVisibility(false)
            continue
        end

        local pos = modelRoot.Position
        local dist = GetDistance(pos)
        if dist > ESP.Settings.MaxDistance then
            ESP:ToggleVisibility(false)
            continue
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
        ESP:ToggleVisibility(onScreen and Library.Tags[ESP.Settings.Tag])

        if ESP.Billboard and ESP.Billboard.Enabled then
            ESP.Billboard.Adornee = modelRoot
            if ESP.Settings.ShowDistance then
                ESP.Label.Text = string.format("%s\n[%.1fm]", ESP.Settings.Name, dist)
            else
                ESP.Label.Text = ESP.Settings.Name
            end
        end

        if ESP.Tracer and ESP.Tracer.Visible then
            local fromY = Camera.ViewportSize.Y
            if ESP.Settings.TracerPosition == "Top" then
                fromY = 0
            elseif ESP.Settings.TracerPosition == "Center" then
                fromY = Camera.ViewportSize.Y / 2
            end
            ESP.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, fromY)
            ESP.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
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