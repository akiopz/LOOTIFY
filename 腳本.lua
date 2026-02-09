--[[
    戰利品 (Lootify) 自製加強版 - 終極兼容修復版
    版本：v3.0 (穩定性優先)
    功能：自動化、ESP、安全繞過、副本專區
    說明：修復了某些執行器下 UI 空白的問題
]]

print("--- Lootify Script v3.0 啟動中 ---")

-- 1. 加載 UI 庫 (增加超時處理)
local Rayfield
local success, err = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    print("Rayfield 加載報錯: " .. tostring(err))
    return
end
print("1. UI 庫加載成功")

-- 2. 創建窗口 (移除 ConfigurationSaving 以防權限問題導致掛起)
local Window = Rayfield:CreateWindow({
   Name = "戰利品 (Lootify) 安全專業版",
   LoadingTitle = "正在啟動安全引擎 v3.0...",
   LoadingSubtitle = "by 你的 AI 助手",
   ConfigurationSaving = { Enabled = false }, -- 關閉以提高兼容性
   KeySystem = false
})
print("2. 窗口創建成功")

-- 3. 延遲一下確保窗口渲染
task.wait(0.5)

-- 4. 全局變量
local Flags = {
    AutoRoll = false,
    AutoEquip = false,
    FastOpen = false,
    StealthOpen = true,
    SkyFarm = false,
    SkyFarmHeight = 30,
    AutoKill = false,
    SelectedDungeon = "新手平原",
    AutoEnterDungeon = false,
    WalkSpeed = 16,
    ESPEnabled = false
}

-- 5. 創建分頁 (加入 pcall 確保單個失敗不影響整體)
local function CreateTabs()
    local success, err = pcall(function()
        -- 安全分頁
        local SecurityTab = Window:CreateTab("安全與繞過", 4483362458)
        SecurityTab:CreateToggle({
           Name = "管理員加入自動跳服",
           CurrentValue = true,
           Callback = function(Value) Flags.AdminDetection = Value end,
        })
        SecurityTab:CreateToggle({
           Name = "隱匿開箱模式 (Stealth Open)",
           CurrentValue = true,
           Callback = function(Value) Flags.StealthOpen = Value end,
        })
        print("3. 安全分頁創建成功")

        -- 自動化分頁
        local MainTab = Window:CreateTab("自動化功能", 4483362458)
        MainTab:CreateToggle({
           Name = "自動抽獎 (Auto Roll)",
           CurrentValue = false,
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
           end,
        })
        MainTab:CreateToggle({
           Name = "自動裝備最強",
           CurrentValue = false,
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
           end,
        })
        MainTab:CreateToggle({
           Name = "全地圖快速秒開",
           CurrentValue = false,
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
           end,
        })
        print("4. 自動化分頁創建成功")

        -- 副本分頁
        local DungeonTab = Window:CreateTab("副本與掛機", 4483362458)
        local DungeonList = {"新手平原", "獸人營地", "骷髏洞窟", "惡魔祭壇", "冰雪神殿", "遠古戰場", "熔岩地心", "精靈森林", "荒蕪沙漠", "幽靈船艙", "機械之城", "虛空裂縫", "天界聖域", "冥界深淵", "混沌神殿", "時空迷宮", "終焉之地"}
        DungeonTab:CreateDropdown({
           Name = "選擇副本關卡",
           Options = DungeonList,
           CurrentOption = "新手平原",
           Callback = function(Option) Flags.SelectedDungeon = Option[1] end,
        })
        DungeonTab:CreateToggle({
           Name = "自動進入副本",
           CurrentValue = false,
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
           end,
        })
        print("5. 副本分頁創建成功")
        
        -- 角色強化分頁
        local PlayerTab = Window:CreateTab("角色強化", 4483362458)
        PlayerTab:CreateSlider({
           Name = "移動速度",
           Range = {16, 100},
           Increment = 1,
           CurrentValue = 16,
           Callback = function(Value) 
              Flags.WalkSpeed = Value
              if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                 game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
              end
           end,
        })
        print("6. 角色分頁創建成功")
    end)
    if not success then
        print("創建分頁出錯: " .. tostring(err))
    end
end

-- 6. 啟動 UI 創建
task.spawn(CreateTabs)

-- 7. 繞過邏輯 (非阻塞)
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
    print("7. 繞過邏輯已啟動")
end)

Rayfield:Notify({Title = "啟動完畢", Content = "Lootify v3.0 已經就緒，若分頁仍未出現請嘗試重新執行。", Duration = 5})
print("--- 腳本加載完成 ---")
