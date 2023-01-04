local BanEvent = game:GetService("ReplicatedStorage"):WaitForChild("EasyAdmin").Ban
local TeleportEvent = game:GetService("ReplicatedStorage"):WaitForChild("EasyAdmin").Teleport
local ConfirmEvent = game:GetService("ReplicatedStorage"):WaitForChild("EasyAdmin").Confirm
local ResetEvent = game:GetService("ReplicatedStorage"):WaitForChild("EasyAdmin").Reset
local OfflineBanEvent = game:GetService("ReplicatedStorage"):WaitForChild("EasyAdmin").OfflineBan
local EntbanEvent = game:GetService("ReplicatedStorage"):WaitForChild("EasyAdmin").Unban
local ServerLock = game:GetService("ReplicatedStorage"):WaitForChild("EasyAdmin").ServerLock
local ServerAnnouncement = game:GetService("ReplicatedStorage"):WaitForChild("EasyAdmin").Announcement
local Warn = game:GetService("ReplicatedStorage"):WaitForChild("EasyAdmin").Warn
local Warnung = game:GetService("ReplicatedStorage"):WaitForChild("EasyAdmin").WarnFenster
local Announce = game:GetService("ReplicatedStorage"):WaitForChild("EasyAdmin").AnnounceFenster
local UnsichtbarEvent = game:GetService("ReplicatedStorage"):WaitForChild("EasyAdmin").Unsichtbar
local GodmodeEvent = game:GetService("ReplicatedStorage"):WaitForChild("EasyAdmin").Godmode

local CoreGui = game:GetService("StarterGui")
local dss 		= game:GetService("DataStoreService")
local TimedBans	= dss:GetDataStore("TimedBans")





game.Players.PlayerAdded:Connect(function(plr)
	
	-- SPIELZEIT
	local Folder = Instance.new("Folder", plr)
	Folder.Name = "Spielzeit"
	local TickSession = Instance.new("IntValue", Folder)
	TickSession.Name = "Spielzeit"
	TickSession.Value = tick()
	
	-- LOCK/UNLOCK SYSTEM
	
	
	if _G.Locked == true then
		plr:Kick("\n Dieser Server ist aktuell Gelockt, Versuch es späer nocheinmal!")
	elseif _G.Locked == false then
		print(plr.Name.." hat das Spiel betreten!")
	end
	
	
	
	
	-- BAN SYSTEM
	
	local data = TimedBans:GetAsync(plr.UserId)
	if data and data[1] == plr.UserId then

		if os.time() >= data[3] then
			print(os.time())
			TimedBans:SetAsync(plr.UserId,{".",".","."})
		else
			local d = data[3] - os.time()
			local s = d/86400
			local f = math.round(s)
			plr:Kick("\nDu wurdest gesperrt\nGrund: "..data[2].."\n"..f.." Verbleibende Tage bis zur Aufhebung der Sperre")
		end
	end
	wait(5)
	while wait(10) do
		if game.Players:FindFirstChild(plr.Name) then
			local data = TimedBans:GetAsync(plr.UserId)
			if data ~= nil then
				if data[1] == plr.UserId then
					local d = data[3] - os.time()
					local s = d/86400
					local f = math.round(s)
					plr:Kick("\nDu wurdest gesperrt\nGrund: "..data[2].."\n"..f.." Verbleibende Tage bis zur Aufhebung der Sperre")
					game.Workspace.RacBanFeed.Value = plr.Name
				end
			end
		end
	end
end)





BanEvent.OnServerEvent:Connect(function(player,Art,Spieler,Grund,Tage)
	if Art == "BAN" then
		local uid = game.Players:GetUserIdFromNameAsync(Spieler)

		local ostime = os.time()
		local da = tonumber(Tage)
		local d = da * 86400
		local length = d + ostime

		local tabl = {uid,Grund,length}

		TimedBans:SetAsync(uid,tabl)

		if game.Players:FindFirstChild(Spieler) == nil then
			print("Dieser Spieler ist Offline!")
		else
			game.Players:FindFirstChild(Spieler):Kick("\n\nDu wurdest gesperrt\n\nGrund: "..Grund.."\n\n"..Tage.." Verbleibende Tage bis zur Aufhebung der Sperre")
		end
	end
	
	if Art == "KICK" then
		if game.Players:FindFirstChild(Spieler) == nil then
			print("Dieser Spieler ist Offline!")
		else			
			--local uid = game.Players:GetUserIdFromNameAsync(Spieler)
			game.Players:FindFirstChild(Spieler):Kick("\n\nDu wurdest Gekickt:\n\nGrund: "..Grund.."\n\n Rejoin dem Spiel um es wieder zu spielen")
		end
	end
	
end)


