Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/ghastlytim/LinoriaLib/main/linorialibedited.lua'))();

local LocalPlayer = game.Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Fonts = {};
for Font, _ in next, Drawing.Fonts do
	table.insert(Fonts, Font);
end;

local TestWindow = Library:CreateWindow('InkWare');
Library:SetWatermark('Inkwaretest');
Library:Notify('Loading Inkware');
wait(1)

local LegitTab = TestWindow:AddTab('Combat');
local LegitTabbox1 = LegitTab:AddLeftTabbox('Silent');

local lAimbot2 = LegitTabbox1:AddTab('Silent Aim');
lAimbot2:AddToggle('Saim_Enabled', { Text = 'Enable Silentaim' })

local lAimbot1 = LegitTabbox1:AddTab('Fov');
lAimbot1:AddToggle('Fov_Enabled', { Text = 'Enable fov' }):AddColorPicker('Fov_Color', { Default = Library.AccentColor });
lAimbot1:AddToggle('Fov_filled', { Text = 'Fov Filled' });
lAimbot1:AddSlider('Fov_Radius', { Text = 'Fov Radius', Default = 0, Min = 0, Max = 300, Rounding = 0, Suffix = '' });

local SettingsTab = TestWindow:AddTab('Settings');

local function UpdateTheme()
    Library.BackgroundColor = Flags.BackgroundColor.Value;
    Library.MainColor = Flags.MainColor.Value;
    Library.AccentColor = Flags.AccentColor.Value;
    Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor);
    Library.OutlineColor = Flags.OutlineColor.Value;
    Library.FontColor = Flags.FontColor.Value;

    Library:UpdateColorsUsingRegistry();
end;

local function SetDefault()
    Flags.FontColor:SetValueRGB(Color3.fromRGB(255, 255, 255));
    Flags.MainColor:SetValueRGB(Color3.fromRGB(28, 28, 28));
    Flags.BackgroundColor:SetValueRGB(Color3.fromRGB(20, 20, 20));
    Flags.AccentColor:SetValueRGB(Color3.fromRGB(0, 85, 255));
    Flags.OutlineColor:SetValueRGB(Color3.fromRGB(50, 50, 50));
    Flags.Rainbow:SetValue(false);

    UpdateTheme();
end;

local Theme = SettingsTab:AddLeftGroupbox('Theme');
Theme:AddLabel('Background Color'):AddColorPicker('BackgroundColor', { Default = Library.BackgroundColor });
Theme:AddLabel('Main Color'):AddColorPicker('MainColor', { Default = Library.MainColor });
Theme:AddLabel('Accent Color'):AddColorPicker('AccentColor', { Default = Library.AccentColor });
Theme:AddToggle('Rainbow', { Text = 'Rainbow Accent Color' });
Theme:AddLabel('Outline Color'):AddColorPicker('OutlineColor', { Default = Library.OutlineColor });
Theme:AddLabel('Font Color'):AddColorPicker('FontColor', { Default = Library.FontColor });
Theme:AddButton('Default Theme', SetDefault);
Theme:AddToggle('Keybinds', { Text = 'Show Keybinds Menu', Default = true }):OnChanged(function()
    Library.KeybindFrame.Visible = Flags.Keybinds.Value;
end);
Theme:AddToggle('Watermark', { Text = 'Show Watermark', Default = true }):OnChanged(function()
    Library:SetWatermarkVisibility(Flags.Watermark.Value);
end);

task.spawn(function()
    while game:GetService('RunService').RenderStepped:Wait() do
        if Flags.Rainbow.Value then
            local Registry = TestWindow.Holder.Visible and Library.Registry or Library.HudRegistry;

            for Idx, Object in next, Registry do
                for Property, ColorIdx in next, Object.Properties do
                    if ColorIdx == 'AccentColor' or ColorIdx == 'AccentColorDark' then
                        local Instance = Object.Instance;
                        local yPos = Instance.AbsolutePosition.Y;

                        local Mapped = Library:MapValue(yPos, 0, 1080, 0, 0.5) * 1.5;
                        local Color = Color3.fromHSV((Library.CurrentRainbowHue - Mapped) % 1, 0.8, 1);

                        if ColorIdx == 'AccentColorDark' then
                            Color = Library:GetDarkerColor(Color);
                        end;

                        Instance[Property] = Color;
                    end;
                end;
            end;
        end;
    end;
end);

