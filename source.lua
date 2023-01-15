local self = {}
local userInputService = game:GetService("UserInputService")

self.openUiKey = Enum.KeyCode.PageUp
self.colorSets = {
	["blue"] = {
		["titleTab"] = Color3.fromRGB(18, 77, 93);
		["textColor"] = Color3.fromRGB(225, 225, 225);
		["background"] = Color3.fromRGB(20, 85, 103);
		["tabsFrame"] = Color3.fromRGB(15, 65, 76);
	};
}
self.activeColorSet = self.colorSets.blue
self.resizingFrame = false
getgenv().instance = math.random(-999999999, 999999999)
self.instance = getgenv().instance

function self:setColorSet(colorSet)
	self.activeColorSet = self.colorSets[colorSet]
end

function self:createUI(title)
	if game.CoreGui:FindFirstChild("customUiLibrary") then
		game.CoreGui.customUiLibrary:Destroy()
	end

	local newGui = Instance.new("ScreenGui", game.CoreGui)
	local backgroundDim = Instance.new("Frame", newGui)
	local frame = Instance.new("Frame", newGui)
	local titleTab = Instance.new("TextLabel", frame)
	local menuButton = Instance.new("ImageButton", titleTab)
	local tabsFrame = Instance.new("Frame", frame)
	local contentArea = Instance.new("Frame", frame)
	local resizeButton = Instance.new("Frame", frame)
	local dragArea = Instance.new("Frame", frame)
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
	Instance.new("UICorner", titleTab).CornerRadius = UDim.new(0, 4)
	Instance.new("UICorner", tabsFrame).CornerRadius = UDim.new(0, 4)
	Instance.new("UIListLayout", tabsFrame)

	newGui.Enabled = false
	newGui.Name = "customUiLibrary"
	newGui.IgnoreGuiInset = true

	backgroundDim.Size = UDim2.fromScale(1, 1)
	backgroundDim.BorderSizePixel = 0
	backgroundDim.BackgroundColor3 = Color3.new()
	backgroundDim.BackgroundTransparency = 0.7

	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.Size = UDim2.fromOffset(600, 300)
	frame.BackgroundColor3 = self.activeColorSet.background
	frame.ClipsDescendants = true

	titleTab.Size = UDim2.new(1, 0, 0, 15)
	titleTab.TextXAlignment = Enum.TextXAlignment.Left
	titleTab.TextSize = 14
	titleTab.FontFace = Font.new(tostring(Enum.Font.Ubuntu), Enum.FontWeight.Bold, Enum.FontStyle.Italic)
	titleTab.Text = "          "..title
	titleTab.BackgroundColor3 = self.activeColorSet.titleTab
	titleTab.TextColor3 = self.activeColorSet.textColor

	menuButton.Position = UDim2.fromOffset(2, 0)
	menuButton.Size = UDim2.fromOffset(15, 15)
	menuButton.BackgroundTransparency = 1
	menuButton.Image = "rbxassetid://2738273138"

	tabsFrame.Visible = false	
	tabsFrame.AnchorPoint = Vector2.new(0, 1)
	tabsFrame.Position = UDim2.fromScale(0, 1)
	tabsFrame.Size = UDim2.new(0, 125, 1, -15)
	tabsFrame.BackgroundColor3 = self.activeColorSet.tabsFrame
	tabsFrame.BackgroundTransparency = 0.45
	tabsFrame.ZIndex = 2

	contentArea.AnchorPoint = Vector2.new(0, 1)
	contentArea.Position = UDim2.fromScale(0, 1)
	contentArea.Size = UDim2.new(1, 0, 1, -15)
	contentArea.BackgroundTransparency = 1

	resizeButton.AnchorPoint = Vector2.new(1, 1)
	resizeButton.Size = UDim2.fromOffset(10, 10)
	resizeButton.BorderSizePixel = 0
	resizeButton.BackgroundColor3 = Color3.new()
	resizeButton.Position = UDim2.fromScale(1, 1)
	resizeButton.BackgroundTransparency = 0.8

	dragArea.BackgroundTransparency = 1
	dragArea.Size = UDim2.fromScale(1, 1)
	dragArea.ZIndex = 10

	pcall(function() getgenv().openUiConnection:Disconnect() end)
	getgenv().openUiConnection = userInputService.InputBegan:Connect(function(key)
		if key.KeyCode == self.openUiKey then
			newGui.Enabled = not newGui.Enabled
		end
	end)

	menuButton.MouseButton1Click:Connect(function()
		tabsFrame.Visible = not tabsFrame.Visible
	end)

	self:enableResize(resizeButton, frame)
	self:enableDrag(dragArea, frame)
	self.mainUI = newGui
	self.contentArea = contentArea
	self.tabsFrame = tabsFrame
end

function self:addNewTab(name, frame)
	local tabButton = Instance.new("TextButton", self.tabsFrame)

	tabButton.Size = UDim2.new(1, 0, 0, 25)
	tabButton.BackgroundTransparency = 1
	tabButton.TextColor3 = self.activeColorSet.textColor
	tabButton.Text = name
	tabButton.TextSize = 17
	tabButton.FontFace = Font.new(tostring(Enum.Font.Ubuntu), Enum.FontWeight.Regular, Enum.FontStyle.Italic)
	tabButton.ZIndex = 2

	tabButton.MouseButton1Click:Connect(function()
		if frame.Parent ~= self.contentArea then
			local frame = self.contentArea:FindFirstChildOfClass("Frame")
			local scrollingFrame = self.contentArea:FindFirstChildOfClass("ScrollingFrame")
			
			if frame then
				frame.Parent = nil
			elseif scrollingFrame then
				scrollingFrame.Parent = nil
			end
		end
		frame.Parent = (frame.Parent ~= self.contentArea) and self.contentArea or nil
	end)
end

function self:enableDrag(frame, parent)
	parent = parent or frame

	local dragging = false
	local dragInput, mousePos, framePos

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			mousePos = input.Position
			framePos = parent.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input == dragInput and dragging and not self.resizingFrame then
			local delta = input.Position - mousePos
			parent.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
		end
	end)
end

function self:enableResize(frame, parent)
	local mousePos
	local frameSizeX
	local frameSizeY

	parent = parent or frame

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local startLocation = userInputService:GetMouseLocation()

			self.resizingFrame = true
			mousePos = input.Position
			frameSizeX = parent.Size.X.Offset
			frameSizeY = parent.Size.Y.Offset

			spawn(function()
				while self.resizingFrame do
					task.wait()
					local delta = userInputService:GetMouseLocation() - Vector2.new(mousePos.X, mousePos.Y+36) -- gui inset
					parent.Size = UDim2.fromOffset(math.max(frameSizeX+delta.X, 10), math.max(frameSizeY+delta.Y, 10))
				end
			end)
		end
	end)

	frame.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.resizingFrame = false
		end
	end)
end