OfflineBanEvent.OnServerEvent:Connect(function(player, Art, Spieler, Tage, Grund)
	
	
	--- OFFLINEBAN FUNKTION


	if Art == "BAN" then
		local uid = game.Players:GetUserIdFromNameAsync(Spieler)

		local ostime = os.time()
		local da = tonumber(Tage)
		local d = da * 86400
		local length = d + ostime

		local tabl = {uid,Grund,length}
		
		TimedBans:SetAsync(uid,tabl)

		
		OfflineBanEvent:FireClient(player, "NOTIFY", Spieler, Tage)
		
	end

	
	
	
end)


EntbanEvent.OnServerEvent:Connect(function(player, Art, Spieler)
	
	
	--- UNBAN FUNKTION
	
	if Art == "UNBAN" then
		local uid = game.Players:GetUserIdFromNameAsync(Spieler)
		TimedBans:SetAsync(uid,{".",".","."})

		EntbanEvent:FireClient(player, "NOTIFY", Spieler)
		--UNBAN COMMAND | game:GetService("DataStoreService"):GetDataStore("TimedBans"):SetAsync(USERID,{".",".","."})			
	end
	
	
end)


ServerLock.OnServerEvent:Connect(function(player, Art, Status)
	
	if Art == "LOCK" then
		if Status == "SERVER:LOCKED" then
			_G.Locked = true
			ServerLock:FireClient(player, "NOTIFYLOCK")
		end
		
	elseif Art == "UNLOCK" then
		if Status == "SERVER:UNLOCKED" then
			_G.Locked = false
			ServerLock:FireClient(player, "NOTIFYUNLOCKED")
		end
		
	end
	
end)



ServerAnnouncement.OnServerEvent:Connect(function(player, Art, Nachricht, Dauer)
	
	if Art == "ANNOUNCE" then
		
		print(Nachricht)
		print(Dauer)
		
		
		for i, Player in pairs(game.Players:GetPlayers()) do
			
			Announce.Announcement.MainFrame.Nachricht.Text = Nachricht
			
			Announce:Clone().Parent = Player.PlayerGui
			wait(Dauer)
			Player.PlayerGui:WaitForChild("AnnounceFenster"):Destroy()
		end
		
		
	end
	
end)



Warn.OnServerEvent:Connect(function(player, Spieler, Grund)	
	local playerGui = game.Players:FindFirstChild(Spieler):WaitForChild("PlayerGui")

	Warnung.WarnFenster.List.Grund.Text = Grund
	Warnung.WarnFenster.List.Moderator.Text = player.Name

	Warnung:Clone().Parent = playerGui
	wait(5)
	playerGui:WaitForChild("WarnFenster"):Destroy()
end)




TeleportEvent.OnServerEvent:Connect(function(player, Art, Spieler)
	if Art == "TELEPORTTO" then
		player.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(game.Workspace:WaitForChild(Spieler).HumanoidRootPart.Position)
		TeleportEvent:FireClient(player, "TELEPORTTO")
		
	elseif Art == "TELEPORTHERE" then
		game.Workspace:WaitForChild(Spieler).HumanoidRootPart.CFrame = CFrame.new(player.Character:WaitForChild("HumanoidRootPart").Position)
		TeleportEvent:FireClient(player, "TELEPORTHERE")
		
	end
end)



UnsichtbarEvent.OnServerEvent:Connect(function(player, Art)
	
	if Art == "UNSICHTBAR" then
		
		for i,v in pairs(player.Character:GetDescendants()) do
			if v:IsA("BasePart") or v:IsA("Decal") then 
				if v.Name == "HumanoidRootPart" then
				else

					v.Transparency = 1
				end
			end
		end	
		
	elseif Art == "SICHTBAR" then
		
		
		for i,v in pairs(player.Character:GetDescendants()) do
			if v:IsA("BasePart") or v:IsA("Decal") then 
				if v.Name == "HumanoidRootPart" then
					else

					v.Transparency = 0
					end
			end
		end	
		
	end
	
	
end)

GodmodeEvent.OnServerEvent:Connect(function(player, Art)
	
	local hum = player.Character:WaitForChild("Humanoid")	
	
	if Art == "AKTIVIERT" then
		
		hum.MaxHealth = math.huge
		
	elseif Art == "DEAKTIVIERT" then
		
		hum.MaxHealth = 100
		hum.Health = 100
		
	end
	
end)



ConfirmEvent.OnServerEvent:Connect(function(player, Art, Spieler, Wert)
	if Art == "WALKSPEED" then
		game.Workspace:FindFirstChild(Spieler):WaitForChild("Humanoid").WalkSpeed = Wert
	elseif Art == "JUMPPOWER" then
		game.Workspace:FindFirstChild(Spieler):WaitForChild("Humanoid").JumpHeight = Wert
	end
end)

ResetEvent.OnServerEvent:Connect(function(player, Art, Spieler)
	if Art == "WALKSPEED" then
		game.Workspace:FindFirstChild(Spieler):WaitForChild("Humanoid").WalkSpeed = 16
	elseif Art == "JUMPPOWER" then
		game.Workspace:FindFirstChild(Spieler):WaitForChild("Humanoid").JumpHeight = 7.2
	end
end)