Flags.Rainbow:OnChanged(function()
    if not Flags.Rainbow.Value then
        UpdateTheme();
    end;
end);

Flags.BackgroundColor:OnChanged(UpdateTheme);
Flags.MainColor:OnChanged(UpdateTheme);
Flags.AccentColor:OnChanged(UpdateTheme);
Flags.OutlineColor:OnChanged(UpdateTheme);
Flags.FontColor:OnChanged(UpdateTheme);

Library:Notify('Loaded UI!');

--quick example on using flags

local fovcircle = Drawing.new("Circle")
game:GetService("RunService").RenderStepped:Connect(function()
    fovcircle.Visible = Flags.Fov_Enabled.Value
fovcircle.Thickness = 1
fovcircle.Color = Flags.Fov_Color.Value
fovcircle.NumSides = 90
fovcircle.Radius = Flags.Fov_Radius.Value
fovcircle.Filled = Flags.Fov_filled.Value
fovcircle.Position = Vector2.new(Mouse.X, Mouse.Y)
end)

-// Services

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Shortcuts

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--// Variables

local OldNameCall = nil


--// Functions

local function GetClosestPlayer()
	local MaximumDistance = math.huge
	local Target

	local Thread = coroutine.wrap(function()
		wait(20)
		MaximumDistance = math.huge
	end)

	Thread()

	for _, v in next, Players:GetPlayers() do
		if v.Name ~= LocalPlayer.Name then
			if v.TeamColor ~= LocalPlayer.TeamColor then
				if workspace:FindFirstChild(v.Name) ~= nil then
					if workspace[v.Name]:FindFirstChild("HumanoidRootPart") ~= nil then
						if workspace[v.Name]:FindFirstChild("Humanoid") ~= nil and workspace[v.Name]:FindFirstChild("Humanoid").Health ~= 0 then
							local ScreenPoint = Camera:WorldToScreenPoint(workspace[v.Name]:WaitForChild("HumanoidRootPart", math.huge).Position)
							local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
							
							if VectorDistance < MaximumDistance and VectorDistance < Flags.Fov_Radius.Value then
								Target = v
								MaximumDistance = VectorDistance
							end
						end
					end
				end
			end
		end
	end

	return Target
end

--// Silent Aim

