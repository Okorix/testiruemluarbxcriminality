local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/insanedude59/SplixUiLib/main/Main"))()
local ESPSettings = loadstring(game:HttpGet("https://raw.githubusercontent.com/Okorix/esplibrary/main/main.lua"))()

--// Cache

local select = select
local pcall, getgenv, next, Vector2, mathclamp, type, mousemoverel = select(1, pcall, getgenv, next, Vector2.new, math.clamp, type, mousemoverel or (Input and Input.MouseMove))

--// Preventing Multiple Processes

pcall(function()
	getgenv().Aimbot.Functions:Exit()
end)

--// Environment

getgenv().Aimbot = {}
local Environment = getgenv().Aimbot

--// Services

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Lighting = game.Lighting

--// Variables

local RequiredDistance, Typing, Running, Animation, ServiceConnections = 2000, false, false, nil, {}

--// Script Settings

Environment.Settings = {
	Enabled = true,
	TeamCheck = false,
	AliveCheck = true,
	WallCheck = false, -- Laggy
	Sensitivity = 0, -- Animation length (in seconds) before fully locking onto target
	ThirdPerson = false, -- Uses mousemoverel instead of CFrame to support locking in third person (could be choppy)
	ThirdPersonSensitivity = 3, -- Boundary: 0.1 - 5
	TriggerKey = "MouseButton2",
	Toggle = false,
	LockPart = "Head" -- Body part to lock on
}

Environment.FOVSettings = {
	Enabled = true,
	Visible = true,
	Amount = 90,
	Color = Color3.fromRGB(255, 255, 255),
	LockedColor = Color3.fromRGB(255, 70, 70),
	Transparency = 0.5,
	Sides = 60,
	Thickness = 1,
	Filled = false
}

Environment.FOVCircle = Drawing.new("Circle")

--// Functions

local function CancelLock()
	Environment.Locked = nil
	if Animation then Animation:Cancel() end
	Environment.FOVCircle.Color = Environment.FOVSettings.Color
end

local function GetClosestPlayer()
	if not Environment.Locked then
		RequiredDistance = (Environment.FOVSettings.Enabled and Environment.FOVSettings.Amount or 2000)

		for _, v in next, Players:GetPlayers() do
			if v ~= LocalPlayer then
				if v.Character and v.Character:FindFirstChild(Environment.Settings.LockPart) and v.Character:FindFirstChildOfClass("Humanoid") then
					if Environment.Settings.TeamCheck and v.Team == LocalPlayer.Team then continue end
					if Environment.Settings.AliveCheck and v.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then continue end
					if Environment.Settings.WallCheck and #(Camera:GetPartsObscuringTarget({v.Character[Environment.Settings.LockPart].Position}, v.Character:GetDescendants())) > 0 then continue end

					local Vector, OnScreen = Camera:WorldToViewportPoint(v.Character[Environment.Settings.LockPart].Position)
					local Distance = (Vector2(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2(Vector.X, Vector.Y)).Magnitude

					if Distance < RequiredDistance and OnScreen then
						RequiredDistance = Distance
						Environment.Locked = v
					end
				end
			end
		end
	elseif (Vector2(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2(Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position).X, Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position).Y)).Magnitude > RequiredDistance then
		CancelLock()
	end
end

--// Typing Check

ServiceConnections.TypingStartedConnection = UserInputService.TextBoxFocused:Connect(function()
	Typing = true
end)

ServiceConnections.TypingEndedConnection = UserInputService.TextBoxFocusReleased:Connect(function()
	Typing = false
end)

--// Main

