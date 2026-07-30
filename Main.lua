local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ToggleMenuGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Create Main Frame
local frame = Instance.new("Frame")
frame.Name = "Frame"
frame.Size = UDim2.new(0, 280, 0, 42)
frame.Position = UDim2.new(0.5, -140, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame.BackgroundTransparency = 0
frame.BorderColor3 = Color3.fromRGB(27, 42, 53)
frame.BorderMode = Enum.BorderMode.Outline
frame.BorderSizePixel = 1
frame.Style = Enum.FrameStyle.DropShadow
frame.ZIndex = 4
frame.Interactable = true
frame.Parent = screenGui

-- Title Label
local label = Instance.new("TextLabel")
label.Name = "Label"
label.Size = UDim2.new(1, -65, 1, 0)
label.Position = UDim2.new(0, 12, 0, 0)
label.BackgroundTransparency = 1
label.Text = "Auto Destroy Car"
label.TextColor3 = Color3.fromRGB(235, 235, 235)
label.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
label.TextScaled = false
label.TextSize = 12
label.TextStrokeColor3 = Color3.fromRGB(60, 60, 60)
label.TextStrokeTransparency = 0
label.TextStrokeTransparency = 0
label.TextTransparency = 0
label.TextWrap = true
label.TextWrapped = true
label.TextXAlignment = Enum.TextXAlignment.Left
label.ZIndex = 5
label.Parent = frame

-- Toggle Switch Background Frame
local toggleFrame = Instance.new("Frame")
toggleFrame.Name = "ToggleFrame"
toggleFrame.Size = UDim2.new(0, 44, 0, 22)
toggleFrame.Position = UDim2.new(1, -54, 0.5, -11)
toggleFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggleFrame.BackgroundTransparency = 0
toggleFrame.BorderColor3 = Color3.fromRGB(27, 42, 53)
toggleFrame.BorderMode = Enum.BorderMode.Outline
toggleFrame.BorderSizePixel = 1
toggleFrame.Style = Enum.FrameStyle.DropShadow
toggleFrame.ZIndex = 5
toggleFrame.Interactable = true
toggleFrame.Parent = frame

-- Toggle Knob
local knob = Instance.new("Frame")
knob.Name = "Knob"
knob.Size = UDim2.new(0, 16, 0, 16)
knob.Position = UDim2.new(0, -3, 0.5, -8)
knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
knob.BackgroundTransparency = 0
knob.BorderColor3 = Color3.fromRGB(27, 42, 53)
knob.BorderMode = Enum.BorderMode.Outline
knob.BorderSizePixel = 1
knob.Style = Enum.FrameStyle.DropShadow
knob.ZIndex = 5
knob.Interactable = true
knob.Parent = toggleFrame

-- Expanded Clickable TextButton overlay
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Size = UDim2.new(1, 16, 1, 16)
toggleBtn.Position = UDim2.new(0, -8, 0, -8)
toggleBtn.BackgroundTransparency = 1
toggleBtn.Text = ""
toggleBtn.AutoButtonColor = false
toggleBtn.ZIndex = 7
toggleBtn.Parent = toggleFrame

-- State & Loop Logic
local isToggled = false

local function isCarDestroyed()
	local carCollection = Workspace:FindFirstChild("CarCollection")
	if not carCollection then return true end

	local userFolder = carCollection:FindFirstChild(player.Name)
	if not userFolder then return true end

	local car = userFolder:FindFirstChild("Car")
	if not car then return true end

	local hasParts = car:FindFirstChildWhichIsA("BasePart", true) ~= nil
	return not hasParts
end

local function findRespawnElements()
	local respawnGui = playerGui:FindFirstChild("Respawn", true) or playerGui:FindFirstChild("RespawnGui", true)
	if not respawnGui then return nil, nil end

	local targetBtn = respawnGui:FindFirstChild("Button", true) or respawnGui:FindFirstChildWhichIsA("TextButton", true) or respawnGui:FindFirstChildWhichIsA("ImageButton", true)
	local cooldownLabel = respawnGui:FindFirstChild("Cooldown", true) or respawnGui:FindFirstChild("Timer", true) or respawnGui:FindFirstChildWhichIsA("TextLabel", true)

	return targetBtn, cooldownLabel
end

local function clickGuiButton(button)
	if not button then return end

	-- Firesignal execution
	if firesignal then
		pcall(function() firesignal(button.Activated) end)
		pcall(function() firesignal(button.MouseButton1Click) end)
		pcall(function() firesignal(button.TouchTap) end)
	end

	-- Getconnections execution fallback
	if getconnections then
		for _, conn in pairs(getconnections(button.Activated)) do pcall(function() conn:Fire() end) end
		for _, conn in pairs(getconnections(button.MouseButton1Click)) do pcall(function() conn:Fire() end) end
		for _, conn in pairs(getconnections(button.TouchTap)) do pcall(function() conn:Fire() end) end
	end

	-- Virtual Touch Fallback
	local pos = button.AbsolutePosition
	local size = button.AbsoluteSize
	local x = pos.X + (size.X / 2)
	local y = pos.Y + (size.Y / 2) + 36

	pcall(function()
		VirtualInputManager:SendTouchEvent(1, Enum.UserInputState.Begin, x, y)
		task.wait(0.05)
		VirtualInputManager:SendTouchEvent(1, Enum.UserInputState.End, x, y)
	end)
end

local function runLoop()
	-- Loop 1: Transitions Deletion Loop
	task.spawn(function()
		while isToggled do
			local transitions = playerGui:FindFirstChild("Transitions", true) or Workspace:FindFirstChild("Transitions", true)
			if transitions then
				local blackscreen = transitions:FindFirstChild("Blackscreen")
				if blackscreen then
					blackscreen:Destroy()
				end

				local fadeBlackscreen = transitions:FindFirstChild("FadeBlackscreen")
				if fadeBlackscreen then
					fadeBlackscreen:Destroy()
				end
			end
			task.wait(0.1)
		end
	end)

	-- Loop 2: Dealership & Spawn Handler
	task.spawn(function()
		while isToggled do
			if isCarDestroyed() then
				-- Locate Dealership button dynamically or via path
				local dealership = nil
				local screen = playerGui:FindFirstChild("Screen")
				if screen then
					local topbar = screen:FindFirstChild("Topbar")
					local holder = topbar and topbar:FindFirstChild("Holder")
					local menu = holder and holder:FindFirstChild("menu")
					dealership = menu and menu:FindFirstChild("Dealership")
				end
				if not dealership then
					dealership = playerGui:FindFirstChild("Dealership", true)
				end

				if dealership and dealership:IsA("GuiButton") then
					clickGuiButton(dealership)
				end

				-- 3 Second Delay between pressing Dealership and Spawn
				task.wait(3)

				-- Check/click Respawn button if present and finished cooldown
				local targetBtn, cooldownLabel = findRespawnElements()
				if targetBtn then
					local isCooldownFinished = false
					if cooldownLabel and cooldownLabel:IsA("TextLabel") then
						local text = cooldownLabel.Text
						if text == "" or not string.match(text, "%d+") or not cooldownLabel.Visible then
							isCooldownFinished = true
						end
					else
						isCooldownFinished = true
					end

					if isCooldownFinished then
						clickGuiButton(targetBtn)
						task.wait(0.5)
					end
				end

				-- Locate and Activate Spawn Button
				local dealershipGui = playerGui:FindFirstChild("Dealership", true) or playerGui:WaitForChild("Dealership", 5)
				if dealershipGui then
					local spawnButton = dealershipGui:FindFirstChild("Spawn", true)
					if not spawnButton then
						local bottomBar = dealershipGui:FindFirstChild("BottomBar") or dealershipGui:WaitForChild("BottomBar", 2)
						local spawnHolder = bottomBar and (bottomBar:FindFirstChild("Holder") or bottomBar:WaitForChild("Holder", 2))
						spawnButton = spawnHolder and spawnHolder:FindFirstChild("Spawn")
					end

					task.wait(0.2)

					if spawnButton then
						clickGuiButton(spawnButton)
					end
				end

				-- Wait buffer to check if spawned
				task.wait(1.5)
			else
				task.wait(0.5)
			end
		end
	end)

	-- Loop 3: Car Velocity Loop
	task.spawn(function()
		while isToggled do
			-- Check if CarCollection exists in Workspace
			local carCollection = Workspace:FindFirstChild("CarCollection")

			if carCollection then
				-- Check if a folder/model named after the player exists inside CarCollection
				local userFolder = carCollection:FindFirstChild(player.Name)

				if userFolder then
					-- Check if there is an object named "Car" inside the player's folder
					local car = userFolder:FindFirstChild("Car")

					if car then
						-- Find the PrimaryPart or root part of the car model
						local rootPart = car.PrimaryPart or car:FindFirstChildWhichIsA("BasePart")

						if rootPart then
							-- Check if any valid BasePart still exists inside the car
							local hasParts = car:FindFirstChildWhichIsA("BasePart", true) ~= nil
							if not hasParts then
								break
							end

							-- Launch upward with extreme velocity
							if rootPart and rootPart.Parent then
								rootPart.AssemblyLinearVelocity = Vector3.new(rootPart.AssemblyLinearVelocity.X, 150, rootPart.AssemblyLinearVelocity.Z)
							end
							task.wait(0.08)

							-- Slam downward much harder with extreme velocity
							if rootPart and rootPart.Parent then
								rootPart.AssemblyLinearVelocity = Vector3.new(rootPart.AssemblyLinearVelocity.X, -300, rootPart.AssemblyLinearVelocity.Z)
							end
							task.wait(0.08)
						else
							task.wait(0.1)
						end
					else
						task.wait(0.1)
					end
				else
					task.wait(0.1)
				end
			else
				task.wait(0.1)
			end
		end
	end)
end

toggleBtn:GetAttributeChangedSignal("IsToggled"):Connect(function()
	isToggled = toggleBtn:GetAttribute("IsToggled") or false

	if isToggled then
		runLoop()
	end
end)

-- Tween Info for smooth animation
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Listen for clicks to switch state and animate knob further
toggleBtn.MouseButton1Click:Connect(function()
	local currentState = toggleBtn:GetAttribute("IsToggled") or false
	local newState = not currentState

	toggleBtn:SetAttribute("IsToggled", newState)

	local targetPosition = newState and UDim2.new(1, -13, 0.5, -8) or UDim2.new(0, -3, 0.5, -8)

	TweenService:Create(knob, tweenInfo, {
		Position = targetPosition
	}):Play()
end)
