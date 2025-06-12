local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- UI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "DoughOverlay"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local background = Instance.new("Frame")
background.Size = UDim2.new(1, 0, 1, 0)
background.Position = UDim2.new(0, 0, 0, 0)
background.BackgroundColor3 = Color3.new(0, 0, 0)
background.BackgroundTransparency = 0.4
background.Visible = true
background.Parent = gui

local topText = Instance.new("TextLabel")
topText.Size = UDim2.new(1, 0, 0.1, 0)
topText.Position = UDim2.new(0, 0, 0, 0)
topText.BackgroundTransparency = 1
topText.Text = getgenv().BFInfoTopText or "Blox Fruits Info UI"
topText.TextColor3 = Color3.fromRGB(255, 255, 255)
topText.TextScaled = true
topText.Font = Enum.Font.FredokaOne
topText.Parent = background

local timeLabel = Instance.new("TextLabel")
timeLabel.Size = UDim2.new(1, 0, 0.04, 0)
timeLabel.Position = UDim2.new(0, 0, 0.84, 0)
timeLabel.BackgroundTransparency = 1
timeLabel.Text = "Time: 0 Hours 0 Minutes 0 Seconds"
timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timeLabel.TextScaled = true
timeLabel.Font = Enum.Font.FredokaOne
timeLabel.Parent = background

local logo = Instance.new("ImageLabel")
logo.Size = UDim2.new(0, 200, 0, 200)
logo.Position = UDim2.new(0.5, -100, 0.4, -100)
logo.BackgroundTransparency = 1
logo.Image = getgenv().BFInfoLogoId or "rbxassetid://119836305527028"
logo.Parent = background

local infoLabel1 = Instance.new("TextLabel")
infoLabel1.Size = UDim2.new(0.95, 0, 0.05, 0)
infoLabel1.Position = UDim2.new(0.025, 0, 0.89, 0)
infoLabel1.BackgroundTransparency = 1
infoLabel1.TextColor3 = Color3.new(1, 1, 1)
infoLabel1.TextScaled = true
infoLabel1.Font = Enum.Font.FredokaOne
infoLabel1.RichText = true
infoLabel1.Text = "Loading..."
infoLabel1.Parent = background

local infoLabel2 = infoLabel1:Clone()
infoLabel2.Position = UDim2.new(0.025, 0, 0.935, 0)
infoLabel2.Text = ""
infoLabel2.Parent = background

-- Toggle
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 120, 0, 40)
toggleButton.Position = UDim2.new(0, 15, 0, 70)
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.BackgroundTransparency = 0.1
toggleButton.BorderSizePixel = 0
toggleButton.Text = "Close"
toggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.GothamSemibold
toggleButton.Parent = gui
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 12)

local isOpen = true
toggleButton.MouseButton1Click:Connect(function()
	isOpen = not isOpen
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local targetPos = isOpen and UDim2.new(0, 0, 0, 0) or UDim2.new(0, 0, -1, 0)
	TweenService:Create(background, tweenInfo, {Position = targetPos}):Play()
	toggleButton.Text = isOpen and "Close" or "Open"
end)

-- Time counter
local startTime = tick()
RunService.RenderStepped:Connect(function()
	local total = math.floor(tick() - startTime)
	local hrs = math.floor(total / 3600)
	local mins = math.floor((total % 3600) / 60)
	local secs = total % 60
	timeLabel.Text = "Time: " .. hrs .. " Hours " .. mins .. " Minutes " .. secs .. " Seconds"
end)

-- Tween helper
local function tweenValue(start, goal, duration, callback)
	local current = start
	local t = 0
	local id = "Tween_" .. tostring(math.random())
	RunService:BindToRenderStep(id, Enum.RenderPriority.First.Value, function(dt)
		t += dt
		local alpha = math.clamp(t / duration, 0, 1)
		current = math.floor(start + (goal - start) * alpha)
		callback(current)
		if alpha >= 1 then
			RunService:UnbindFromRenderStep(id)
		end
	end)
end

-- Get Race chuẩn theo Character (V1 -> V4)
local function getRaceInfo()
	local raceName = "Unknown"
	local raceVersion = "V1"

	local data = player:FindFirstChild("Data")
	if data and data:FindFirstChild("Race") then
		raceName = data.Race.Value
	end

	local char = player.Character or player.CharacterAdded:Wait()
	if char:FindFirstChild("RaceV4Button") then
		raceVersion = "V4"
	elseif char:FindFirstChild("RaceAbility") or char:FindFirstChild("RaceV3Auras") then
		raceVersion = "V3"
	elseif char:FindFirstChild("RaceTransform") then
		raceVersion = "V2"
	end

	return raceName .. " " .. raceVersion
end

-- Cập nhật UI liên tục
local prevLevel, prevBeli, prevFrag = 0, 0, 0
task.spawn(function()
	while task.wait(1) do
		pcall(function()
			local level = player.Data.Level.Value
			local beli = player.Data.Beli.Value
			local frag = player.Data.Fragments.Value
			local race = getRaceInfo()

			local fullName = player.Name
			local shortName = string.sub(fullName, 1, 6)
			local hidden = string.rep("*", math.max(0, #fullName - 6))

			tweenValue(prevLevel, level, 0.8, function(valL)
				tweenValue(prevBeli, beli, 0.8, function(valB)
					tweenValue(prevFrag, frag, 0.8, function(valF)
						infoLabel1.Text = string.format(
							"<font color='rgb(255,255,255)'>Player: %s%s</font> | " ..
							"<font color='rgb(255,255,0)'>Level: %s</font>",
							shortName, hidden, valL
						)
						infoLabel2.Text = string.format(
							"<font color='rgb(0,255,0)'>Beli: %s</font> | " ..
							"<font color='rgb(255,0,255)'>Fragments: %s</font> | " ..
							"<font color='rgb(0,153,255)'>Race: %s</font>",
							valB, valF, race
						)
					end)
				end)
			end)

			prevLevel, prevBeli, prevFrag = level, beli, frag
		end)
	end
end)

-- Update lại Race khi nhân vật hồi sinh
player.CharacterAdded:Connect(function()
	task.wait(1)
	local race = getRaceInfo()
	local info = infoLabel2.Text
	infoLabel2.Text = info:gsub("Race: .-$", "Race: " .. race)
end)

-- Music
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://127343237333461"
sound.Looped = true
sound.Volume = 1
sound.Parent = workspace
sound:Play()
