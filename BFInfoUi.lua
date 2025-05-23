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
topText.Text = "Blox Fruits Info Ui"
topText.TextColor3 = Color3.fromRGB(255, 255, 255)
topText.TextScaled = true
topText.Font = Enum.Font.FredokaOne
topText.Parent = background

local timeLabel = Instance.new("TextLabel")
timeLabel.Size = UDim2.new(1, 0, 0.04, 0)
timeLabel.Position = UDim2.new(0, 0, 0.9, 0)
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
logo.Image = "rbxassetid://ID_IMAGE"
logo.Parent = background

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0.95, 0, 0.05, 0)
infoLabel.Position = UDim2.new(0.025, 0, 0.94, 0)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = Color3.new(1, 1, 1)
infoLabel.TextScaled = true
infoLabel.Font = Enum.Font.FredokaOne
infoLabel.RichText = true
infoLabel.Text = "Loading..."
infoLabel.Parent = background

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

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = toggleButton

-- Toggle Function
local isOpen = true
toggleButton.MouseButton1Click:Connect(function()
	isOpen = not isOpen
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local targetPos = isOpen and UDim2.new(0, 0, 0, 0) or UDim2.new(0, 0, -1, 0)
	TweenService:Create(background, tweenInfo, {Position = targetPos}):Play()
	toggleButton.Text = isOpen and "Close" or "Open"
end)

-- Time Counter
local seconds = 0
spawn(function()
	while wait(1) do
		seconds += 1
		local hrs = math.floor(seconds / 3600)
		local mins = math.floor((seconds % 3600) / 60)
		local secs = seconds % 60
		timeLabel.Text = "Time: " .. hrs .. " Hours " .. mins .. " Minutes " .. secs .. " Seconds"
	end
end)

-- Tween effect helper
local function tweenValue(start, goal, duration, callback)
	local current = start
	local t = 0
	RunService:BindToRenderStep("TweenInfoUpdater", Enum.RenderPriority.First.Value, function(dt)
		t += dt
		local alpha = math.clamp(t / duration, 0, 1)
		current = math.floor(start + (goal - start) * alpha)
		callback(current)
		if alpha >= 1 then
			RunService:UnbindFromRenderStep("TweenInfoUpdater")
		end
	end)
end

-- Info Updating with tween
local prevLevel, prevBeli, prevFrag = 0, 0, 0
spawn(function()
	while wait(1) do
		pcall(function()
			local level = player.Data.Level.Value
			local beli = player.Data.Beli.Value
			local frag = player.Data.Fragments.Value
			local fullName = player.Name
			local shortName = string.sub(fullName, 1, 6)
			local hidden = string.rep("*", math.max(0, #fullName - 6))

			tweenValue(prevLevel, level, 0.8, function(val)
				tweenValue(prevBeli, beli, 0.8, function(valB)
					tweenValue(prevFrag, frag, 0.8, function(valF)
						infoLabel.Text = string.format(
							"<font color='rgb(255,255,255)'>Player: %s%s</font> | " ..
							"<font color='rgb(255,255,0)'>Level: %s</font> | " ..
							"<font color='rgb(0,255,0)'>Beli: %s</font> | " ..
							"<font color='rgb(255,0,255)'>Fragments: %s</font>",
							shortName, hidden,
							val, valB, valF
						)
					end)
				end)
			end)

			prevLevel, prevBeli, prevFrag = level, beli, frag
		end)
	end
end)

-- Music on Execute
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://127343237333461"
sound.Looped = true
sound.Volume = 1
sound.Parent = workspace
sound:Play()
