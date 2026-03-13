repeat
	task.wait()
until game:IsLoaded()

local library = {}
local ToggleUI = false
library.currentTab = nil
library.flags = {}
local services = setmetatable({}, {
	__index = function(t, k)
		return game.GetService(game, k)
	end,
})
local mouse = services.Players.LocalPlayer:GetMouse()

local Scheme = {
    BackgroundColor = Color3.fromRGB(15, 15, 15),
    MainColor = Color3.fromRGB(25, 25, 25),      
    AccentColor = Color3.fromRGB(125, 85, 255),  
    OutlineColor = Color3.fromRGB(40, 40, 40),   
    FontColor = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.Code,                        
    PlaceholderColor = Color3.fromRGB(180, 180, 180)
}

local function AddOutline(instance, cornerRadius)
    local stroke = Instance.new("UIStroke")
    stroke.Parent = instance
    stroke.Color = Scheme.OutlineColor
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return stroke
end

function Tween(obj, t, data)
	services.TweenService
		:Create(obj, TweenInfo.new(t[1], Enum.EasingStyle[t[2]], Enum.EasingDirection[t[3]]), data)
		:Play()
	return true
end

local function MakeResizable(frame, handle)
    local dragging = false
    local dragStart, startSize

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startSize = frame.Size
            
            local endCon
            endCon = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    endCon:Disconnect()
                end
            end)
        end
    end)

    services.UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Size = UDim2.new(
                startSize.X.Scale, 
                math.max(380, startSize.X.Offset + delta.X),
                startSize.Y.Scale, 
                math.max(280, startSize.Y.Offset + delta.Y) 
            )
        end
    end)
end

function drag(frame, hold)
	if not hold then
		hold = frame
	end
	local dragging = false
	local dragStart, startPos

	hold.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
            
            local endCon
			endCon = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
                    endCon:Disconnect()
				end
			end)
		end
	end)
    
    services.UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X, 
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local toggled = false
local switchingTabs = false

function switchTab(new)
	if switchingTabs then
		return
	end
	local old = library.currentTab
	if old == nil then
		new[2].Visible = true
		library.currentTab = new
		services.TweenService:Create(new[1], TweenInfo.new(0.1), { ImageColor3 = Scheme.AccentColor, ImageTransparency = 0 }):Play()
		services.TweenService:Create(new[1].TabText, TweenInfo.new(0.1), { TextTransparency = 0, TextColor3 = Scheme.AccentColor }):Play()
		return
	end
	if old[1] == new[1] then
		return
	end
	switchingTabs = true
	library.currentTab = new
	services.TweenService:Create(old[1], TweenInfo.new(0.1), { ImageColor3 = Scheme.FontColor, ImageTransparency = 0.5 }):Play()
    services.TweenService:Create(old[1].TabText, TweenInfo.new(0.1), { TextTransparency = 0.5, TextColor3 = Scheme.FontColor }):Play()
    

	services.TweenService:Create(new[1], TweenInfo.new(0.1), { ImageColor3 = Scheme.AccentColor, ImageTransparency = 0 }):Play()
	services.TweenService:Create(new[1].TabText, TweenInfo.new(0.1), { TextTransparency = 0, TextColor3 = Scheme.AccentColor }):Play()
	
    old[2].Visible = false
	new[2].Visible = true
	task.wait(0.1)
	switchingTabs = false
end

function library.new(arg1, arg2, arg3)
    local name, theme
    if type(arg1) == "table" then
        name = arg2
        theme = arg3
    else
        name = arg1
        theme = arg2
    end
    name = name or "Library"

	for _, v in next, services.CoreGui:GetChildren() do
		if v.Name == "REN" then
			v:Destroy()
		end
	end
	
	local dogent = Instance.new("ScreenGui")
	local Main = Instance.new("Frame")
	local TabMain = Instance.new("Frame")
	local MainC = Instance.new("UICorner")
	local SB = Instance.new("Frame")
	local SBC = Instance.new("UICorner")
	local Side = Instance.new("Frame")
	local TabBtns = Instance.new("ScrollingFrame")
	local TabBtnsL = Instance.new("UIListLayout")
	local ScriptTitle = Instance.new("TextLabel")
	local Open = Instance.new("TextButton")
	local UIG = Instance.new("UIGradient")
	local UICornerMain = Instance.new("UICorner")

    local SearchContainer = Instance.new("Frame")
    local SearchBox = Instance.new("TextBox")
    local SearchIcon = Instance.new("ImageLabel")
    local SearchCorner = Instance.new("UICorner")
    local SearchStroke = Instance.new("UIStroke")

    local MoveIconBtn = Instance.new("ImageButton")
    
    local ResizeHandle = Instance.new("ImageButton")

    local VersionLabel = Instance.new("TextLabel")

	if syn and syn.protect_gui then
		syn.protect_gui(dogent)
	end
	
	dogent.Name = "REN"
	dogent.Parent = services.CoreGui
	
	function UiDestroy()
		dogent:Destroy()
	end

    function ToggleUILib()
        Main.Visible = not Main.Visible
    end
	
	Main.Name = "Main"
	Main.Parent = dogent
	Main.AnchorPoint = Vector2.new(0.5, 0.5)
	Main.BackgroundColor3 = Scheme.BackgroundColor
	Main.BackgroundTransparency = 0
	Main.Position = UDim2.new(0.5, 0, 0.5, 0)
	Main.Size = UDim2.new(0, 486, 0, 290) 
	Main.ZIndex = 1
	Main.Active = true
    Main.ClipsDescendants = true 
    AddOutline(Main, 4)
	
	services.UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.RightControl then
			Main.Visible = not Main.Visible
		end
	end)
	
	drag(Main, MoveIconBtn)
    drag(Main, Side)

	UICornerMain.Parent = Main
	UICornerMain.CornerRadius = UDim.new(0, 4)

	TabMain.Name = "TabMain"
	TabMain.Parent = Main
	TabMain.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TabMain.BackgroundTransparency = 1.000
	TabMain.Position = UDim2.new(0.25, 0, 0, 36) 
	TabMain.Size = UDim2.new(0.74, 0, 0.85, -15) 
	
	MainC.CornerRadius = UDim.new(0, 4)
	MainC.Name = "MainC"
	MainC.Parent = Main
	
	SB.Name = "SB"
	SB.Parent = Main
	SB.BackgroundColor3 = Scheme.BackgroundColor
    SB.BorderSizePixel = 0
	SB.BackgroundTransparency = 0
	SB.Size = UDim2.new(0, 8, 1, 0) 
	
	SBC.CornerRadius = UDim.new(0, 4)
	SBC.Name = "SBC"
	SBC.Parent = SB
	
	Side.Name = "Side"
	Side.Parent = SB
	Side.BackgroundColor3 = Scheme.BackgroundColor
	Side.BackgroundTransparency = 0
	Side.BorderColor3 = Scheme.OutlineColor
	Side.BorderSizePixel = 0
	Side.ClipsDescendants = true
	Side.Position = UDim2.new(1, 0, 0, 0)
	Side.Size = UDim2.new(0, 94, 1, 0) 
    
    local Separator = Instance.new("Frame")
    Separator.Parent = Main
    Separator.BackgroundColor3 = Scheme.OutlineColor
    Separator.BorderSizePixel = 0
    Separator.Position = UDim2.new(0, 100, 0, 0) 
    Separator.Size = UDim2.new(0, 1, 1, 0)

	TabBtns.Name = "TabBtns"
	TabBtns.Parent = Side
	TabBtns.Active = true
	TabBtns.BackgroundColor3 = Scheme.BackgroundColor
	TabBtns.BackgroundTransparency = 1.000
	TabBtns.BorderSizePixel = 0
	TabBtns.Position = UDim2.new(0, 0, 0.11, 0) 
	TabBtns.Size = UDim2.new(1, 0, 0.9, -15) 
	TabBtns.CanvasSize = UDim2.new(0, 0, 1, 0)
	TabBtns.ScrollBarThickness = 0
	
	TabBtnsL.Name = "TabBtnsL"
	TabBtnsL.Parent = TabBtns
	TabBtnsL.SortOrder = Enum.SortOrder.LayoutOrder
	TabBtnsL.Padding = UDim.new(0, 8) 
	
