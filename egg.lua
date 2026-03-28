local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local Player = Players.LocalPlayer

-- ==========================================
-- 1. BIKIN GUI DASAR & SISTEM MINIMIZE
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoWalkEggHunter"
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
Title.Text = "🥚 AI AUTO-WALK"
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

local WalkBtn = Instance.new("TextButton")
WalkBtn.Size = UDim2.new(1, -20, 0, 40)
WalkBtn.Position = UDim2.new(0, 10, 1, -50)
WalkBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
WalkBtn.Text = "JALAN KE TELUR"
WalkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
WalkBtn.Font = Enum.Font.GothamBold
WalkBtn.TextSize = 14
WalkBtn.Parent = MainFrame
Instance.new("UICorner", WalkBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

-- ==========================================
-- 2. LOGIKA PENCAKARI TELUR
-- ==========================================
local isRunning = true
local currentEggIndex = 1
local cachedEggs = {}

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

task.spawn(function()
    while isRunning do
        cachedEggs = FindAllEggs()
        if ServerCountLabel then
            ServerCountLabel.Text = "Telur di Server adaa: " .. #cachedEggs
        end
        task.wait(1)
    end
end)

-- ==========================================
-- 3. AI PATHFINDING (GPS OTOMATIS)
-- ==========================================
local isWalking = false

WalkBtn.MouseButton1Click:Connect(function()
    -- Kalo lagi jalan dan tombol dipencet, berfungsi jadi tombol STOP
    if isWalking then
        isWalking = false
        WalkBtn.Text = "MEMBATALKAN..."
        return
    end
    
    cachedEggs = FindAllEggs()
    if #cachedEggs == 0 then
        WalkBtn.Text = "KOSONG! Nunggu..."
        task.delay(1.5, function() if not isWalking then WalkBtn.Text = "JALAN KE TELUR" end end)
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
            isWalking = true
            WalkBtn.Text = "🛑 STOP JALAN"
            WalkBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
            
            task.spawn(function()
                -- Bikin settingan GPS buat karakter
                local path = PathfindingService:CreatePath({
                    AgentRadius = 3,         -- Jarak biar ga nabrak tembok
                    AgentHeight = 5,         -- Tinggi karakter
                    AgentCanJump = true,     -- Izinkan AI buat loncat
                    WaypointSpacing = 4      -- Jarak antar titik kordinat (GPS)
                })
                
                -- Mulai hitung rute dari tempat lu ke telur
                local success, errorMessage = pcall(function()
                    path:ComputeAsync(hrp.Position, targetPos)
                end)
                
                if success and path.Status == Enum.PathStatus.Success then
                    local waypoints = path:GetWaypoints()
                    
                    -- Mulai jalanin karakter ngikutin titik-titik GPS
                    for i, wp in ipairs(waypoints) do
                        if not isWalking then break end -- Kalo lu pencet STOP
                        
                        -- Kalo AI bilang harus loncat (misal ada tebing/batu)
                        if wp.Action == Enum.PathWaypointAction.Jump then
                            hum.Jump = true
                        end
                        
                        -- Suruh karakter jalan ke titik selanjutnya
                        hum:MoveTo(wp.Position)
                        
                        -- Nunggu sampe karakternya nyampe di titik itu (dikasih timeout biar ga stuck)
                        local timeout = 2
                        local startTimer = tick()
                        repeat
                            task.wait(0.1)
                        until not isWalking or (hrp.Position - wp.Position).Magnitude < 3 or (tick() - startTimer) > timeout
                    end
                    
                    if isWalking then
                        -- Kalo udah sampe tujuan
                        isWalking = false
                        currentEggIndex = currentEggIndex + 1
                        
                        -- Senggol bacok virtual
                        local eggPart = targetEgg:IsA("BasePart") and targetEgg or targetEgg:FindFirstChildWhichIsA("BasePart")
                        if eggPart and firetouchinterest then
                            pcall(function()
                                firetouchinterest(hrp, eggPart, 0)
                                task.wait(0.05)
                                firetouchinterest(hrp, eggPart, 1)
                            end)
                        end
                        
                        WalkBtn.Text = "SAMPE! (NEXT)"
                        WalkBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
                        task.delay(1, function() 
                            if not isWalking then 
                                WalkBtn.Text = "JALAN KE TELUR" 
                                WalkBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
                            end
                        end)
                    end
                else
                    -- Kalo AI ga nemu jalan (misal telurnya di dalem ruangan terkunci)
                    isWalking = false
                    WalkBtn.Text = "RUTE BUNTU!"
                    WalkBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
                    task.delay(2, function() 
                        WalkBtn.Text = "JALAN KE TELUR" 
                        WalkBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
                    end)
                end
            end)
        end
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    isRunning = false
    isWalking = false
    ScreenGui:Destroy()
end)