local function Load()
	ServiceConnections.RenderSteppedConnection = RunService.RenderStepped:Connect(function()
		if Environment.FOVSettings.Enabled and Environment.Settings.Enabled then
			Environment.FOVCircle.Radius = Environment.FOVSettings.Amount
			Environment.FOVCircle.Thickness = Environment.FOVSettings.Thickness
			Environment.FOVCircle.Filled = Environment.FOVSettings.Filled
			Environment.FOVCircle.NumSides = Environment.FOVSettings.Sides
			Environment.FOVCircle.Color = Environment.FOVSettings.Color
			Environment.FOVCircle.Transparency = Environment.FOVSettings.Transparency
			Environment.FOVCircle.Visible = Environment.FOVSettings.Visible
			Environment.FOVCircle.Position = Vector2(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
		else
			Environment.FOVCircle.Visible = false
		end

		if Running and Environment.Settings.Enabled then
			GetClosestPlayer()

			if Environment.Locked then
				if Environment.Settings.ThirdPerson then
					Environment.Settings.ThirdPersonSensitivity = mathclamp(Environment.Settings.ThirdPersonSensitivity, 0.1, 5)

					local Vector = Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position)
					mousemoverel((Vector.X - UserInputService:GetMouseLocation().X) * Environment.Settings.ThirdPersonSensitivity, (Vector.Y - UserInputService:GetMouseLocation().Y) * Environment.Settings.ThirdPersonSensitivity)
				else
					if Environment.Settings.Sensitivity > 0 then
						Animation = TweenService:Create(Camera, TweenInfo.new(Environment.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, Environment.Locked.Character[Environment.Settings.LockPart].Position)})
						Animation:Play()
					else
						Camera.CFrame = CFrame.new(Camera.CFrame.Position, Environment.Locked.Character[Environment.Settings.LockPart].Position)
					end
				end

			Environment.FOVCircle.Color = Environment.FOVSettings.LockedColor

			end
		end
	end)

	ServiceConnections.InputBeganConnection = UserInputService.InputBegan:Connect(function(Input)
		if not Typing then
			pcall(function()
				if Input.KeyCode == Enum.KeyCode[Environment.Settings.TriggerKey] then
					if Environment.Settings.Toggle then
						Running = not Running

						if not Running then
							CancelLock()
						end
					else
						Running = true
					end
				end
			end)

			pcall(function()
				if Input.UserInputType == Enum.UserInputType[Environment.Settings.TriggerKey] then
					if Environment.Settings.Toggle then
						Running = not Running

						if not Running then
							CancelLock()
						end
					else
						Running = true
					end
				end
			end)
		end
	end)

	ServiceConnections.InputEndedConnection = UserInputService.InputEnded:Connect(function(Input)
		if not Typing then
			if not Environment.Settings.Toggle then
				pcall(function()
					if Input.KeyCode == Enum.KeyCode[Environment.Settings.TriggerKey] then
						Running = false; CancelLock()
					end
				end)

				pcall(function()
					if Input.UserInputType == Enum.UserInputType[Environment.Settings.TriggerKey] then
						Running = false; CancelLock()
					end
				end)
			end
		end
	end)
end

--// Functions

Environment.Functions = {}

function Environment.Functions:Exit()
	for _, v in next, ServiceConnections do
		v:Disconnect()
	end

	if Environment.FOVCircle.Remove then Environment.FOVCircle:Remove() end

	getgenv().Aimbot.Functions = nil
	getgenv().Aimbot = nil
	
	Load = nil; GetClosestPlayer = nil; CancelLock = nil
end

function Environment.Functions:Restart()
	for _, v in next, ServiceConnections do
		v:Disconnect()
	end

	Load()
end

function Environment.Functions:ResetSettings()
	Environment.Settings = {
		Enabled = true,
		TeamCheck = false,
		AliveCheck = true,
		WallCheck = false,
		Sensitivity = 0, -- Animation length (in seconds) before fully locking onto target
		ThirdPerson = false, -- Uses mousemoverel instead of CFrame to support locking in third person (could be choppy)
		ThirdPersonSensitivity = 3, -- Boundary: 0.1 - 5
		TriggerKey = "MouseButton2",
		Toggle = false,
		LockPart = "Head" -- Body part to lock on
	}

	Environment.FOVSettings = {
		Enabled = true,
		Visible = true,
		Amount = 90,
		Color = Color3.fromRGB(255, 255, 255),
		LockedColor = Color3.fromRGB(255, 70, 70),
		Transparency = 0.5,
		Sides = 60,
		Thickness = 1,
		Filled = false
	}
end

--// Load

Load()

getgenv().Aimbot.Settings.Enabled = false
getgenv().Aimbot.Settings.SaveSettings = false
getgenv().Aimbot.Settings.SendNotifications = false
getgenv().Aimbot.FOVSettings.Enabled = false
getgenv().Aimbot.FOVSettings.Visible = false