OldNameCall = hookmetamethod(game, "__namecall", function(Self, ...)
	local NameCallMethod = getnamecallmethod()
	local Arguments = {...}

	if not checkcaller() and tostring(Self) == "HitPart" and tostring(NameCallMethod) == "FireServer" then
		if Flags.Saim_Enabled.Value == true then
			Arguments[1] = GetClosestPlayer().Character.Hitbox
		end

		return Self.FireServer(Self, unpack(Arguments))
	elseif not checkcaller() and tostring(Self) == "Trail" and tostring(NameCallMethod) == "FireServer" then
		if Flags.Saim_Enabled.Value == true then
			if type(Arguments[1][5]) == "string" then
				Arguments[1][6] = GetClosestPlayer().Character.Hitbox
				Arguments[1][2] = GetClosestPlayer().Character.Hitbox.Position
			end
		end

		return Self.FireServer(Self, unpack(Arguments))
	elseif not checkcaller() and tostring(Self) == "CreateProjectile" and tostring(NameCallMethod) == "FireServer" then	
		if Flags.Saim_Enabled.Value == true then
			Arguments[18] = GetClosestPlayer().Character.Hitbox
			Arguments[19] = GetClosestPlayer().Character.Hitbox.Position
			Arguments[17] = GetClosestPlayer().Character.Hitbox.Position
			Arguments[4] = GetClosestPlayer().Character.Hitbox.CFrame
			Arguments[10] = GetClosestPlayer().Character.Hitbox.Position
			Arguments[3] = GetClosestPlayer().Character.Hitbox.Position
		end

		return Self.FireServer(Self, unpack(Arguments))
	elseif not checkcaller() and tostring(Self) == "Flames" and tostring(NameCallMethod) == "FireServer" then -- DOESNT WORK
		if Flags.Saim_Enabled.Value == true then
			Arguments[1] = GetClosestPlayer().Character.Hitbox.CFrame
			Arguments[2] = GetClosestPlayer().Character.Hitbox.Position
			Arguments[5] = GetClosestPlayer().Character.Hitbox.Position
		end

		return Self.FireServer(Self, unpack(Arguments))
	elseif not checkcaller() and tostring(Self) == "Fire" and tostring(NameCallMethod) == "FireServer" then
		if Flags.Saim_Enabled.Value == true then
			Arguments[1] = GetClosestPlayer().Character.Hitbox.Position
		end

		return Self.FireServer(Self, unpack(Arguments))
	elseif not checkcaller() and tostring(Self) == "ReplicateProjectile" and tostring(NameCallMethod) == "FireServer" then
		if Flags.Saim_Enabled.Value == true then
			Arguments[1][3] = GetClosestPlayer().Character.Hitbox.Position
			Arguments[1][4] = GetClosestPlayer().Character.Hitbox.Position
			Arguments[1][10] = GetClosestPlayer().Character.Hitbox.Position
		end

		return Self.FireServer(Self, unpack(Arguments))
	elseif not checkcaller() and tostring(Self) == "RemoteEvent" and tostring(NameCallMethod) == "FireServer" then
		if Flags.Saim_Enabled.Value == true then
			if Arguments[1][1] == "createparticle" and Arguments[1][2] == "muzzle" then
				if Arguments[3] == LocalPlayer.Character.Gun then
					if ReplicatedStorage.Weapons(LocalPlayer.Character.Gun.Boop.Value).Melee then
						local KnifeArguments1 = {
							[1] = "createparticle",
							[2] = "bullethole",
							[3] = GetClosestPlayer().Character.Hitbox,
							[4] = GetClosestPlayer().Character.Hitbox.Position,
							[5] = Vector3.new(0, 0, 0),
							[6] = ReplicatedStorage.Weapons:FindFirstChild(LocalPlayer.Character.Gun.Boop.Value),
							[7] = false,
							[8] = GetClosestPlayer().Character.Hitbox.Position,
							[9] = true,
							[12] = LocalPlayer,
							[13] = 1
						}
						
						local KnifeArguments = {
							GetClosestPlayer().Character.Hitbox,
							GetClosestPlayer().Character.Hitbox.Position,
							ReplicatedStorage.Weapons:FindFirstChild(LocalPlayer.Character.EquippedTool.Value).Name,
							1,
							5,
							false,
							false,
							false,
							1,
							false,
							ReplicatedStorage.Weapons:FindFirstChild(LocalPlayer.Character.EquippedTool.Value).FireRate.Value,
							ReplicatedStorage.Weapons:FindFirstChild(LocalPlayer.Character.EquippedTool.Value).ReloadTime.Value,
							ReplicatedStorage.Weapons:FindFirstChild(LocalPlayer.Character.EquippedTool.Value).Ammo.Value,
							ReplicatedStorage.Weapons:FindFirstChild(LocalPlayer.Character.EquippedTool.Value).StoredAmmo.Value,
							ReplicatedStorage.Weapons:FindFirstChild(LocalPlayer.Character.EquippedTool.Value).Bullets.Value,
							ReplicatedStorage.Weapons:FindFirstChild(LocalPlayer.Character.EquippedTool.Value).EquipTime.Value,
							ReplicatedStorage.Weapons:FindFirstChild(LocalPlayer.Character.EquippedTool.Value).RecoilControl.Value,
							ReplicatedStorage.Weapons:FindFirstChild(LocalPlayer.Character.EquippedTool.Value).Auto.Value,
							ReplicatedStorage.Weapons:FindFirstChild(LocalPlayer.Character.EquippedTool.Value)["Speed%"].Value,
							ReplicatedStorage:WaitForChild("wkspc").DistributedTime.Value,
							215,
							1,
							false,
							true
						}

						ReplicatedStorage.Events.RemoteEvent:FireServer(KnifeArguments1)
						ReplicatedStorage.Events.HitPart:FireServer(unpack(KnifeArguments))
					end
				end
			end
		end

		return Self.FireServer(Self, unpack(Arguments))
	end

	return OldNameCall(Self, ...)
end)
