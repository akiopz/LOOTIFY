--[[
    戰利品 (Lootify) 自製加強版 - Orion UI 兼容版
    版本：v5.0 (功能全面強化版)
    UI 庫：Orion Library
]]

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "戰利品 (Lootify) 終極強化版 v5.0", HidePremium = false, SaveConfig = false, IntroText = "Lootify 強化引擎"})

-- 全局變量
local Flags = {
    AutoRoll = false,
    AutoEquip = false,
    FastOpen = false,
    StealthOpen = true,
    KillAura = false,
    AutoCollect = false,
    SelectedDungeon = "新手平原",
    AutoEnterDungeon = false,
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    PlayerESP = false
}

-- 1. 自動化分頁 (強化)
local MainTab = Window:MakeTab({
	Name = "自動化功能",
	Icon = "rbxassetid://4483362458",
	PremiumOnly = false
})

MainTab:AddToggle({
	Name = "自動抽獎 (極速版)",
	Default = false,
	Callback = function(Value)
		Flags.AutoRoll = Value
		task.spawn(function()
			while Flags.AutoRoll do
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local remote = ReplicatedStorage:FindFirstChild("Events") and (ReplicatedStorage.Events:FindFirstChild("Roll") or ReplicatedStorage.Events:FindFirstChild("RequestRoll"))
				if remote then remote:FireServer() end
				task.wait(0.05) -- 加快頻率
			end
		end)
	end    
})

MainTab:AddToggle({
	Name = "全地圖快速秒開 (自動掃描)",
	Default = false,
	Callback = function(Value)
		Flags.FastOpen = Value
		task.spawn(function()
			while Flags.FastOpen do
				pcall(function()
					for _, obj in pairs(workspace:GetDescendants()) do
						if obj.Name:lower():find("chest") or obj.Name:lower():find("box") then
							local target = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
							if target and game.Players.LocalPlayer.Character then
								firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, target, 0)
								task.wait()
								firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, target, 1)
							end
						end
					end
				end)
				task.wait(0.3)
			end
		end)
	end    
})

MainTab:AddToggle({
	Name = "自動拾取掉落物",
	Default = false,
	Callback = function(Value)
		Flags.AutoCollect = Value
		task.spawn(function()
			while Flags.AutoCollect do
				pcall(function()
					for _, item in pairs(workspace:GetChildren()) do
						if item:IsA("BasePart") and (item.Name:lower():find("loot") or item:FindFirstChild("TouchInterest")) then
							firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, item, 0)
							task.wait()
							firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, item, 1)
						end
					end
				end)
				task.wait(0.5)
			end
		end)
	end    
})

-- 2. 戰鬥分頁 (新增)
local CombatTab = Window:MakeTab({
	Name = "戰鬥與刷怪",
	Icon = "rbxassetid://4483362458",
	PremiumOnly = false
})