ScriptTitle.Name = "ScriptTitle"
ScriptTitle.Parent = Side
ScriptTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ScriptTitle.BackgroundTransparency = 1.000
ScriptTitle.Position = UDim2.new(0, 25, 0, 5) 
ScriptTitle.Size = UDim2.new(0, 90, 0, 18) 
ScriptTitle.Font = Scheme.Font
ScriptTitle.Text = name
ScriptTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ScriptTitle.TextSize = 13.000 
ScriptTitle.TextTransparency = 0
ScriptTitle.TextScaled = true
ScriptTitle.TextXAlignment = Enum.TextXAlignment.Left
ScriptTitle.ZIndex = 10
ScriptTitle.TextStrokeTransparency = 0.5
ScriptTitle.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

local ImageLabel = Instance.new("ImageLabel")
ImageLabel.Name = "TitleIcon"
ImageLabel.Parent = ScriptTitle
ImageLabel.BackgroundTransparency = 1.000
ImageLabel.Position = UDim2.new(0, -22, 0, 0) 
ImageLabel.Size = UDim2.new(0, 18, 0, 18) 
ImageLabel.Image = "rbxassetid://136469174415866"
ImageLabel.ImageTransparency = 0
ImageLabel.ZIndex = 11

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.14, Color3.fromRGB(255, 165, 0)),
    ColorSequenceKeypoint.new(0.28, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.42, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.56, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.70, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(0.84, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
})
UIGradient.Rotation = 0
UIGradient.Transparency = NumberSequence.new(0)
UIGradient.Parent = ScriptTitle

if not LayoutRefs then
    LayoutRefs = {}
end
LayoutRefs.WindowTitleGradient = UIGradient
LayoutRefs.GradientAnimationSpeed = 0.25

local RunService = game:GetService("RunService")
local gradientAnimation

gradientAnimation = RunService.RenderStepped:Connect(function(deltaTime)
    if not ScriptTitle or not ScriptTitle:IsDescendantOf(game) or ScriptTitle.Parent == nil then
        if gradientAnimation then
            gradientAnimation:Disconnect()
        end
        return
    end
    
    if UIGradient and UIGradient.Parent then
        UIGradient.Rotation = UIGradient.Rotation + (90 * deltaTime)
        if UIGradient.Rotation >= 360 then
            UIGradient.Rotation = UIGradient.Rotation - 360
        end
    else
        if gradientAnimation then
            gradientAnimation:Disconnect()
        end
    end
end)

    SearchContainer.Name = "SearchContainer"
    SearchContainer.Parent = Main
    SearchContainer.BackgroundColor3 = Scheme.MainColor
    SearchContainer.BackgroundTransparency = 0
    SearchContainer.Position = UDim2.new(0.26, 0, 0.02, 0) 
    SearchContainer.Size = UDim2.new(0.62, 0, 0, 24) 
    
    SearchCorner.CornerRadius = UDim.new(0, 3) 
    SearchCorner.Parent = SearchContainer
    
    SearchStroke.Parent = SearchContainer
    SearchStroke.Color = Scheme.OutlineColor
    SearchStroke.Thickness = 1
    SearchStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    SearchIcon.Name = "SearchIcon"
    SearchIcon.Parent = SearchContainer
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Position = UDim2.new(0, 6, 0.5, -7) 
    SearchIcon.Size = UDim2.new(0, 14, 0, 14) 
    SearchIcon.Image = "rbxassetid://6031154871"
    SearchIcon.ImageColor3 = Scheme.PlaceholderColor

    SearchBox.Name = "SearchBox"
    SearchBox.Parent = SearchContainer
    SearchBox.BackgroundTransparency = 1
    SearchBox.Position = UDim2.new(0, 26, 0, 0) 
    SearchBox.Size = UDim2.new(1, -26, 1, 0)
    SearchBox.Font = Scheme.Font
    SearchBox.PlaceholderText = "Search"
    SearchBox.PlaceholderColor3 = Scheme.PlaceholderColor
    SearchBox.Text = ""
    SearchBox.TextColor3 = Scheme.FontColor
    SearchBox.TextSize = 12 
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left

    local function FilterElements(text)
        text = text:lower()
        if not library.currentTab then return end
        
        local currentTabFrame = library.currentTab[2] 
        
        for _, section in pairs(currentTabFrame:GetChildren()) do
            if section:IsA("Frame") and section.Name == "Section" then
                local objs = section:FindFirstChild("Objs")
                local hasVisibleItems = false
                
                if objs then
                    for _, item in pairs(objs:GetChildren()) do
                        if item:IsA("Frame") and item:FindFirstChildWhichIsA("GuiButton") then
                            local btn = item:FindFirstChildWhichIsA("GuiButton") 
                            local labelText = ""
                            
                            if btn:IsA("TextButton") or btn:IsA("TextLabel") then
                                labelText = btn.Text:lower()
                            end
                            if labelText == "" or labelText:match("^%s*$") then
                                for _, inner in pairs(btn:GetChildren()) do
                                    if inner:IsA("TextLabel") then
                                        labelText = inner.Text:lower()
                                        break
                                    end
                                end
                            end

                            if labelText:find(text) then
                                item.Visible = true
                                hasVisibleItems = true
                            else
                                item.Visible = false
                            end
                        end
                    end
                end
                
                if text ~= "" then
                    section.Visible = hasVisibleItems
                else
                    section.Visible = true
                end
            end
        end
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        FilterElements(SearchBox.Text)
    end)

