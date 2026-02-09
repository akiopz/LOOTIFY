--[[
    戰利品 (Lootify) 自製加強版 - Orion UI 兼容版
    版本：v4.0 (更換 UI 庫以修復空白問題)
    UI 庫：Orion Library
]]

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "戰利品 (Lootify) 專業版 v4.0", HidePremium = false, SaveConfig = false, IntroText = "Lootify 安全引擎"})

-- 全局變量
local Flags = {
    AutoRoll = false,
    AutoEquip = false,
    FastOpen = false,
    StealthOpen = true,
    SelectedDungeon = "新手平原",
    AutoEnterDungeon = false,
    WalkSpeed = 16
}

-- 1. 自動化分頁
local MainTab = Window:MakeTab({
	Name = "自動化功能",
	Icon = "rbxassetid://4483362458",
	PremiumOnly = false
})

MainTab:AddToggle({
	Name = "自動抽獎 (Auto Roll)",
	Default = false,
	Callback = function(Value)
		Flags.AutoRoll = Value
		task.spawn(function()
			while Flags.AutoRoll do
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local remote = ReplicatedStorage:FindFirstChild("Events") and (ReplicatedStorage.Events:FindFirstChild("Roll") or ReplicatedStorage.Events:FindFirstChild("RequestRoll"))
				if remote then remote:FireServer() end
				task.wait(0.1)
			end
		end)
	end    
})

MainTab:AddToggle({
	Name = "自動裝備最強",
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

MainTab:AddToggle({
	Name = "全地圖快速秒開",
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
				task.wait(0.5)
			end
		end)
	end    
})

-- 2. 副本分頁
local DungeonTab = Window:MakeTab({
	Name = "副本與掛機",
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
	Name = "自動進入副本",
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

-- 3. 安全分頁
local SecurityTab = Window:MakeTab({
	Name = "安全與繞過",
	Icon = "rbxassetid://4483362458",
	PremiumOnly = false
})

SecurityTab:AddToggle({
	Name = "隱匿開箱模式 (Stealth)",
	Default = true,
	Callback = function(Value)
		Flags.StealthOpen = Value
	end    
})

-- 4. 角色強化
local PlayerTab = Window:MakeTab({
	Name = "角色強化",
	Icon = "rbxassetid://4483362458",
	PremiumOnly = false
})

PlayerTab:AddSlider({
	Name = "移動速度",
	Min = 16,
	Max = 100,
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

-- 初始化完畢
OrionLib:Init()

-- 繞過邏輯 (非阻塞)
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
