local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

-- ==========================================
-- 1. BIKIN GUI DASAR & SISTEM MINIMIZE
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HybridEggTeleporter"
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
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

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
Title.Text = "🥚 HYBRID TP EGG"
Title.TextColor3 = Color3.fromRGB(200, 255, 255)
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

local TpBtn = Instance.new("TextButton")
TpBtn.Size = UDim2.new(1, -20, 0, 40)
TpBtn.Position = UDim2.new(0, 10, 1, -50)
TpBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
TpBtn.Text = "TELEPORT (1x)"
TpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TpBtn.Font = Enum.Font.GothamBold
TpBtn.TextSize = 14
TpBtn.Parent = MainFrame
Instance.new("UICorner", TpBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
MinimizeBtn.Position = UDim2.new(1, -60, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = MainFrame
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 5)

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 45, 0, 45)
OpenBtn.Position = UDim2.new(1, -60, 0.5, -22)
OpenBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 50)
OpenBtn.Text = "🥚"
OpenBtn.TextSize = 20
OpenBtn.Visible = false
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(255, 150, 255)

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

local FastTravelRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("FastTravel")
local WaypointsFolder = workspace:WaitForChild("Map"):WaitForChild("Waypoints")

local function FindAllEggs()
    local found = {}
    local geodeFolder = workspace:FindFirstChild("Geode")
    if geodeFolder then
        for _, obj in ipairs(geodeFolder:GetChildren()) do
            if obj.Name == "EasterEgg" and obj.Parent then
                table.insert(found, obj)
            end
        end
    else
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "EasterEgg" and obj.Parent then
                table.insert(found, obj)
            end
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
-- 3. EKSEKUSI HYBRID TELEPORT
-- ==========================================
local isTeleporting = false

TpBtn.MouseButton1Click:Connect(function()
    if isTeleporting then return end
    
    cachedEggs = FindAllEggs()
    if #cachedEggs == 0 then
        TpBtn.Text = "KOSONG! Nunggu..."
        task.delay(1.5, function() if not isTeleporting then TpBtn.Text = "TELEPORT (1x)" end end)
        return
    end

    if currentEggIndex > #cachedEggs then currentEggIndex = 1 end
    local targetEgg = cachedEggs[currentEggIndex]
    
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hrp and targetEgg and targetEgg.Parent then
        local targetPos = targetEgg:IsA("Model") and targetEgg:GetPivot().Position or targetEgg.Position
        
        if targetPos then
            isTeleporting = true
            TpBtn.Text = "FAST TRAVEL..."
            TpBtn.BackgroundColor3 = Color3.fromRGB(180, 120, 50)
            
            -- Langkah 1: Numpang Fast Travel ke pulau terdekat
            local destWP = GetClosestWaypoint(targetPos)
            local sourceWP = GetClosestWaypoint(hrp.Position)
            
            if destWP and sourceWP and destWP ~= sourceWP then
                FastTravelRemote:FireServer(sourceWP, destWP)
                task.wait(2) -- Tunggu loading layar fast travel
            end
            
            -- Langkah 2: Jarak udah deket, sikat sisa jaraknya pake CFrame Lock!
            TpBtn.Text = "FINISHING..."
            
            local targetCFrame = CFrame.new(targetPos + Vector3.new(0, 2, 0))
            hrp.Anchored = true 
            
            local tpLock = RunService.Heartbeat:Connect(function()
                hrp.CFrame = targetCFrame
                hrp.Velocity = Vector3.zero
            end)
            
            task.wait(0.5) -- Lock posisinya setengah detik biar server pasrah
            tpLock:Disconnect()
            hrp.Anchored = false
            
            -- Langkah 3: Senggol Bacok Virtual
            local eggPart = targetEgg:IsA("BasePart") and targetEgg or targetEgg:FindFirstChildWhichIsA("BasePart")
            if eggPart and firetouchinterest then
                pcall(function()
                    firetouchinterest(hrp, eggPart, 0)
                    task.wait(0.05)
                    firetouchinterest(hrp, eggPart, 1)
                end)
            end
            
            currentEggIndex = currentEggIndex + 1
            isTeleporting = false
            
            TpBtn.Text = "SUKSES TP!"
            TpBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
            task.delay(1, function() 
                if not isTeleporting then 
                    TpBtn.Text = "TELEPORT (1x)" 
                    TpBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
                end
            end)
        end
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    isRunning = false
    ScreenGui:Destroy()
end)