MoveIconBtn.Name = "MoveIcon"
MoveIconBtn.Parent = Main
MoveIconBtn.BackgroundTransparency = 1
MoveIconBtn.Position = UDim2.new(1, -30, 0.02, 0) 
MoveIconBtn.Size = UDim2.new(0, 24, 0, 24) 
MoveIconBtn.Image = "rbxassetid://71795269657276" 
MoveIconBtn.ImageColor3 = Color3.new(1, 1, 1)
MoveIconBtn.ImageTransparency = 0.5
MoveIconBtn.ZIndex = 50
    
    MoveIconBtn.MouseEnter:Connect(function()
        MoveIconBtn.ImageTransparency = 0
    end)
    MoveIconBtn.MouseLeave:Connect(function()
        MoveIconBtn.ImageTransparency = 0.5
    end)

    ResizeHandle.Name = "ResizeHandle"
    ResizeHandle.Parent = Main
    ResizeHandle.BackgroundTransparency = 1
    ResizeHandle.AnchorPoint = Vector2.new(1, 1)
    ResizeHandle.Position = UDim2.new(1, -2, 1, -2) 
    ResizeHandle.Size = UDim2.new(0, 16, 0, 16) 
    ResizeHandle.Image = "rbxassetid://6031097225" 
    ResizeHandle.ImageColor3 = Scheme.FontColor
    ResizeHandle.ImageTransparency = 0.5
    ResizeHandle.ZIndex = 50 
    
    MakeResizable(Main, ResizeHandle)

    VersionLabel.Name = "VersionLabel"
    VersionLabel.Parent = Main
    VersionLabel.BackgroundTransparency = 1
    VersionLabel.Position = UDim2.new(0, 0, 1, -16) 
    VersionLabel.Size = UDim2.new(1, 0, 0, 16) 
    VersionLabel.Font = Scheme.Font
    local player = game.Players.LocalPlayer
