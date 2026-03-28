local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

-- ==========================================
-- 1. BIKIN GUI DASAR & SISTEM MINIMIZE
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateHybridEggHunter"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true 

local success, target = pcall(function() return gethui() end)
if success and target then
    ScreenGui.Parent = target
else
    local coreSuccess = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not coreSuccess then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 140)
MainFrame.Position = UDim2.new(0.5, 150, 0.5, -65)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Sistem Drag GUI
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "🥚 ULTIMATE HYBRID"
Title.TextColor3 = Color3.fromRGB(200, 255, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.Parent = MainFrame

local ServerCountLabel = Instance.new("TextLabel")
ServerCountLabel.Size = UDim2.new(1, -20, 0, 30)
ServerCountLabel.Position = UDim2.new(0, 10, 0, 35)
ServerCountLabel.BackgroundTransparency = 1
ServerCountLabel.Text = "Telur di Server: Menghitung..."
ServerCountLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
ServerCountLabel.Font = Enum.Font.GothamMedium
ServerCountLabel.TextSize = 13
ServerCountLabel.Parent = MainFrame

local ActionBtn = Instance.new("TextButton")
ActionBtn.Size = UDim2.new(1, -20, 0, 40)
ActionBtn.Position = UDim2.new(0, 10, 1, -50)
ActionBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
ActionBtn.Text = "JALAN + TP (1x)"
ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionBtn.Font = Enum.Font.GothamBold
ActionBtn.TextSize = 14
ActionBtn.Parent = MainFrame
Instance.new("UICorner", ActionBtn).CornerRadius = UDim.new(0, 6)

-- TOMBOL CLOSE
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

-- TOMBOL MINIMIZE
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
MinimizeBtn.Position = UDim2.new(1, -60, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = MainFrame
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 5)

-- TOMBOL OPEN (Muncul pas diminimize)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 45, 0, 45)
OpenBtn.Position = UDim2.new(1, -60, 0.5, -22)
OpenBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 50)
OpenBtn.Text = "🥚"
OpenBtn.TextSize = 20
OpenBtn.Visible = false
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(150, 255, 150)

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenBtn.Visible = true
end)
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenBtn.Visible = false
end)

-- ==========================================
-- 2. SISTEM WAYPOINT & PENCARI TELUR
-- ==========================================
local isRunning = true
local currentEggIndex = 1
local cachedEggs = {}

-- Setup Remote Fast Travel bawaan game
local FastTravelRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("FastTravel")
local WaypointsFolder = workspace:WaitForChild("Map"):WaitForChild("Waypoints")

local function FindAllEggs()
    local found = {}
    local geodeFolder = workspace:FindFirstChild("Geode")
    if geodeFolder then
        for _, obj in ipairs(geodeFolder:GetChildren()) do
            if obj.Name == "EasterEgg" and obj.Parent then table.insert(found, obj) end
        end
    else
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "EasterEgg" and obj.Parent then table.insert(found, obj) end
        end
    end
    return found
end

local function GetClosestWaypoint(targetPosition)
    local closestWP = nil
    local shortestDist = math.huge
    for _, wp in ipairs(WaypointsFolder:GetChildren()) do
        if wp:IsA("Model") and wp.PrimaryPart then
            local dist = (wp.PrimaryPart.Position - targetPosition).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                closestWP = wp
            end
        end
    end
    return closestWP
end

task.spawn(function()
    while isRunning do
        cachedEggs = FindAllEggs()
        if ServerCountLabel then
            ServerCountLabel.Text = "Telur di Server: " .. #cachedEggs
        end
        task.wait(1)
    end
end)

-- ==========================================
-- 3. LOGIKA HYBRID (FAST TRAVEL -> AI WALK)
-- ==========================================
local isWorking = false