CombatTab:AddToggle({
	Name = "殺怪光環 (Kill Aura)",
	Default = false,
	Callback = function(Value)
		Flags.KillAura = Value
		task.spawn(function()
			while Flags.KillAura do
				pcall(function()
					local lp = game.Players.LocalPlayer
					for _, enemy in pairs(workspace:GetChildren()) do
						if enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy.Humanoid.Health > 0 then
							local dist = (lp.Character.HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
							if dist < 20 then
								local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Events") and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
								if remote then
									-- 模擬攻擊遠程事件 (具體視遊戲而定)
									local attackRemote = game:GetService("ReplicatedStorage").Events:FindFirstChild("Attack") or game:GetService("ReplicatedStorage").Events:FindFirstChild("Hit")
									if attackRemote then
										attackRemote:FireServer(enemy)
									end
								end
							end
						end
					end
				end)
				task.wait(0.1)
			end
		end)
	end    
})

CombatTab:AddToggle({
	Name = "自動裝備最強裝備",
	Default = false,
	Callback = function(Value)
		Flags.AutoEquip = Value
		task.spawn(function()
			while Flags.AutoEquip do
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local equip = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("EquipBest")
				if equip then equip:FireServer() end
				task.wait(5)
			end
		end)
	end    
})

-- 3. 副本分頁
local DungeonTab = Window:MakeTab({
	Name = "副本專區",
	Icon = "rbxassetid://4483362458",
	PremiumOnly = false
})

local DungeonList = {"新手平原", "獸人營地", "骷髏洞窟", "惡魔祭壇", "冰雪神殿", "遠古戰場", "熔岩地心", "精靈森林", "荒蕪沙漠", "幽靈船艙", "機械之城", "虛空裂縫", "天界聖域", "冥界深淵", "混沌神殿", "時空迷宮", "終焉之地"}

DungeonTab:AddDropdown({
	Name = "選擇副本關卡",
	Default = "新手平原",
	Options = DungeonList,
	Callback = function(Value)
		Flags.SelectedDungeon = Value
	end    
})

DungeonTab:AddToggle({
	Name = "自動進入選定副本",
	Default = false,
	Callback = function(Value)
		Flags.AutoEnterDungeon = Value
		task.spawn(function()
			while Flags.AutoEnterDungeon do
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local dungeonRemote = ReplicatedStorage:FindFirstChild("Events") and (ReplicatedStorage.Events:FindFirstChild("EnterDungeon") or ReplicatedStorage.Events:FindFirstChild("JoinDungeon"))
				if dungeonRemote then dungeonRemote:FireServer(Flags.SelectedDungeon) end
				task.wait(5)
			end
		end)
	end    
})

-- 4. 角色強化 (新增無限跳)
local PlayerTab = Window:MakeTab({
	Name = "角色強化",
	Icon = "rbxassetid://4483362458",
	PremiumOnly = false
})

PlayerTab:AddSlider({
	Name = "移動速度",
	Min = 16,
	Max = 200,
	Default = 16,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "Speed",
	Callback = function(Value)
		Flags.WalkSpeed = Value
		if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
			game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
		end
	end    
})

PlayerTab:AddToggle({
	Name = "無限跳躍",
	Default = false,
	Callback = function(Value)
		Flags.InfiniteJump = Value
	end    
})

game:GetService("UserInputService").JumpRequest:Connect(function()
	if Flags.InfiniteJump then
		game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
	end
end)

-- 5. 視覺與安全
local VisualTab = Window:MakeTab({
	Name = "視覺與安全",
	Icon = "rbxassetid://4483362458",
	PremiumOnly = false
})

VisualTab:AddToggle({
	Name = "玩家透視 (ESP)",
	Default = false,
	Callback = function(Value)
		Flags.PlayerESP = Value
		-- 簡單 ESP 邏輯
		task.spawn(function()
			while Flags.PlayerESP do
				for _, p in pairs(game.Players:GetPlayers()) do
					if p ~= game.Players.LocalPlayer and p.Character and not p.Character:FindFirstChild("Highlight") then
						local hl = Instance.new("Highlight", p.Character)
						hl.FillColor = Color3.fromRGB(255, 0, 0)
					end
				end
				task.wait(2)
			end
			for _, p in pairs(game.Players:GetPlayers()) do
				if p.Character and p.Character:FindFirstChild("Highlight") then
					p.Character.Highlight:Destroy()
				end
			end
		end)
	end    
})

VisualTab:AddToggle({
	Name = "隱匿開箱模式",
	Default = true,
	Callback = function(Value)
		Flags.StealthOpen = Value
	end    
})

-- 初始化
OrionLib:Init()

-- 繞過邏輯
task.spawn(function()
    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    setreadonly(mt, false)
    mt.__index = newcclosure(function(t, k)
        if not checkcaller() and t:IsA("Humanoid") then
            if k == "WalkSpeed" then return 16
            elseif k == "JumpPower" then return 50 end
        end
        return oldIndex(t, k)
    end)
    setreadonly(mt, true)
end)