VersionLabel.Text = player.Name .. "丨" .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    VersionLabel.TextColor3 = Scheme.PlaceholderColor
    VersionLabel.TextSize = 10 
    VersionLabel.TextTransparency = 0.5
    VersionLabel.TextXAlignment = Enum.TextXAlignment.Center
    VersionLabel.ZIndex = 10

	TabBtnsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		TabBtns.CanvasSize = UDim2.new(0, 0, 0, TabBtnsL.AbsoluteContentSize.Y + 15) 
	end)
	
    Open.Name = "Open"
    Open.Parent = dogent
    Open.BackgroundColor3 = Scheme.MainColor
    Open.BackgroundTransparency = 0
    Open.Position = UDim2.new(0.008, 0, 0.311, 0)
    Open.Size = UDim2.new(0, 52, 0, 26) 
    Open.Font = Scheme.Font
    Open.Text = "    开关    "
    Open.TextColor3 = Scheme.FontColor
    Open.TextTransparency = 0
    Open.TextSize = 12.000 
    Open.Active = true
    Open.Draggable = true
    Open.ZIndex = 100
    AddOutline(Open, 3) 
    local OpenCorner = Instance.new("UICorner")
    OpenCorner.CornerRadius = UDim.new(0,3) 
    OpenCorner.Parent = Open

    UIG.Parent = Open

    Open.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
    end)
	
	local window = {}
	
	function window.Tab(window, name, icon)
		local Tab = Instance.new("ScrollingFrame")
		local TabIco = Instance.new("ImageLabel")
		local TabText = Instance.new("TextLabel")
		local TabBtn = Instance.new("TextButton")
		local TabL = Instance.new("UIListLayout")
		
		Tab.Name = "Tab"
		Tab.Parent = TabMain
		Tab.Active = true
		Tab.BackgroundColor3 = Scheme.BackgroundColor
		Tab.BackgroundTransparency = 1.000
		Tab.Size = UDim2.new(1, 0, 1, 0)
		Tab.ScrollBarThickness = 2
        Tab.ScrollBarImageColor3 = Scheme.OutlineColor
		Tab.Visible = false
		
		TabIco.Name = "TabIco"
		TabIco.Parent = TabBtns
		TabIco.BackgroundTransparency = 1.000
		TabIco.BorderSizePixel = 0
		TabIco.Size = UDim2.new(0, 20, 0, 20) 
		TabIco.Image = ("rbxassetid://%s"):format((icon or 4370341699))
		TabIco.ImageTransparency = 0.5
        TabIco.ImageColor3 = Scheme.FontColor
		
		TabText.Name = "TabText"
		TabText.Parent = TabIco
		TabText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TabText.BackgroundTransparency = 1.000
		TabText.Position = UDim2.new(1.2, 0, 0, 0) 
		TabText.Size = UDim2.new(0, 65, 0, 20) 
		TabText.Font = Scheme.Font
		TabText.Text = name
		TabText.TextColor3 = Scheme.FontColor
		TabText.TextSize = 12.000 
		TabText.TextTransparency = 0.5
		TabText.TextXAlignment = Enum.TextXAlignment.Left
		
		TabBtn.Name = "TabBtn"
		TabBtn.Parent = TabIco
		TabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TabBtn.BackgroundTransparency = 1.000
		TabBtn.BorderSizePixel = 0
		TabBtn.Size = UDim2.new(0, 94, 0, 20) 
		TabBtn.AutoButtonColor = false
		TabBtn.Font = Enum.Font.SourceSans
		TabBtn.Text = ""
		TabBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
		TabBtn.TextSize = 14.000
		
		TabL.Name = "TabL"
		TabL.Parent = Tab
		TabL.SortOrder = Enum.SortOrder.LayoutOrder
		TabL.Padding = UDim.new(0, 3) 
		
		TabBtn.MouseButton1Click:Connect(function()
			spawn(function()
			end)
			switchTab({ TabIco, Tab })
		end)
		
		if library.currentTab == nil then
			switchTab({ TabIco, Tab })
		end
		
		TabL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Tab.CanvasSize = UDim2.new(0, 0, 0, TabL.AbsoluteContentSize.Y + 6) 
		end)
		
		local tab = {}
		
		function tab.section(tab, name, TabVal)
			local Section = Instance.new("Frame")
			local SectionC = Instance.new("UICorner")
			local SectionText = Instance.new("TextLabel")
			local SectionOpen = Instance.new("ImageLabel")
			local SectionOpened = Instance.new("ImageLabel")
			local SectionToggle = Instance.new("ImageButton")
			local Objs = Instance.new("Frame")
			local ObjsL = Instance.new("UIListLayout")
			
			Section.Name = "Section"
			Section.Parent = Tab
			Section.BackgroundColor3 = Scheme.BackgroundColor
			Section.BackgroundTransparency = 0
			Section.BorderSizePixel = 0
			Section.ClipsDescendants = true
			Section.Size = UDim2.new(0.98, 0, 0, 28) 
            AddOutline(Section, 3) 
			
			SectionC.CornerRadius = UDim.new(0, 3) 
			SectionC.Name = "SectionC"
			SectionC.Parent = Section
			
			SectionText.Name = "SectionText"
			SectionText.Parent = Section
			SectionText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SectionText.BackgroundTransparency = 1.000
			SectionText.Position = UDim2.new(0.02, 0, 0, 0) 
			SectionText.Size = UDim2.new(0, 340, 0, 28) 
			SectionText.Font = Scheme.Font
			SectionText.Text = name
			SectionText.TextColor3 = Scheme.FontColor
			SectionText.TextSize = 12.000 
			SectionText.TextTransparency = 0
			SectionText.TextXAlignment = Enum.TextXAlignment.Left
			
			SectionOpen.Name = "SectionOpen"
			SectionOpen.Parent = SectionText
			SectionOpen.BackgroundTransparency = 1
			SectionOpen.BorderSizePixel = 0
			SectionOpen.Position = UDim2.new(0, -5, 0, 4) 
			SectionOpen.Size = UDim2.new(0, 20, 0, 20) 
			SectionOpen.Image = "http://www.roblox.com/asset/?id=6031302934"
            SectionOpen.ImageColor3 = Scheme.FontColor
            SectionOpen.Visible = false 
			
			SectionOpened.Name = "SectionOpened"
			SectionOpened.Parent = SectionOpen
			SectionOpened.BackgroundTransparency = 1.000
			SectionOpened.BorderSizePixel = 0
			SectionOpened.Size = UDim2.new(0, 20, 0, 20) 
			SectionOpened.Image = "http://www.roblox.com/asset/?id=6031302932"
			SectionOpened.ImageTransparency = 1.000
            SectionOpened.ImageColor3 = Scheme.FontColor
			
			SectionToggle.Name = "SectionToggle"
			SectionToggle.Parent = Section
			SectionToggle.BackgroundTransparency = 1
			SectionToggle.BorderSizePixel = 0
			SectionToggle.Size = UDim2.new(1, 0, 0, 28) 
			
			Objs.Name = "Objs"
			Objs.Parent = Section
			Objs.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Objs.BackgroundTransparency = 1
			Objs.BorderSizePixel = 0
			Objs.Position = UDim2.new(0, 5, 0, 28) 
			Objs.Size = UDim2.new(0.98, 0, 0, 0)
			
			ObjsL.Name = "ObjsL"
			ObjsL.Parent = Objs
			ObjsL.SortOrder = Enum.SortOrder.LayoutOrder
			ObjsL.Padding = UDim.new(0, 6) 
			
			local open = true 
			if TabVal == false then open = false end

			local function UpdateSize()
				if not open then return end
                local contentHeight = 0
                for _, child in pairs(Objs:GetChildren()) do
                    if child:IsA("Frame") and child.Visible then
                        contentHeight = contentHeight + child.AbsoluteSize.Y + ObjsL.Padding.Offset
                    end
                end
				Section.Size = UDim2.new(0.98, 0, 0, 28 + contentHeight + 6) 
			end

			if TabVal ~= false then
				UpdateSize()
			end
			
			SectionToggle.MouseButton1Click:Connect(function()
				open = not open
                if open then
                    UpdateSize()
                else
                    Section.Size = UDim2.new(0.98, 0, 0, 28) 
                end
			end)
			
			ObjsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize)
            Objs.ChildAdded:Connect(function(child)
                child:GetPropertyChangedSignal("Visible"):Connect(UpdateSize)
            end)
			
			local section = {}
			
			function section.Button(section, text, callback)
				local callback = callback or function() end
				local BtnModule = Instance.new("Frame")
				local Btn = Instance.new("TextButton")
				local BtnC = Instance.new("UICorner")
				
				BtnModule.Name = "BtnModule"
				BtnModule.Parent = Objs
				BtnModule.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				BtnModule.BackgroundTransparency = 1.000
				BtnModule.BorderSizePixel = 0
				BtnModule.Position = UDim2.new(0, 0, 0, 0)
				BtnModule.Size = UDim2.new(0, 363, 0, 24) 
				
				Btn.Name = "Btn"
				Btn.Parent = BtnModule
				Btn.BackgroundColor3 = Scheme.MainColor
				Btn.BackgroundTransparency = 0
				Btn.BorderSizePixel = 0
				Btn.Size = UDim2.new(0, 363, 0, 24) 
				Btn.AutoButtonColor = false
				Btn.Font = Scheme.Font
				Btn.Text = text
				Btn.TextColor3 = Scheme.FontColor
				Btn.TextSize = 12.000 
				Btn.TextTransparency = 0
				Btn.TextXAlignment = Enum.TextXAlignment.Center 
                AddOutline(Btn, 3) 
				
				BtnC.CornerRadius = UDim.new(0, 3) 
				BtnC.Name = "BtnC"
				BtnC.Parent = Btn
				
				Btn.MouseButton1Click:Connect(function()
                    local oldColor = Btn.BackgroundColor3
                    Btn.BackgroundColor3 = Scheme.AccentColor
                    wait(0.1)
                    Btn.BackgroundColor3 = oldColor
					spawn(callback)
				end)
				
				UpdateSize()
			end
			
			function section:Label(text)
				local LabelModule = Instance.new("Frame")
				local TextLabel = Instance.new("TextLabel")
				local LabelC = Instance.new("UICorner")
				
				LabelModule.Name = "LabelModule"
				LabelModule.Parent = Objs
				LabelModule.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				LabelModule.BackgroundTransparency = 1.000
				LabelModule.BorderSizePixel = 0
				LabelModule.Position = UDim2.new(0, 0, NAN, 0)
				LabelModule.Size = UDim2.new(0, 363, 0, 16) 
				
				TextLabel.Parent = LabelModule
				TextLabel.BackgroundColor3 = Scheme.BackgroundColor
				TextLabel.BackgroundTransparency = 1
				TextLabel.Size = UDim2.new(0, 363, 0, 18) 
				TextLabel.Font = Scheme.Font
				TextLabel.Text = text
				TextLabel.TextColor3 = Scheme.FontColor
				TextLabel.TextSize = 12.000 
				TextLabel.TextTransparency = 0
				
				LabelC.CornerRadius = UDim.new(0, 3) 
				LabelC.Name = "LabelC"
				LabelC.Parent = TextLabel
				
				UpdateSize()
				return TextLabel
			end
			
			function section.Toggle(section, text, flag, enabled, callback)
				local callback = callback or function() end
				local enabled = enabled or false
				assert(text, "No text provided")
				assert(flag, "No flag provided")
				library.flags[flag] = enabled
				
				local ToggleModule = Instance.new("Frame")
				local ToggleBtn = Instance.new("TextButton")
				local ToggleBtnC = Instance.new("UICorner")
				local ToggleDisable = Instance.new("Frame")
				local ToggleSwitch = Instance.new("Frame")
				local ToggleSwitchC = Instance.new("UICorner")
				local ToggleDisableC = Instance.new("UICorner")
				
				ToggleModule.Name = "ToggleModule"
				ToggleModule.Parent = Objs
				ToggleModule.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ToggleModule.BackgroundTransparency = 1.000
				ToggleModule.BorderSizePixel = 0
				ToggleModule.Position = UDim2.new(0, 0, 0, 0)
				ToggleModule.Size = UDim2.new(0, 363, 0, 24) 
				
				ToggleBtn.Name = "ToggleBtn"
				ToggleBtn.Parent = ToggleModule
				ToggleBtn.BackgroundColor3 = Scheme.MainColor
				ToggleBtn.BackgroundTransparency = 0
				ToggleBtn.BorderSizePixel = 0
				ToggleBtn.Size = UDim2.new(0, 363, 0, 24) 
				ToggleBtn.AutoButtonColor = false
				ToggleBtn.Font = Scheme.Font
				ToggleBtn.Text = "   " .. text
				ToggleBtn.TextColor3 = Scheme.FontColor
				ToggleBtn.TextSize = 12.000 
				ToggleBtn.TextTransparency = 0
				ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
                AddOutline(ToggleBtn, 3) 
				
				ToggleBtnC.CornerRadius = UDim.new(0, 3) 
				ToggleBtnC.Name = "ToggleBtnC"
				ToggleBtnC.Parent = ToggleBtn
				
				ToggleDisable.Name = "ToggleDisable"
				ToggleDisable.Parent = ToggleBtn
				ToggleDisable.BackgroundColor3 = Scheme.BackgroundColor
				ToggleDisable.BackgroundTransparency = 0
				ToggleDisable.BorderSizePixel = 0
				ToggleDisable.Position = UDim2.new(0.86, 0, 0.5, -7) 
				ToggleDisable.Size = UDim2.new(0, 28, 0, 14) 
                AddOutline(ToggleDisable, 7) 
				
				ToggleSwitch.Name = "ToggleSwitch"
				ToggleSwitch.Parent = ToggleDisable
				ToggleSwitch.BackgroundColor3 = Scheme.FontColor
				ToggleSwitch.Size = UDim2.new(0, 14, 0, 14) 
				
				ToggleSwitchC.CornerRadius = UDim.new(1, 0)
				ToggleSwitchC.Name = "ToggleSwitchC"
				ToggleSwitchC.Parent = ToggleSwitch
				
				ToggleDisableC.CornerRadius = UDim.new(1, 0)
				ToggleDisableC.Name = "ToggleDisableC"
				ToggleDisableC.Parent = ToggleDisable
				
				local funcs = {
					SetState = function(self, state)
						if state == nil then
							state = not library.flags[flag]
						end
						if library.flags[flag] == state then
							return
						end
						services.TweenService
							:Create(
								ToggleSwitch,
								TweenInfo.new(0.2),
								{
									Position = UDim2.new(0, (state and 14 or 0), 0, 0), 
									BackgroundColor3 = (state and Scheme.AccentColor or Scheme.FontColor),
								}
							)
							:Play()
                        services.TweenService
							:Create(
								ToggleDisable,
								TweenInfo.new(0.2),
								{
									BackgroundColor3 = (state and Scheme.MainColor or Scheme.BackgroundColor),
								}
							)
							:Play()
						library.flags[flag] = state
						callback(state)
					end,
					Module = ToggleModule,
				}
				
				if enabled ~= false then
					funcs:SetState(flag, true)
				end
				
				ToggleBtn.MouseButton1Click:Connect(function()
					funcs:SetState()
				end)
				
				UpdateSize()
				return funcs
			end
			
			function section.Keybind(section, text, default, callback)
				local callback = callback or function() end
				assert(text, "No text provided")
				assert(default, "No default key provided")
				local default = (typeof(default) == "string" and Enum.KeyCode[default] or default)
				local banned = {
					Return = true,
					Space = true,
					Tab = true,
					Backquote = true,
					CapsLock = true,
					Escape = true,
					Unknown = true,
				}
				local shortNames = {
					RightControl = "RCtrl",
					LeftControl = "LCtrl",
					LeftShift = "LShift",
					RightShift = "RShift",
					Semicolon = ";",
					Quote = '"',
					LeftBracket = "[",
					RightBracket = "]",
					Equals = "=",
					Minus = "-",
					RightAlt = "RAlt",
					LeftAlt = "LAlt",
				}
				local bindKey = default
				local keyTxt = (default and (shortNames[default.Name] or default.Name) or "None")
				
				local KeybindModule = Instance.new("Frame")
				local KeybindBtn = Instance.new("TextButton")
				local KeybindBtnC = Instance.new("UICorner")
				local KeybindValue = Instance.new("TextButton")
				local KeybindValueC = Instance.new("UICorner")
				local KeybindL = Instance.new("UIListLayout")
				local UIPadding = Instance.new("UIPadding")
				
				KeybindModule.Name = "KeybindModule"
				KeybindModule.Parent = Objs
				KeybindModule.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				KeybindModule.BackgroundTransparency = 1.000
				KeybindModule.BorderSizePixel = 0
				KeybindModule.Position = UDim2.new(0, 0, 0, 0)
				KeybindModule.Size = UDim2.new(0, 363, 0, 24) 
				
				KeybindBtn.Name = "KeybindBtn"
				KeybindBtn.Parent = KeybindModule
				KeybindBtn.BackgroundColor3 = Scheme.MainColor
				KeybindBtn.BackgroundTransparency = 0
				KeybindBtn.BorderSizePixel = 0
				KeybindBtn.Size = UDim2.new(0, 363, 0, 24) 
				KeybindBtn.AutoButtonColor = false
				KeybindBtn.Font = Scheme.Font
				KeybindBtn.Text = "   " .. text
				KeybindBtn.TextColor3 = Scheme.FontColor
				KeybindBtn.TextSize = 12.000 
				KeybindBtn.TextTransparency = 0
				KeybindBtn.TextXAlignment = Enum.TextXAlignment.Left
                AddOutline(KeybindBtn, 3) 
				
				KeybindBtnC.CornerRadius = UDim.new(0, 3) 
				KeybindBtnC.Name = "KeybindBtnC"
				KeybindBtnC.Parent = KeybindBtn
				
				KeybindValue.Name = "KeybindValue"
				KeybindValue.Parent = KeybindBtn
				KeybindValue.BackgroundColor3 = Scheme.BackgroundColor
				KeybindValue.BackgroundTransparency = 0
				KeybindValue.BorderSizePixel = 0
				KeybindValue.Position = UDim2.new(0.73, 0, 0.2, 0) 
				KeybindValue.Size = UDim2.new(0, 80, 0, 16) 
				KeybindValue.AutoButtonColor = false
				KeybindValue.Font = Scheme.Font
				KeybindValue.Text = keyTxt
				KeybindValue.TextColor3 = Scheme.FontColor
				KeybindValue.TextSize = 12.000 
				KeybindValue.TextTransparency = 0
                AddOutline(KeybindValue, 3) 
				
				KeybindValueC.CornerRadius = UDim.new(0, 3) 
				KeybindValueC.Name = "KeybindValueC"
				KeybindValueC.Parent = KeybindValue
				
				KeybindL.Name = "KeybindL"
				KeybindL.Parent = KeybindBtn
				KeybindL.HorizontalAlignment = Enum.HorizontalAlignment.Right
				KeybindL.SortOrder = Enum.SortOrder.LayoutOrder
				KeybindL.VerticalAlignment = Enum.VerticalAlignment.Center
				
				UIPadding.Parent = KeybindBtn
				UIPadding.PaddingRight = UDim.new(0, 5) 
				
				services.UserInputService.InputBegan:Connect(function(inp, gpe)
					if gpe then
						return
					end
					if inp.UserInputType ~= Enum.UserInputType.Keyboard then
						return
					end
					if inp.KeyCode ~= bindKey then
						return
					end
					callback(bindKey.Name)
				end)
				
				KeybindValue.MouseButton1Click:Connect(function()
					KeybindValue.Text = "..."
					wait()
					local key, uwu = services.UserInputService.InputEnded:Wait()
					local keyName = tostring(key.KeyCode.Name)
					if key.UserInputType ~= Enum.UserInputType.Keyboard then
						KeybindValue.Text = keyTxt
						return
					end
					if banned[keyName] then
						KeybindValue.Text = keyTxt
						return
					end
					wait()
					bindKey = Enum.KeyCode[keyName]
					KeybindValue.Text = shortNames[keyName] or keyName
				end)
				
				KeybindValue:GetPropertyChangedSignal("TextBounds"):Connect(function()
					KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 25, 0, 16) 
				end)
				
				KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 25, 0, 16) 
				
				UpdateSize()
			end
			
			function section.Textbox(section, text, flag, default, callback)
				local callback = callback or function() end
				assert(text, "No text provided")
				assert(flag, "No flag provided")
				assert(default, "No default text provided")
				library.flags[flag] = default
				
				local TextboxModule = Instance.new("Frame")
				local TextboxBack = Instance.new("TextButton")
				local TextboxBackC = Instance.new("UICorner")
				local BoxBG = Instance.new("TextButton")
				local BoxBGC = Instance.new("UICorner")
				local TextBox = Instance.new("TextBox")
				local TextboxBackL = Instance.new("UIListLayout")
				local TextboxBackP = Instance.new("UIPadding")
				
				TextboxModule.Name = "TextboxModule"
				TextboxModule.Parent = Objs
				TextboxModule.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextboxModule.BackgroundTransparency = 1.000
				TextboxModule.BorderSizePixel = 0
				TextboxModule.Position = UDim2.new(0, 0, 0, 0)
				TextboxModule.Size = UDim2.new(0, 363, 0, 24) 
				
				TextboxBack.Name = "TextboxBack"
				TextboxBack.Parent = TextboxModule
				TextboxBack.BackgroundColor3 = Scheme.MainColor
				TextboxBack.BackgroundTransparency = 0
				TextboxBack.BorderSizePixel = 0
				TextboxBack.Size = UDim2.new(0, 363, 0, 24) 
				TextboxBack.AutoButtonColor = false
				TextboxBack.Font = Scheme.Font
				TextboxBack.Text = "   " .. text
				TextboxBack.TextColor3 = Scheme.FontColor
				TextboxBack.TextSize = 12.000 
				TextboxBack.TextTransparency = 0
				TextboxBack.TextXAlignment = Enum.TextXAlignment.Left
                AddOutline(TextboxBack, 3) 
				
				TextboxBackC.CornerRadius = UDim.new(0, 3) 
				TextboxBackC.Name = "TextboxBackC"
				TextboxBackC.Parent = TextboxBack
				
				BoxBG.Name = "BoxBG"
				BoxBG.Parent = TextboxBack
				BoxBG.BackgroundColor3 = Scheme.BackgroundColor
				BoxBG.BackgroundTransparency = 0
				BoxBG.BorderSizePixel = 0
				BoxBG.Position = UDim2.new(0.73, 0, 0.2, 0) 
				BoxBG.Size = UDim2.new(0, 80, 0, 16) 
				BoxBG.AutoButtonColor = false
				BoxBG.Font = Scheme.Font
				BoxBG.Text = ""
				BoxBG.TextColor3 = Scheme.FontColor
				BoxBG.TextSize = 12.000 
                AddOutline(BoxBG, 3) 
				
				BoxBGC.CornerRadius = UDim.new(0, 3) 
				BoxBGC.Name = "BoxBGC"
				BoxBGC.Parent = BoxBG
				
				TextBox.Parent = BoxBG
				TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextBox.BackgroundTransparency = 1.000
				TextBox.BorderSizePixel = 0
				TextBox.Size = UDim2.new(1, 0, 1, 0)
				TextBox.Font = Scheme.Font
				TextBox.Text = default
				TextBox.TextColor3 = Scheme.FontColor
				TextBox.PlaceholderColor3 = Scheme.PlaceholderColor
				TextBox.TextSize = 12.000 
				TextBox.TextTransparency = 0
				
				TextboxBackL.Name = "TextboxBackL"
				TextboxBackL.Parent = TextboxBack
				TextboxBackL.HorizontalAlignment = Enum.HorizontalAlignment.Right
				TextboxBackL.SortOrder = Enum.SortOrder.LayoutOrder
				TextboxBackL.VerticalAlignment = Enum.VerticalAlignment.Center
				
				TextboxBackP.Name = "TextboxBackP"
				TextboxBackP.Parent = TextboxBack
				TextboxBackP.PaddingRight = UDim.new(0, 5) 
				
				TextBox.FocusLost:Connect(function()
					if TextBox.Text == "" then
						TextBox.Text = default
					end
					library.flags[flag] = TextBox.Text
					callback(TextBox.Text)
				end)
				
				TextBox:GetPropertyChangedSignal("TextBounds"):Connect(function()
					BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 25, 0, 16) 
				end)
				
				BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 25, 0, 16) 
				
				UpdateSize()
			end
			
			function section.Slider(section, text, flag, default, min, max, precise, callback)
				local callback = callback or function() end
				local min = min or 1
				local max = max or 10
				local default = default or min
				local precise = precise or false
				library.flags[flag] = default
				assert(text, "No text provided")
				assert(flag, "No flag provided")
				assert(default, "No default value provided")
				
				local SliderModule = Instance.new("Frame")
				local SliderBack = Instance.new("TextButton")
				local SliderBackC = Instance.new("UICorner")
				local SliderBar = Instance.new("Frame")
				local SliderBarC = Instance.new("UICorner")
				local SliderPart = Instance.new("Frame")
				local SliderPartC = Instance.new("UICorner")
				local SliderValBG = Instance.new("TextButton")
				local SliderValBGC = Instance.new("UICorner")
				local SliderValue = Instance.new("TextBox")
				local MinSlider = Instance.new("TextButton")
				local AddSlider = Instance.new("TextButton")
				
				SliderModule.Name = "SliderModule"
				SliderModule.Parent = Objs
				SliderModule.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				SliderModule.BackgroundTransparency = 1.000
				SliderModule.BorderSizePixel = 0
				SliderModule.Position = UDim2.new(0, 0, 0, 0)
				SliderModule.Size = UDim2.new(0, 363, 0, 24) 
				
				SliderBack.Name = "SliderBack"
				SliderBack.Parent = SliderModule
				SliderBack.BackgroundColor3 = Scheme.MainColor
				SliderBack.BackgroundTransparency = 0
				SliderBack.BorderSizePixel = 0
				SliderBack.Size = UDim2.new(0, 363, 0, 24) 
				SliderBack.AutoButtonColor = false
				SliderBack.Font = Scheme.Font
				SliderBack.Text = "   " .. text
				SliderBack.TextColor3 = Scheme.FontColor
				SliderBack.TextSize = 12.000 
				SliderBack.TextTransparency = 0
				SliderBack.TextXAlignment = Enum.TextXAlignment.Left
                AddOutline(SliderBack, 3) 
				
				SliderBackC.CornerRadius = UDim.new(0, 3) 
				SliderBackC.Name = "SliderBackC"
				SliderBackC.Parent = SliderBack
				
				SliderBar.Name = "SliderBar"
				SliderBar.Parent = SliderBack
				SliderBar.AnchorPoint = Vector2.new(0, 0.5)
				SliderBar.BackgroundColor3 = Scheme.OutlineColor 
				SliderBar.BackgroundTransparency = 0
				SliderBar.BorderSizePixel = 0
				SliderBar.Position = UDim2.new(0.35, 30, 0.5, 0) 
				SliderBar.Size = UDim2.new(0, 110, 0, 6) 
				
				SliderBarC.CornerRadius = UDim.new(0, 3) 
				SliderBarC.Name = "SliderBarC"
				SliderBarC.Parent = SliderBar
				
				SliderPart.Name = "SliderPart"
				SliderPart.Parent = SliderBar
				SliderPart.BackgroundColor3 = Scheme.AccentColor 
				SliderPart.Size = UDim2.new(0, 42, 0, 6) 
				
				SliderPartC.CornerRadius = UDim.new(0, 3) 
				SliderPartC.Name = "SliderPartC"
				SliderPartC.Parent = SliderPart
				
				SliderValBG.Name = "SliderValBG"
				SliderValBG.Parent = SliderBack
				SliderValBG.BackgroundColor3 = Scheme.BackgroundColor
				SliderValBG.BackgroundTransparency = 0
				SliderValBG.BorderSizePixel = 0
				SliderValBG.Position = UDim2.new(0.85, 0, 0.5, -8) 
				SliderValBG.Size = UDim2.new(0, 36, 0, 16) 
				SliderValBG.AutoButtonColor = false
				SliderValBG.Font = Scheme.Font
				SliderValBG.Text = ""
				SliderValBG.TextColor3 = Scheme.FontColor
				SliderValBG.TextSize = 12.000 
                AddOutline(SliderValBG, 3) 
				
				SliderValBGC.CornerRadius = UDim.new(0, 3) 
				SliderValBGC.Name = "SliderValBGC"
				SliderValBGC.Parent = SliderValBG
				
				SliderValue.Name = "SliderValue"
				SliderValue.Parent = SliderValBG
				SliderValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				SliderValue.BackgroundTransparency = 1.000
				SliderValue.BorderSizePixel = 0
				SliderValue.Size = UDim2.new(1, 0, 1, 0)
				SliderValue.Font = Scheme.Font
				SliderValue.Text = "1000"
				SliderValue.TextColor3 = Scheme.FontColor
				SliderValue.TextSize = 12.000 
				SliderValue.TextTransparency = 0
				
				MinSlider.Name = "MinSlider"
				MinSlider.Parent = SliderModule
				MinSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				MinSlider.BackgroundTransparency = 1.000
				MinSlider.BorderSizePixel = 0
				MinSlider.Position = UDim2.new(0.27, 30, 0.5, -8) 
				MinSlider.Size = UDim2.new(0, 16, 0, 16) 
				MinSlider.Font = Scheme.Font
				MinSlider.Text = "-"
				MinSlider.TextColor3 = Scheme.FontColor
				MinSlider.TextSize = 14.000 
				MinSlider.TextTransparency = 0
				MinSlider.TextWrapped = true
				
				AddSlider.Name = "AddSlider"
				AddSlider.Parent = SliderModule
				AddSlider.AnchorPoint = Vector2.new(0, 0.5)
				AddSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				AddSlider.BackgroundTransparency = 1.000
				AddSlider.BorderSizePixel = 0
				AddSlider.Position = UDim2.new(0.78, 0, 0.5, 0) 
				AddSlider.Size = UDim2.new(0, 16, 0, 16) 
				AddSlider.Font = Scheme.Font
				AddSlider.Text = "+"
				AddSlider.TextColor3 = Scheme.FontColor
				AddSlider.TextSize = 14.000 
				AddSlider.TextTransparency = 0
				AddSlider.TextWrapped = true
				
				local funcs = {
					SetValue = function(self, value)
						local percent = (mouse.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X
						if value then
							percent = (value - min) / (max - min)
						end
						percent = math.clamp(percent, 0, 1)
						if precise then
							value = value or tonumber(string.format("%.1f", tostring(min + (max - min) * percent)))
						else
							value = value or math.floor(min + (max - min) * percent)
						end
						library.flags[flag] = tonumber(value)
						SliderValue.Text = tostring(value)
						SliderPart.Size = UDim2.new(percent, 0, 1, 0)
						callback(tonumber(value))
					end,
				}
				
				MinSlider.MouseButton1Click:Connect(function()
					local currentValue = library.flags[flag]
					currentValue = math.clamp(currentValue - 1, min, max)
					funcs:SetValue(currentValue)
				end)
				
				AddSlider.MouseButton1Click:Connect(function()
					local currentValue = library.flags[flag]
					currentValue = math.clamp(currentValue + 1, min, max)
					funcs:SetValue(currentValue)
				end)
				
				funcs:SetValue(default)
				
				local dragging, boxFocused, allowed = false, false, { [""] = true, ["-"] = true }
				
				SliderBar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						funcs:SetValue()
						dragging = true
					end
				end)
				
				services.UserInputService.InputEnded:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
				end)
				
				services.UserInputService.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
						funcs:SetValue()
					end
				end)
				
				SliderBar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.Touch then
						funcs:SetValue()
						dragging = true
					end
				end)
				
				services.UserInputService.InputEnded:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
					end
				end)
				
				services.UserInputService.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.Touch then
						funcs:SetValue()
					end
				end)
				
				SliderValue.Focused:Connect(function()
					boxFocused = true
				end)
				
				SliderValue.FocusLost:Connect(function()
					boxFocused = false
					if SliderValue.Text == "" then
						funcs:SetValue(default)
					end
				end)
				
				SliderValue:GetPropertyChangedSignal("Text"):Connect(function()
					if not boxFocused then
						return
					end
					SliderValue.Text = SliderValue.Text:gsub("%D+", "")
					local text = SliderValue.Text
					if not tonumber(text) then
						SliderValue.Text = SliderValue.Text:gsub("%D+", "")
					elseif not allowed[text] then
						if tonumber(text) > max then
							text = max
							SliderValue.Text = tostring(max)
						end
						funcs:SetValue(tonumber(text))
					end
				end)
				
				UpdateSize()
				return funcs
			end
			
			function section.Dropdown(section, text, flag, options, callback)
				local callback = callback or function() end
				local options = options or {}
				assert(text, "No text provided")
				assert(flag, "No flag provided")
				library.flags[flag] = nil
				
				local DropdownModule = Instance.new("Frame")
				local DropdownTop = Instance.new("TextButton")
				local DropdownTopC = Instance.new("UICorner")
				local DropdownOpen = Instance.new("TextButton")
				local DropdownText = Instance.new("TextBox")
				local DropdownModuleL = Instance.new("UIListLayout")
				local Option = Instance.new("TextButton")
				local OptionC = Instance.new("UICorner")
				
				DropdownModule.Name = "DropdownModule"
				DropdownModule.Parent = Objs
				DropdownModule.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				DropdownModule.BackgroundTransparency = 1.000
				DropdownModule.BorderSizePixel = 0
				DropdownModule.ClipsDescendants = true
				DropdownModule.Position = UDim2.new(0, 0, 0, 0)
				DropdownModule.Size = UDim2.new(0, 363, 0, 24) 
				
				DropdownTop.Name = "DropdownTop"
				DropdownTop.Parent = DropdownModule
				DropdownTop.BackgroundColor3 = Scheme.MainColor
				DropdownTop.BackgroundTransparency = 0
				DropdownTop.BorderSizePixel = 0
				DropdownTop.Size = UDim2.new(0, 363, 0, 24) 
				DropdownTop.AutoButtonColor = false
				DropdownTop.Font = Scheme.Font
				DropdownTop.Text = ""
				DropdownTop.TextColor3 = Scheme.FontColor
				DropdownTop.TextSize = 12.000 
				DropdownTop.TextXAlignment = Enum.TextXAlignment.Left
                AddOutline(DropdownTop, 3) 
				
				DropdownTopC.CornerRadius = UDim.new(0, 3) 
				DropdownTopC.Name = "DropdownTopC"
				DropdownTopC.Parent = DropdownTop
				
				DropdownOpen.Name = "DropdownOpen"
				DropdownOpen.Parent = DropdownTop
				DropdownOpen.AnchorPoint = Vector2.new(0, 0.5)
				DropdownOpen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				DropdownOpen.BackgroundTransparency = 1.000
				DropdownOpen.BorderSizePixel = 0
				DropdownOpen.Position = UDim2.new(0.9, 0, 0.5, 0) 
				DropdownOpen.Size = UDim2.new(0, 16, 0, 16) 
				DropdownOpen.Font = Scheme.Font
				DropdownOpen.Text = "+"
				DropdownOpen.TextColor3 = Scheme.FontColor
				DropdownOpen.TextSize = 14.000 
				DropdownOpen.TextTransparency = 0
				DropdownOpen.TextWrapped = true
				
				DropdownText.Name = "DropdownText"
				DropdownText.Parent = DropdownTop
				DropdownText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				DropdownText.BackgroundTransparency = 1.000
				DropdownText.BorderSizePixel = 0
				DropdownText.Position = UDim2.new(0.03, 0, 0, 0)
				DropdownText.Size = UDim2.new(0, 150, 0, 24) 
				DropdownText.Font = Scheme.Font
				DropdownText.PlaceholderColor3 = Scheme.PlaceholderColor
				DropdownText.PlaceholderText = text
				DropdownText.Text = ""
				DropdownText.TextColor3 = Scheme.FontColor
				DropdownText.TextSize = 12.000 
				DropdownText.TextTransparency = 0
				DropdownText.TextXAlignment = Enum.TextXAlignment.Left
				
				DropdownModuleL.Name = "DropdownModuleL"
				DropdownModuleL.Parent = DropdownModule
				DropdownModuleL.SortOrder = Enum.SortOrder.LayoutOrder
				DropdownModuleL.Padding = UDim.new(0, 3) 
				
				local setAllVisible = function()
					local options = DropdownModule:GetChildren()
					for i = 1, #options do
						local option = options[i]
						if option:IsA("TextButton") and option.Name:match("Option_") then
							option.Visible = true
						end
					end
				end
				
				local searchDropdown = function(text)
					local options = DropdownModule:GetChildren()
					for i = 1, #options do
						local option = options[i]
						if text == "" then
							setAllVisible()
						else
							if option:IsA("TextButton") and option.Name:match("Option_") then
								if option.Text:lower():match(text:lower()) then
									option.Visible = true
								else
									option.Visible = false
								end
							end
						end
					end
				end
				
				local open = false
				local ToggleDropVis = function()
					open = not open
					if open then
						setAllVisible()
					end
					DropdownOpen.Text = (open and "-" or "+")
					DropdownModule.Size =
						UDim2.new(0, 363, 0, (open and DropdownModuleL.AbsoluteContentSize.Y + 3 or 24)) 
                    
                    UpdateSize() 
				end
				
				DropdownOpen.MouseButton1Click:Connect(ToggleDropVis)
				
				DropdownText.Focused:Connect(function()
					if open then
						return
					end
					ToggleDropVis()
				end)
				
				DropdownText:GetPropertyChangedSignal("Text"):Connect(function()
					if not open then
						return
					end
					searchDropdown(DropdownText.Text)
				end)
				
				DropdownModuleL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					if not open then
						return
					end
					DropdownModule.Size = UDim2.new(0, 363, 0, (DropdownModuleL.AbsoluteContentSize.Y + 3)) 
                    UpdateSize() 
				end)
				
				local funcs = {}
				
				funcs.AddOption = function(self, option)
					local Option = Instance.new("TextButton")
					local OptionC = Instance.new("UICorner")
					
					Option.Name = "Option_" .. option
					Option.Parent = DropdownModule
					Option.BackgroundColor3 = Scheme.BackgroundColor 
					Option.BackgroundTransparency = 0
					Option.BorderSizePixel = 0
					Option.Position = UDim2.new(0, 0, 0.3, 0)
					Option.Size = UDim2.new(0, 363, 0, 20) 
					Option.AutoButtonColor = false
					Option.Font = Scheme.Font
					Option.Text = option
					Option.TextColor3 = Scheme.FontColor
					Option.TextSize = 12.000 
					Option.TextTransparency = 0
                    AddOutline(Option, 3) 
					
					OptionC.CornerRadius = UDim.new(0, 3) 
					OptionC.Name = "OptionC"
					OptionC.Parent = Option
					
					Option.MouseButton1Click:Connect(function()
						ToggleDropVis()
						callback(Option.Text)
						DropdownText.Text = Option.Text
						library.flags[flag] = Option.Text
					end)
				end
				
				funcs.RemoveOption = function(self, option)
					local option = DropdownModule:FindFirstChild("Option_" .. option)
					if option then
						option:Destroy()
					end
				end
				
				funcs.SetOptions = function(self, options)
					for _, v in next, DropdownModule:GetChildren() do
						if v.Name:match("Option_") then
							v:Destroy()
						end
					end
					for _, v in next, options do
						funcs:AddOption(v)
					end
				end
				
				funcs:SetOptions(options)
				
				UpdateSize()
				return funcs
			end
			
			return section
		end
		return tab
	end
	
	return window
end
return library