ActionBtn.MouseButton1Click:Connect(function()
    if isWorking then
        isWorking = false
        ActionBtn.Text = "MEMBATALKAN..."
        return
    end
    
    cachedEggs = FindAllEggs()
    if #cachedEggs == 0 then
        ActionBtn.Text = "KOSONG! Nunggu..."
        task.delay(1.5, function() if not isWorking then ActionBtn.Text = "JALAN + TP (1x)" end end)
        return
    end

    if currentEggIndex > #cachedEggs then currentEggIndex = 1 end
    local targetEgg = cachedEggs[currentEggIndex]
    
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if hrp and hum and targetEgg and targetEgg.Parent then
        local targetPos = targetEgg:IsA("Model") and targetEgg:GetPivot().Position or targetEgg.Position
        
        if targetPos then
            isWorking = true
            ActionBtn.Text = "🛑 STOP PROSES"
            ActionBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
            
            task.spawn(function()
                -- LAKUKAN PENGECEKAN FAST TRAVEL
                local destWP = GetClosestWaypoint(targetPos)
                local sourceWP = GetClosestWaypoint(hrp.Position)
                
                -- Kalo lu belom ada di Waypoint yang deket telur, panggil ojek portal!
                if destWP and sourceWP and destWP ~= sourceWP then
                    ActionBtn.Text = "🛑 FAST TRAVEL..."
                    FastTravelRemote:FireServer(sourceWP, destWP)
                    
                    -- Kasih waktu 3 detik buat game nge-load layar fast travel lu
                    task.wait(3)
                end
                
                -- Kalo lu udah di area yang bener (atau udah selesai fast travel), mulai jalan kaki
                if not isWorking then return end
                ActionBtn.Text = "🛑 AI JALAN KAKI..."
                
                -- Bikin rute GPS dari posisi lu yang BARU ke titik telur
                local path = PathfindingService:CreatePath({
                    AgentRadius = 3,
                    AgentHeight = 5,
                    AgentCanJump = true,
                    WaypointSpacing = 4
                })
                
                local success, errorMessage = pcall(function()
                    path:ComputeAsync(hrp.Position, targetPos)
                end)
                
                if success and path.Status == Enum.PathStatus.Success then
                    local waypoints = path:GetWaypoints()
                    
                    for i, wp in ipairs(waypoints) do
                        if not isWorking then break end
                        
                        -- Loncat kalo AI nyuruh loncat (ada tangga/batu)
                        if wp.Action == Enum.PathWaypointAction.Jump then
                            hum.Jump = true
                        end
                        
                        -- Jalan ke titik rute
                        hum:MoveTo(wp.Position)
                        
                        -- Tunggu sampe nyampe di titik sub-rute (maksimal 2 detik per titik)
                        local timeout = 2
                        local startTimer = tick()
                        repeat
                            task.wait(0.1)
                        until not isWorking or (hrp.Position - wp.Position).Magnitude < 3 or (tick() - startTimer) > timeout
                    end
                    
                    if isWorking then
                        isWorking = false
                        currentEggIndex = currentEggIndex + 1
                        
                        -- Senggol Bacok Virtual pas sampe
                        local eggPart = targetEgg:IsA("BasePart") and targetEgg or targetEgg:FindFirstChildWhichIsA("BasePart")
                        if eggPart and firetouchinterest then
                            pcall(function()
                                firetouchinterest(hrp, eggPart, 0)
                                task.wait(0.05)
                                firetouchinterest(hrp, eggPart, 1)
                            end)
                        end
                        
                        ActionBtn.Text = "SAMPE! (NEXT)"
                        ActionBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
                        task.delay(1.5, function() 
                            if not isWorking then 
                                ActionBtn.Text = "JALAN + TP (1x)" 
                                ActionBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
                            end
                        end)
                    end
                else
                    isWorking = false
                    ActionBtn.Text = "RUTE BUNTU!"
                    ActionBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
                    task.delay(2, function() 
                        ActionBtn.Text = "JALAN + TP (1x)" 
                        ActionBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
                    end)
                end
            end)
        end
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    isRunning = false
    isWorking = false
    ScreenGui:Destroy()
end)