local Window = UILibrary:new({textsize = 13.5,font = Enum.Font.RobotoMono,name = "TESTIRUEM.LUA | CRIMINALITY",color = Color3.fromRGB(225,58,81)})

local VisualsTab = Window:page({name = "Visuals"})
local AimbotTab = Window:page({name = "Aimbot"})
local MiscTab = Window:page({name = "Misc"})

local PlayerSection = VisualsTab:section({name = "Player",side = "left",size = 300})
local AimbotSection = AimbotTab:section({name = "Aimbot",side = "left",size = 300})
local FOVSection = AimbotTab:section({name = "FOV",side = "right",size = 300})
local MiscSection = MiscTab:section({name = "Misc",side = "left",size = 300})

local LockpickHBEEnabled = false
local FullbrightEnabled = false
local InfiniteStaminaEnabled = false

PlayerSection:toggle({name = "Enabled",def = ESPSettings.Enabled,callback = function(Value)
    ESPSettings.Enabled = Value
end})

PlayerSection:toggle({name = "Box",def = ESPSettings.BoxVisible,callback = function(Value)
    ESPSettings.BoxVisible = Value
end})

PlayerSection:toggle({name = "Box outline",def = ESPSettings.BoxOutlineVisible,callback = function(Value)
    ESPSettings.BoxOutlineVisible = Value
end})

PlayerSection:colorpicker({name = "Box outline color",cpname = nil,def = ESPSettings.BoxOutlineColor,callback = function(Value)
   ESPSettings.BoxOutlineColor = Value
end})

PlayerSection:colorpicker({name = "Box color",cpname = nil,def = ESPSettings.BoxColor,callback = function(Value)
   ESPSettings.BoxColor = Value
end})

PlayerSection:toggle({name = "Name",def = ESPSettings.NameVisible,callback = function(Value)
    ESPSettings.NameVisible = Value
end})

PlayerSection:colorpicker({name = "Name color",cpname = nil,def = ESPSettings.NameColor,callback = function(Value)
   ESPSettings.NameColor = Value
end})

PlayerSection:slider({name = "Name size",def = ESPSettings.NameSize, max = 15,min = 1,rounding = true,ticking = false,measuring = "",callback = function(Value)
   ESPSettings.NameSize = Value
end})

PlayerSection:toggle({name = "Health bar",def = ESPSettings.HealthBarVisible,callback = function(Value)
    ESPSettings.HealthBarVisible = Value
end})

PlayerSection:toggle({name = "Health text",def = ESPSettings.HealthTextVisible,callback = function(Value)
    ESPSettings.HealthTextVisible = Value
end})

PlayerSection:toggle({name = "Current tool",def = ESPSettings.CurrentToolTextVisible,callback = function(Value)
    ESPSettings.CurrentToolTextVisible = Value
end})

PlayerSection:keybind({name = "UI Keybind",def = Window.key,callback = function(Key)
   Window.key = Key
end})

AimbotSection:toggle({name = "Enabled",def = Environment.Settings.Enabled,callback = function(Value)
    Environment.Settings.Enabled = Value
end})

AimbotSection:toggle({name = "Team check",def = Environment.Settings.TeamCheck,callback = function(Value)
    Environment.Settings.TeamCheck = Value
end})

AimbotSection:toggle({name = "Alive check",def = Environment.Settings.AliveCheck,callback = function(Value)
    Environment.Settings.AliveCheck = Value
end})

AimbotSection:toggle({name = "Wall check (laggy)",def = Environment.Settings.WallCheck,callback = function(Value)
    Environment.Settings.WallCheck = Value
end})

AimbotSection:slider({name = "Sensitivity",def = Environment.Settings.Sensitivity, max = 5,min = 0,rounding = false,ticking = false,measuring = "",callback = function(Value)
   Environment.Settings.Sensitivity = Value
end})

AimbotSection:keybind({name = "Trigger keybind",def = nil,callback = function(Key)
    local Name
    if typeof(Key) == "Instance" then
        Name = Key.UserInputType.Name
    else
        Name = Key.Name
    end
    Environment.Settings.TriggerKey = Name
end})

AimbotSection:toggle({name = "Toggle instead of hold",def = Environment.Settings.Toggle,callback = function(Value)
    Environment.Settings.Toggle = Value
end})

