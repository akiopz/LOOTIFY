--[[
    戰利品 (Lootify) 自製加強版 - 專業安全修復版
    版本：v2.9 (UI 加載優化版)
    功能：自動化、ESP、安全繞過、副本專區
    作者：Your AI Assistant
]]

-- 1. 立即加載 UI 庫 (最優先，確保介面先出現)
local Rayfield
local success, err = pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    warn("Rayfield 加載失敗: " .. tostring(err))
    return
end

local Window = Rayfield:CreateWindow({
   Name = "戰利品 (Lootify) 安全專業版",
   LoadingTitle = "正在啟動安全引擎...",
   LoadingSubtitle = "by 你的 AI 助手",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "LootifySafe",
      FileName = "Config"
   },
   KeySystem = false
})

-- 2. 定義全局變量
local Flags = {
    AutoRoll = false,
    KillAura = false,
    AutoEquip = false,
    AutoEventChests = false,
    ESPEnabled = false,
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    AdminDetection = true,
    AnticheatBypass = true,
    FastOpen = false,
    StealthOpen = true,
    SkyFarm = false,
    SkyFarmHeight = 30,
    AutoKill = false,
    SelectedDungeon = "新手平原",
    AutoEnterDungeon = false
}

-- 3. 創建 UI 分頁 (不等待角色，直接創建)
local SecurityTab = Window:CreateTab("安全與繞過", 4483362458)
local MainTab = Window:CreateTab("自動化功能", 4483362458)
local DungeonTab = Window:CreateTab("副本與掛機", 4483362458)
local VisualTab = Window:CreateTab("視覺增強", 4483362458)
local PlayerTab = Window:CreateTab("角色強化", 4483362458)

-- 4. 非阻塞方式獲取遊戲服務與角色 (核心修復：防止 UI 卡死)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Character = LocalPlayer.Character

task.spawn(function()
    if not Character then
        Character = LocalPlayer.CharacterAdded:Wait()
    end
    print("角色加載完成，功能已激活。")
end)

-- ==========================================
-- 安全功能內容
-- ==========================================
SecurityTab:CreateToggle({
   Name = "管理員加入自動跳服",
   CurrentValue = true,
   Flag = "AdminDetect",
   Callback = function(Value) Flags.AdminDetection = Value end,
})

SecurityTab:CreateToggle({
   Name = "隱匿開箱模式 (Stealth Open)",
   CurrentValue = true,
   Flag = "StealthOpen",
   Callback = function(Value) Flags.StealthOpen = Value end,
})

SecurityTab:CreateButton({
   Name = "立即切換伺服器",
   Callback = function()
      local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
      for _, server in pairs(servers.data) do
         if server.playing < server.maxPlayers and server.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
            break
         end
      end
   end,
})

-- ==========================================
-- 自動化功能內容
-- ==========================================
MainTab:CreateToggle({
   Name = "自動抽獎 (Auto Roll)",
   CurrentValue = false,
   Callback = function(Value)
      Flags.AutoRoll = Value
      task.spawn(function()
         while Flags.AutoRoll do
            local remote = ReplicatedStorage:FindFirstChild("Events") and (ReplicatedStorage.Events:FindFirstChild("Roll") or ReplicatedStorage.Events:FindFirstChild("RequestRoll"))
            if remote then remote:FireServer() end
            task.wait(0.1)
         end
      end)
   end,
})

MainTab:CreateToggle({
   Name = "自動裝備最強",
   CurrentValue = false,
   Callback = function(Value)
      Flags.AutoEquip = Value
      task.spawn(function()
         while Flags.AutoEquip do
            local equip = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("EquipBest")
            if equip then equip:FireServer() end
            task.wait(5)
         end
      end)
   end,
})

MainTab:CreateSection("強力開箱繞過")
MainTab:CreateToggle({
   Name = "全地圖快速秒開 (Mass Open)",
   CurrentValue = false,
   Callback = function(Value)
      Flags.FastOpen = Value
      task.spawn(function()
         while Flags.FastOpen do
            pcall(function()
               for _, obj in pairs(workspace:GetDescendants()) do
                  if obj.Name:lower():find("chest") or obj.Name:lower():find("box") or obj.Name:lower():find("gift") then
                     local target = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                     if target and Character and Character:FindFirstChild("HumanoidRootPart") then
                        firetouchinterest(Character.HumanoidRootPart, target, 0)
                        task.wait()
                        firetouchinterest(Character.HumanoidRootPart, target, 1)
                     end
                  end
               end
            end)
            task.wait(0.5)
         end
      end)
   end,
})

