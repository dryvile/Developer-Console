--[[
	Console Module
]]

-- Roblox Services & Local Player References
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Common Locals
local Main, Lib, Apps, Settings -- Main Containers
local Explorer, Properties, ScriptViewer, Notebook -- Major Apps
local API, RMD, env, service, plr, create, createSimple -- Main Locals

local function initDeps(data)
	Main = data.Main
	Lib = data.Lib
	Apps = data.Apps
	Settings = data.Settings

	API = data.API
	RMD = data.RMD
	env = data.env
	service = data.service
	plr = data.plr
	create = data.create
	createSimple = data.createSimple
end

local function initAfterMain()
	Explorer = Apps.Explorer
	Properties = Apps.Properties
	ScriptViewer = Apps.ScriptViewer
	Notebook = Apps.Notebook
end

local function main()
	local Console = {}
	local window, ConsoleFrame

	local OutputLimit = 500 -- Same as Roblox Console.

	-- Window Setup
	window = Lib.Window.new()
	window:SetTitle("Console")
	window:Resize(500, 400)
	Console.Window = window

	-- Console Frame Container
	ConsoleFrame = Instance.new("ImageButton")
	ConsoleFrame.Name = "Console"
	ConsoleFrame.Parent = window.GuiElems.Content
	ConsoleFrame.BorderSizePixel = 0
	ConsoleFrame.AutoButtonColor = false
	ConsoleFrame.BackgroundTransparency = 1
	ConsoleFrame.BackgroundColor3 = Color3.fromRGB(47, 47, 47)
	ConsoleFrame.Selectable = false
	ConsoleFrame.Size = UDim2.new(1, 0, 1, 0)
	ConsoleFrame.Position = UDim2.new(0, 0, 0, 0)
	ConsoleFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)

	-- Command Line Frame
	local commandLine = Lib.Frame.new().Gui
	commandLine.Name = "CommandLine"
	commandLine.Parent = ConsoleFrame
	commandLine.BorderSizePixel = 0
	commandLine.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
	commandLine.AnchorPoint = Vector2.new(0.5, 1)
	commandLine.ClipsDescendants = true
	commandLine.Size = UDim2.new(1, -8, 0, 22)
	commandLine.Position = UDim2.new(0.5, 0, 1, -5)
	commandLine.BorderColor3 = Color3.fromRGB(0, 0, 0)

	local commandLineStroke = Instance.new("UIStroke")
	commandLineStroke.Parent = commandLine
	commandLineStroke.Transparency = 0.65
	commandLineStroke.Thickness = 1.25

	local commandLineScroll = Instance.new("ScrollingFrame")
	commandLineScroll.Parent = commandLine
	commandLineScroll.Active = true
	commandLineScroll.ScrollingDirection = Enum.ScrollingDirection.X
	commandLineScroll.BorderSizePixel = 0
	commandLineScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	commandLineScroll.ElasticBehavior = Enum.ElasticBehavior.Never
	commandLineScroll.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
	commandLineScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	commandLineScroll.HorizontalScrollBarInset = Enum.ScrollBarInset.Always
	commandLineScroll.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
	commandLineScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
	commandLineScroll.Size = UDim2.new(1, 0, 1, 0)
	commandLineScroll.ScrollBarImageColor3 = Color3.fromRGB(57, 57, 57)
	commandLineScroll.BorderColor3 = Color3.fromRGB(0, 0, 0)
	commandLineScroll.ScrollBarThickness = 2
	commandLineScroll.BackgroundTransparency = 1

	local commandLineInput = Instance.new("TextBox")
	commandLineInput.Parent = commandLineScroll
	commandLineInput.CursorPosition = -1
	commandLineInput.TextXAlignment = Enum.TextXAlignment.Left
	commandLineInput.PlaceholderColor3 = Color3.fromRGB(211, 211, 211)
	commandLineInput.BorderSizePixel = 0
	commandLineInput.TextSize = 13
	commandLineInput.TextColor3 = Color3.fromRGB(211, 211, 211)
	commandLineInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	commandLineInput.FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	commandLineInput.AutomaticSize = Enum.AutomaticSize.X
	commandLineInput.ClearTextOnFocus = false
	commandLineInput.PlaceholderText = "Run a command"
	commandLineInput.Size = UDim2.new(0, 246, 0, 22)
	commandLineInput.BorderColor3 = Color3.fromRGB(0, 0, 0)
	commandLineInput.Text = ""
	commandLineInput.BackgroundTransparency = 1

	local commandLinePadding = Instance.new("UIPadding")
	commandLinePadding.Parent = commandLineInput
	commandLinePadding.PaddingLeft = UDim.new(0, 7)

	local commandLineHighlight = Instance.new("TextLabel")
	commandLineHighlight.Name = "Highlight"
	commandLineHighlight.Parent = commandLineScroll
	commandLineHighlight.Interactable = false
	commandLineHighlight.ZIndex = 2
	commandLineHighlight.BorderSizePixel = 0
	commandLineHighlight.TextSize = 13
	commandLineHighlight.TextXAlignment = Enum.TextXAlignment.Left
	commandLineHighlight.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	commandLineHighlight.FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	commandLineHighlight.TextColor3 = Color3.fromRGB(255, 255, 255)
	commandLineHighlight.BackgroundTransparency = 1
	commandLineHighlight.RichText = true
	commandLineHighlight.Size = UDim2.new(0, 246, 0, 22)
	commandLineHighlight.BorderColor3 = Color3.fromRGB(0, 0, 0)
	commandLineHighlight.Text = ""
	commandLineHighlight.Selectable = true
	commandLineHighlight.AutomaticSize = Enum.AutomaticSize.X

	local highlightPadding = Instance.new("UIPadding")
	highlightPadding.Parent = commandLineHighlight
	highlightPadding.PaddingLeft = UDim.new(0, 7)

	-- Background Output
	local backgroundOutput = Instance.new("Frame")
	backgroundOutput.Name = "BackgroundOutput"
	backgroundOutput.Parent = ConsoleFrame
	backgroundOutput.BorderSizePixel = 0
	backgroundOutput.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
	backgroundOutput.AnchorPoint = Vector2.new(0, 0)
	backgroundOutput.Size = UDim2.new(1, -8, 1, -55)
	backgroundOutput.Position = UDim2.new(0, 4, 0, 23)
	backgroundOutput.BorderColor3 = Color3.fromRGB(0, 0, 0)
	backgroundOutput.ZIndex = 1

	-- Custom ScrollBar
	local scrollbar = Lib.ScrollBar.new()
	scrollbar.Gui.Parent = ConsoleFrame
	scrollbar.Gui.Size = UDim2.new(0, 16, 1, -55)
	scrollbar.Gui.Position = UDim2.new(1, -20, 0, 23)
	scrollbar.Gui.Up.ZIndex = 3
	scrollbar.Gui.Down.ZIndex = 3

	-- Output Frame
	local outputFrame = Instance.new("ScrollingFrame")
	outputFrame.Name = "Output"
	outputFrame.Parent = ConsoleFrame
	outputFrame.Active = true
	outputFrame.BorderSizePixel = 0
	outputFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	outputFrame.TopImage = ""
	outputFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
	outputFrame.BackgroundTransparency = 1
	outputFrame.ScrollBarImageTransparency = 0
	outputFrame.BottomImage = ""
	outputFrame.AnchorPoint = Vector2.new(0, 0)
	outputFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	outputFrame.Size = UDim2.new(1, -8, 1, -55)
	outputFrame.Position = UDim2.new(0, 4, 0, 23)
	outputFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	outputFrame.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70)
	outputFrame.ScrollBarThickness = 16
	outputFrame.ZIndex = 1

	outputFrame:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
		if outputFrame.AbsoluteCanvasSize ~= outputFrame.AbsoluteWindowSize then
			scrollbar.Gui.Visible = true
		else
			scrollbar.Gui.Visible = false
		end
	end)

	local outputListLayout = Instance.new("UIListLayout")
	outputListLayout.Parent = outputFrame
	outputListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local outputStroke = Instance.new("UIStroke")
	outputStroke.Parent = outputFrame
	outputStroke.Transparency = 0.7
	outputStroke.Thickness = 1.25
	outputStroke.Color = Color3.fromRGB(12, 12, 12)

	local outputTextSizeVal = Instance.new("NumberValue")
	outputTextSizeVal.Name = "OutputTextSize"
	outputTextSizeVal.Value = 15
	outputTextSizeVal.Parent = outputFrame

	local outputLimitVal = Instance.new("NumberValue")
	outputLimitVal.Name = "OutputLimit"
	outputLimitVal.Value = OutputLimit
	outputLimitVal.Parent = outputFrame

	local outputPadding = Instance.new("UIPadding")
	outputPadding.Parent = outputFrame
	outputPadding.PaddingTop = UDim.new(0, 2)

	-- Text Size Box
	local textSizeBox = Instance.new("Frame")
	textSizeBox.Name = "TextSizeBox"
	textSizeBox.Parent = ConsoleFrame
	textSizeBox.BorderSizePixel = 0
	textSizeBox.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
	textSizeBox.ClipsDescendants = true
	textSizeBox.Size = UDim2.new(0, 37, 0, 15)
	textSizeBox.Position = UDim2.new(0, 4, 0, 4)
	textSizeBox.BorderColor3 = Color3.fromRGB(0, 0, 0)

	local textSizeInput = Instance.new("TextBox")
	textSizeInput.Parent = textSizeBox
	textSizeInput.PlaceholderColor3 = Color3.fromRGB(108, 108, 108)
	textSizeInput.BorderSizePixel = 0
	textSizeInput.TextWrapped = true
	textSizeInput.TextSize = 15
	textSizeInput.TextColor3 = Color3.fromRGB(211, 211, 211)
	textSizeInput.TextScaled = true
	textSizeInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	textSizeInput.FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	textSizeInput.PlaceholderText = "Size"
	textSizeInput.Size = UDim2.new(1, 0, 1, 0)
	textSizeInput.BorderColor3 = Color3.fromRGB(0, 0, 0)
	textSizeInput.Text = ""
	textSizeInput.BackgroundTransparency = 1

	local textSizePadding = Instance.new("UIPadding")
	textSizePadding.Parent = textSizeInput
	textSizePadding.PaddingTop = UDim.new(0, 2)
	textSizePadding.PaddingRight = UDim.new(0, 5)
	textSizePadding.PaddingLeft = UDim.new(0, 5)
	textSizePadding.PaddingBottom = UDim.new(0, 2)

	local textSizeStroke = Instance.new("UIStroke")
	textSizeStroke.Parent = textSizeBox
	textSizeStroke.Transparency = 0.65
	textSizeStroke.Thickness = 1.25

	-- Clear Button
	local clearBtn = Instance.new("ImageButton")
	clearBtn.Name = "Clear"
	clearBtn.Parent = ConsoleFrame
	clearBtn.BorderSizePixel = 0
	clearBtn.BackgroundColor3 = Color3.fromRGB(57, 57, 57)
	clearBtn.Size = UDim2.new(0, 37, 0, 15)
	clearBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
	clearBtn.Position = UDim2.new(1, -42, 0, 4)

	local clearLabel = Instance.new("TextLabel")
	clearLabel.Parent = clearBtn
	clearLabel.TextWrapped = true
	clearLabel.Interactable = false
	clearLabel.BorderSizePixel = 0
	clearLabel.TextSize = 20
	clearLabel.TextScaled = true
	clearLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	clearLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	clearLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	clearLabel.BackgroundTransparency = 1
	clearLabel.Size = UDim2.new(1, 0, 1, 0)
	clearLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	clearLabel.Text = "Clear"

	local clearPadding = Instance.new("UIPadding")
	clearPadding.Parent = clearBtn
	clearPadding.PaddingTop = UDim.new(0, 1)
	clearPadding.PaddingBottom = UDim.new(0, 1)

	-- Output Template
	local outputTemplate = Instance.new("TextBox")
	outputTemplate.Name = "OutputTemplate"
	outputTemplate.Parent = ConsoleFrame
	outputTemplate.Visible = false
	outputTemplate.Active = false
	outputTemplate.TextXAlignment = Enum.TextXAlignment.Left
	outputTemplate.BorderSizePixel = 0
	outputTemplate.TextEditable = false
	outputTemplate.TextWrapped = true
	outputTemplate.TextSize = 15
	outputTemplate.TextColor3 = Color3.fromRGB(171, 171, 171)
	outputTemplate.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	outputTemplate.RichText = true
	outputTemplate.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	outputTemplate.AutomaticSize = Enum.AutomaticSize.Y
	outputTemplate.Selectable = false
	outputTemplate.ClearTextOnFocus = false
	outputTemplate.Size = UDim2.new(1, 0, 0, 1)
	outputTemplate.Position = UDim2.new(0, 20, 0, 0)
	outputTemplate.BorderColor3 = Color3.fromRGB(0, 0, 0)
	outputTemplate.Text = '(timestamp) <font color="rgb(255, 255, 255)">Output</font>'
	outputTemplate.BackgroundTransparency = 1

	local templatePadding = Instance.new("UIPadding")
	templatePadding.Parent = outputTemplate
	templatePadding.PaddingRight = UDim.new(0, 6)
	templatePadding.PaddingLeft = UDim.new(0, 6)

	-- CtrlScroll Button
	local ctrlScrollBtn = Instance.new("ImageButton")
	ctrlScrollBtn.Name = "CtrlScroll"
	ctrlScrollBtn.Parent = ConsoleFrame
	ctrlScrollBtn.BorderSizePixel = 0
	ctrlScrollBtn.BackgroundColor3 = Color3.fromRGB(57, 57, 57)
	ctrlScrollBtn.Size = UDim2.new(0, 60, 0, 15)
	ctrlScrollBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ctrlScrollBtn.Position = UDim2.new(0, 46, 0, 4)

	local ctrlScrollLabel = Instance.new("TextLabel")
	ctrlScrollLabel.Parent = ctrlScrollBtn
	ctrlScrollLabel.TextWrapped = true
	ctrlScrollLabel.Interactable = false
	ctrlScrollLabel.BorderSizePixel = 0
	ctrlScrollLabel.TextSize = 20
	ctrlScrollLabel.TextScaled = true
	ctrlScrollLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ctrlScrollLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	ctrlScrollLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	ctrlScrollLabel.BackgroundTransparency = 1
	ctrlScrollLabel.Size = UDim2.new(1, 0, 1, 0)
	ctrlScrollLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ctrlScrollLabel.Text = "Ctrl Scroll"

	local ctrlScrollPadding = Instance.new("UIPadding")
	ctrlScrollPadding.Parent = ctrlScrollBtn
	ctrlScrollPadding.PaddingTop = UDim.new(0, 1)
	ctrlScrollPadding.PaddingBottom = UDim.new(0, 1)

	-- AutoScroll Button
	local autoScrollBtn = Instance.new("ImageButton")
	autoScrollBtn.Name = "AutoScroll"
	autoScrollBtn.Parent = ConsoleFrame
	autoScrollBtn.BorderSizePixel = 0
	autoScrollBtn.BackgroundColor3 = Color3.fromRGB(57, 57, 57)
	autoScrollBtn.Size = UDim2.new(0, 60, 0, 15)
	autoScrollBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
	autoScrollBtn.Position = UDim2.new(0, 110, 0, 4)

	local autoScrollLabel = Instance.new("TextLabel")
	autoScrollLabel.Parent = autoScrollBtn
	autoScrollLabel.TextWrapped = true
	autoScrollLabel.Interactable = false
	autoScrollLabel.BorderSizePixel = 0
	autoScrollLabel.TextSize = 20
	autoScrollLabel.TextScaled = true
	autoScrollLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	autoScrollLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	autoScrollLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	autoScrollLabel.BackgroundTransparency = 1
	autoScrollLabel.Size = UDim2.new(1, 0, 1, 0)
	autoScrollLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	autoScrollLabel.Text = "Auto Scroll"

	local autoScrollPadding = Instance.new("UIPadding")
	autoScrollPadding.Parent = autoScrollBtn
	autoScrollPadding.PaddingTop = UDim.new(0, 1)
	autoScrollPadding.PaddingBottom = UDim.new(0, 1)

	-- Embedded Syntax Highlighter Module
	local syntaxHighlighter = {}
	local keywords = {
		lua = {
			"and", "break", "or", "else", "elseif", "if", "then", "until", "repeat", "while", "do", "for", "in", "end",
			"local", "return", "function", "export"
		},
		rbx = {
			"game", "workspace", "script", "math", "string", "table", "task", "wait", "select", "next", "Enum",
			"error", "warn", "tick", "assert", "shared", "loadstring", "tonumber", "tostring", "type",
			"typeof", "unpack", "print", "Instance", "CFrame", "Vector3", "Vector2", "Color3", "UDim", "UDim2", "Ray", "BrickColor",
			"OverlapParams", "RaycastParams", "Axes", "Random", "Region3", "Rect", "TweenInfo",
			"collectgarbage", "not", "utf8", "pcall", "xpcall", "_G", "setmetatable", "getmetatable", "os", "pairs", "ipairs"
		},
		exploit = {
			"hookmetamethod", "hookfunction", "getgc", "filtergc", "Drawing", "getgenv", "getsenv", "getrenv", "getfenv", "setfenv",
			"decompile", "saveinstance", "getrawmetatable", "setrawmetatable", "checkcaller", "cloneref", "clonefunction",
			"iscclosure", "islclosure", "isexecutorclosure", "newcclosure", "getfunctionhash", "crypt", "writefile", "appendfile", "loadfile", "readfile", "listfiles",
			"makefolder", "isfolder", "isfile", "delfile", "delfolder", "getcustomasset", "fireclickdetector", "firetouchinterest", "fireproximityprompt"
		},
		operators = {
			"#", "+", "-", "*", "%", "/", "^", "=", "~", "=", "<", ">", ",", ".", "(", ")", "{", "}", "[", "]", ";", ":"
		}
	}

	local colors = {
		numbers = Color3.fromRGB(255, 198, 0),
		boolean = Color3.fromRGB(255, 198, 0),
		operator = Color3.fromRGB(204, 204, 204),
		lua = Color3.fromRGB(132, 214, 247),
		exploit = Color3.fromRGB(171, 84, 247),
		rbx = Color3.fromRGB(248, 109, 124),
		str = Color3.fromRGB(173, 241, 132),
		comment = Color3.fromRGB(102, 102, 102),
		null = Color3.fromRGB(255, 198, 0),
		call = Color3.fromRGB(253, 251, 172),
		self_call = Color3.fromRGB(253, 251, 172),
		local_color = Color3.fromRGB(248, 109, 115),
		function_color = Color3.fromRGB(248, 109, 115),
		self_color = Color3.fromRGB(248, 109, 115),
		local_property = Color3.fromRGB(97, 161, 241),
	}

	local function createKeywordSet(kwList)
		local set = {}
		for _, kw in ipairs(kwList) do
			set[kw] = true
		end
		return set
	end

	local luaSet = createKeywordSet(keywords.lua)
	local exploitSet = createKeywordSet(keywords.exploit)
	local rbxSet = createKeywordSet(keywords.rbx)
	local operatorsSet = createKeywordSet(keywords.operators)

	local function getHighlight(tokens, index)
		local token = tokens[index]

		if colors[token .. "_color"] then
			return colors[token .. "_color"]
		end

		if tonumber(token) then
			return colors.numbers
		elseif token == "nil" then
			return colors.null
		elseif token:sub(1, 2) == "--" then
			return colors.comment
		elseif operatorsSet[token] then
			return colors.operator
		elseif luaSet[token] then
			return colors.rbx
		elseif rbxSet[token] then
			return colors.lua
		elseif exploitSet[token] then
			return colors.exploit
		elseif token:sub(1, 1) == "\"" or token:sub(1, 1) == "\'" then
			return colors.str
		elseif token == "true" or token == "false" then
			return colors.boolean
		end

		if tokens[index + 1] == "(" then
			if tokens[index - 1] == ":" then
				return colors.self_call
			end
			return colors.call
		end

		if tokens[index - 1] == "." then
			if tokens[index - 2] == "Enum" then
				return colors.rbx
			end
			return colors.local_property
		end
	end

	function syntaxHighlighter.run(source)
		local tokens = {}
		local currentToken = ""

		local inString = false
		local inComment = false
		local commentPersist = false

		for i = 1, #source do
			local character = source:sub(i, i)

			if inComment then
				if character == "\n" and not commentPersist then
					table.insert(tokens, currentToken)
					table.insert(tokens, character)
					currentToken = ""
					inComment = false
				elseif source:sub(i - 1, i) == "]]" and commentPersist then
					currentToken ..= "]"
					table.insert(tokens, currentToken)
					currentToken = ""
					inComment = false
					commentPersist = false
				else
					currentToken = currentToken .. character
				end
			elseif inString then
				if (character == inString and source:sub(i - 1, i - 1) ~= "\\") or character == "\n" then
					currentToken = currentToken .. character
					inString = false
				else
					currentToken = currentToken .. character
				end
			else
				if source:sub(i, i + 1) == "--" then
					table.insert(tokens, currentToken)
					currentToken = "-"
					inComment = true
					commentPersist = source:sub(i + 2, i + 3) == "[["
				elseif character == "\"" or character == "\'" then
					table.insert(tokens, currentToken)
					currentToken = character
					inString = character
				elseif operatorsSet[character] then
					table.insert(tokens, currentToken)
					table.insert(tokens, character)
					currentToken = ""
				elseif character:match("[%w_]") then
					currentToken = currentToken .. character
				else
					table.insert(tokens, currentToken)
					table.insert(tokens, character)
					currentToken = ""
				end
			end
		end

		table.insert(tokens, currentToken)

		local highlighted = {}

		for i, token in ipairs(tokens) do
			local highlight = getHighlight(tokens, i)

			if highlight then
				local syntax = string.format('<font color="#%s">%s</font>', highlight:ToHex(), token:gsub("<", "&lt;"):gsub(">", "&gt;"))
				table.insert(highlighted, syntax)
			else
				table.insert(highlighted, token)
			end
		end

		return table.concat(highlighted)
	end

	-- Initialization logic
	Console.Init = function()
		local CtrlScroll = false
		local AutoScroll = false

		local LogService = game:GetService("LogService")
		local LocalPlayer = player
		local Mouse = LocalPlayer:GetMouse()
		local UserInputService = game:GetService("UserInputService")
		local RunService = game:GetService("RunService")

		local OutputTextSize = outputTextSizeVal

		local function Tween(obj, info, prop)
			local tween = game:GetService("TweenService"):Create(obj, info, prop)
			tween:Play()
			return tween
		end

		-- Ctrl Scroll Button Logic
		if CtrlScroll == true then
			ctrlScrollBtn.BackgroundColor3 = Color3.fromRGB(11, 90, 175)
		else
			ctrlScrollBtn.BackgroundColor3 = Color3.fromRGB(56, 56, 56)
		end
		ctrlScrollBtn.MouseButton1Click:Connect(function()
			CtrlScroll = not CtrlScroll
			if CtrlScroll == true then
				ctrlScrollBtn.BackgroundColor3 = Color3.fromRGB(11, 90, 175)
			else
				ctrlScrollBtn.BackgroundColor3 = Color3.fromRGB(56, 56, 56)
			end
		end)

		local IsHoldingCTRL = false
		UserInputService.InputBegan:Connect(function(input, gameproc)
			if not gameproc then
				if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
					IsHoldingCTRL = true
				end
			end
		end)
		UserInputService.InputEnded:Connect(function(input, gameproc)
			if not gameproc then
				if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
					IsHoldingCTRL = false
				end
			end
		end)

		-- Auto Scroll Button Logic
		if AutoScroll == true then
			autoScrollBtn.BackgroundColor3 = Color3.fromRGB(11, 90, 175)
		else
			autoScrollBtn.BackgroundColor3 = Color3.fromRGB(56, 56, 56)
		end
		autoScrollBtn.MouseButton1Click:Connect(function()
			AutoScroll = not AutoScroll
			if AutoScroll == true then
				autoScrollBtn.BackgroundColor3 = Color3.fromRGB(11, 90, 175)
				outputFrame.CanvasPosition = Vector2.new(0, 9e9)
			else
				autoScrollBtn.BackgroundColor3 = Color3.fromRGB(56, 56, 56)
			end
		end)

		-- Console Text Size Input Logic
		local displayedOutput = {}

		textSizeInput.Text = tostring(OutputTextSize.Value)

		textSizeInput:GetPropertyChangedSignal("Text"):Connect(function()
			local tonum = tonumber(textSizeInput.Text)
			if tonum then
				OutputTextSize.Value = tonum
			end
		end)
		OutputTextSize:GetPropertyChangedSignal("Value"):Connect(function()
			textSizeInput.Text = tostring(OutputTextSize.Value)
		end)

		local scrollConsoleInput
		outputFrame.MouseEnter:Connect(function()
			scrollConsoleInput = UserInputService.InputChanged:Connect(function(input)
				if CtrlScroll and input.UserInputType == Enum.UserInputType.MouseWheel and IsHoldingCTRL == true then
					outputFrame.ScrollingEnabled = false
					local newTextSize = OutputTextSize.Value + input.Position.Z
					if newTextSize >= 1 then
						OutputTextSize.Value = newTextSize
					end
				else
					outputFrame.ScrollingEnabled = true
				end
			end)
		end)
		outputFrame.MouseLeave:Connect(function()
			if scrollConsoleInput then
				scrollConsoleInput:Disconnect()
				scrollConsoleInput = nil
			end
		end)

		clearBtn.MouseButton1Click:Connect(function()
			for _, log in pairs(outputFrame:GetChildren()) do
				if log:IsA("TextBox") then
					log:Destroy()
				end
			end
		end)

		local focussedOutput

		LogService.MessageOut:Connect(function(msg, msgtype)
			local formattedText = ""
			local unformattedText = ""
			local newOutputText = outputTemplate:Clone()
			table.insert(displayedOutput, newOutputText)

			if #displayedOutput > outputLimitVal.Value then
				local oldest = table.remove(displayedOutput, 1)
				if oldest and typeof(oldest) == "Instance" then
					oldest:Destroy()
				end
			end

			unformattedText = os.date("%H:%M:%S") .. "   " .. msg
			if msgtype == Enum.MessageType.MessageOutput then
				formattedText = os.date("%H:%M:%S") .. '   <font color="rgb(204, 204, 204)">' .. msg .. "</font>"
				newOutputText.Text = formattedText
			elseif msgtype == Enum.MessageType.MessageWarning then
				formattedText = os.date("%H:%M:%S") .. '   <b><font color="rgb(255, 142, 60)">' .. msg .. "</font></b>"
				newOutputText.Text = formattedText
			elseif msgtype == Enum.MessageType.MessageError then
				formattedText = os.date("%H:%M:%S") .. '   <b><font color="rgb(255, 68, 68)">' .. msg .. "</font></b>"
				newOutputText.Text = formattedText
			elseif msgtype == Enum.MessageType.MessageInfo then
				formattedText = os.date("%H:%M:%S") .. '   <font color="rgb(128, 215, 255)">' .. msg .. "</font>"
				newOutputText.Text = formattedText
			end

			newOutputText.TextSize = OutputTextSize.Value
			OutputTextSize:GetPropertyChangedSignal("Value"):Connect(function()
				newOutputText.TextSize = OutputTextSize.Value
			end)

			newOutputText.Focused:Connect(function()
				focussedOutput = newOutputText
				newOutputText.Text = unformattedText
			end)
			newOutputText.FocusLost:Connect(function()
				focussedOutput = nil
				newOutputText.Text = formattedText
			end)

			newOutputText.Parent = outputFrame
			newOutputText.Visible = true

			if AutoScroll then
				outputFrame.CanvasPosition = Vector2.new(0, 9e9)
			end
		end)

		outputFrame.MouseLeave:Connect(function()
			if focussedOutput then
				focussedOutput:ReleaseFocus()
			end
		end)

		commandLineInput:GetPropertyChangedSignal("Text"):Connect(function()
			local oneliner = string.gsub(commandLineInput.Text, "\n", "    ")
			commandLineInput.Text = oneliner

			commandLineHighlight.Text = syntaxHighlighter.run(commandLineInput.Text)
		end)

		commandLineInput.FocusLost:Connect(function(enterPressed)
			if enterPressed and commandLineInput.Text ~= "" then
				print("> " .. commandLineInput.Text)
				loadstring(commandLineInput.Text)()
			end
		end)
	end

	return Console
end

return { InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main }