FOVSection:toggle({name = "Enabled",def = Environment.FOVSettings.Enabled,callback = function(Value)
    Environment.FOVSettings.Enabled = Value
end})

FOVSection:toggle({name = "Visible",def = Environment.FOVSettings.Visible,callback = function(Value)
    Environment.FOVSettings.Visible = Value
end})

FOVSection:slider({name = "Radius",def = Environment.FOVSettings.Amount, max = 1000,min = 1,rounding = false,ticking = false,measuring = "",callback = function(Value)
   Environment.FOVSettings.Amount = Value
end})

FOVSection:colorpicker({name = "Color",cpname = nil,def = Environment.FOVSettings.Color,callback = function(Value)
   Environment.FOVSettings.Color = Value
end})

FOVSection:colorpicker({name = "Locked color",cpname = nil,def = Environment.FOVSettings.LockedColor,callback = function(Value)
   Environment.FOVSettings.LockedColor = Value
end})

FOVSection:slider({name = "Transparency",def = Environment.FOVSettings.Transparency, max = 1,min = 0,rounding = false,ticking = false,measuring = "",callback = function(Value)
   Environment.FOVSettings.Transparency = Value
end})

FOVSection:slider({name = "Sides",def = Environment.FOVSettings.Sides, max = 280,min = 30,rounding = true,ticking = false,measuring = "",callback = function(Value)
   Environment.FOVSettings.Sides = Value
end})

FOVSection:slider({name = "Thickness",def = Environment.FOVSettings.Thickness, max = 1,min = 0,rounding = false,ticking = false,measuring = "",callback = function(Value)
   Environment.FOVSettings.Thickness = Value
end})

FOVSection:toggle({name = "Filled",def = Environment.FOVSettings.Filled,callback = function(Value)
    Environment.FOVSettings.Filled = Value
end})

MiscSection:toggle({name = "Lockpick HBE",def = LockpickHBEEnabled,callback = function(Value)
    LockpickHBEEnabled = Value
end})

MiscSection:toggle({name = "Fullbright",def = FullbrightEnabled,callback = function(Value)
    FullbrightEnabled = Value
end})

local InfStaminaObjects = {}

MiscSection:toggle({name = "Infinite stamina",def = InfiniteStaminaEnabled,callback = function(Value)
    InfiniteStaminaEnabled = Value
    if InfiniteStaminaEnabled == true then
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local CharStats = ReplicatedStorage.CharStats
        if CharStats then
            local PlayerCharStats = CharStats:FindFirstChild(LocalPlayer.Name)
            if PlayerCharStats then
                local Currents = PlayerCharStats:FindFirstChild("Currents")
                if Currents then
                    local BV1 = Instance.new("BoolValue", Currents)
                    BV1.Name = string.reverse("81493.2")
                    table.insert(InfStaminaObjects, BV1)
                end
            end
        end
    else
        for _,InfStaminaObject in pairs(InfStaminaObjects) do
            InfStaminaObject:Destroy()
        end
    end
end})

local OldFOVIdk = workspace.CurrentCamera.FieldOfView
MiscSection:slider({name = "FOV",def = workspace.CurrentCamera.FieldOfView, max = 360,min = 1,rounding = true,ticking = true,measuring = "",callback = function(Value)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local CharStats = ReplicatedStorage.CharStats
    if CharStats then
        local PlayerCharStats = CharStats:FindFirstChild(LocalPlayer.Name)
        if PlayerCharStats then
            local FOVsFolder = PlayerCharStats:FindFirstChild("FOVs")
            if FOVsFolder then
                for _,FovValue in pairs(FOVsFolder:GetChildren()) do
                    FovValue.Value = math.max(Value - OldFOVIdk, 0)
                end
            end
        end
    end
end})

PlayerGui.ChildAdded:Connect(function(Child)
    if Child.Name ~= "LockpickGUI" then
        return
    end

    local Location = Child.MF.LP_Frame.Frames
    if LockpickHBEEnabled == true then
        for i = 1, 3 do
            local Bar = Location["B"..i].Bar
            Bar.Size = UDim2.new(0, 35, 0, 500)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if FullbrightEnabled == true then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end

end)