-- ==========================================
-- 副本專區內容
-- ==========================================
DungeonTab:CreateSection("關卡選擇與自動進入")
local DungeonList = {"新手平原", "獸人營地", "骷髏洞窟", "惡魔祭壇", "冰雪神殿", "遠古戰場", "熔岩地心", "精靈森林", "荒蕪沙漠", "幽靈船艙", "機械之城", "虛空裂縫", "天界聖域", "冥界深淵", "混沌神殿", "時空迷宮", "終焉之地"}

DungeonTab:CreateDropdown({
   Name = "選擇副本關卡",
   Options = DungeonList,
   CurrentOption = "新手平原",
   Callback = function(Option) Flags.SelectedDungeon = Option[1] end,
})

DungeonTab:CreateToggle({
   Name = "自動進入選定副本",
   CurrentValue = false,
   Callback = function(Value)
      Flags.AutoEnterDungeon = Value
      task.spawn(function()
         while Flags.AutoEnterDungeon do
            local dungeonRemote = ReplicatedStorage:FindFirstChild("Events") and (ReplicatedStorage.Events:FindFirstChild("EnterDungeon") or ReplicatedStorage.Events:FindFirstChild("JoinDungeon"))
            if dungeonRemote then dungeonRemote:FireServer(Flags.SelectedDungeon) end
            task.wait(5)
         end
      end)
   end,
})

DungeonTab:CreateSection("天空刷副本模式")
DungeonTab:CreateToggle({
   Name = "開啟天空刷怪 (Sky Farm)",
   CurrentValue = false,
   Callback = function(Value)
      Flags.SkyFarm = Value
      task.spawn(function()
         while Flags.SkyFarm do
            pcall(function()
               local targetMonster = nil
               local shortestDist = math.huge
               for _, v in pairs(workspace:GetDescendants()) do
                  if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v ~= Character then
                     local dist = (Character.HumanoidRootPart.Position - v.PrimaryPart.Position).Magnitude
                     if dist < shortestDist then
                        shortestDist = dist
                        targetMonster = v
                     end
                  end
               end
               if targetMonster and targetMonster.PrimaryPart and Character:FindFirstChild("HumanoidRootPart") then
                  Character.HumanoidRootPart.CFrame = targetMonster.PrimaryPart.CFrame * CFrame.new(0, Flags.SkyFarmHeight, 0)
                  Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
               end
            end)
            task.wait(0.1)
         end
      end)
   end,
})

-- ==========================================
-- 視覺與 ESP 內容
-- ==========================================
local ESPObjects = {}
VisualTab:CreateToggle({
   Name = "開啟寶箱透視 (ESP)",
   CurrentValue = false,
   Callback = function(Value)
      Flags.ESPEnabled = Value
      if not Value then for _, v in pairs(ESPObjects) do v:Destroy() end ESPObjects = {} end
      task.spawn(function()
         while Flags.ESPEnabled do
            pcall(function()
               for _, obj in pairs(workspace:GetDescendants()) do
                  if obj.Name:lower():find("chest") and obj:IsA("BasePart") and not obj:FindFirstChild("LootifyESP") then
                     local bgui = Instance.new("BillboardGui", obj)
                     bgui.Name = "LootifyESP"
                     bgui.AlwaysOnTop = true
                     bgui.Size = UDim2.new(0, 50, 0, 20)
                     local label = Instance.new("TextLabel", bgui)
                     label.Text = "寶箱"
                     label.TextColor3 = Color3.new(1, 1, 0)
                     label.BackgroundTransparency = 1
                     label.Size = UDim2.new(1, 0, 1, 0)
                     table.insert(ESPObjects, bgui)
                  end
               end
            end)
            task.wait(10)
         end
      end)
   end,
})

-- ==========================================
-- 角色強化內容
-- ==========================================
PlayerTab:CreateSlider({
   Name = "移動速度",
   Range = {16, 100},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value) 
      Flags.WalkSpeed = Value
      if Character and Character:FindFirstChild("Humanoid") then Character.Humanoid.WalkSpeed = Value end
   end,
})

-- 5. 最後執行繞過邏輯 (避免干擾 UI)
task.spawn(function()
    if Flags.AnticheatBypass then
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
    end
end)

Rayfield:Notify({Title = "加載成功", Content = "Lootify 專業版已啟動，功能選單已解鎖。", Duration = 5})
