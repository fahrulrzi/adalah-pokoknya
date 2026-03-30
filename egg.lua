local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

-- ==========================================
-- GLOBAL SETTINGS (Biar ga ilang pas re-run)
-- ==========================================
_G.ESPToggled = _G.ESPToggled or false
_G.IsWorking = false -- Status Auto-Walk/Hybrid

local espTable = {} -- Buat nyimpen data ESP

-- ==========================================
-- 1. BIKIN GUI COMPACT & MINIMIZE
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CompactEggHunterESP"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true 

local success, target = pcall(function() return gethui() end)
if success and target then
    ScreenGui.Parent = target
else
    local coreSuccess = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not coreSuccess then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end
end

-- MAIN FRAME (Ukuran Diperkecil jadi 180x110)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 180, 0, 110)
MainFrame.Position = UDim2.new(0.95, -185, 0.5, -55) -- Mojok kanan tengah
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(50, 60, 80)

-- Sistem Drag GUI (Tetep ada)
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

-- TITLE (Perkecil teks)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 22)
Title.BackgroundTransparency = 1
Title.Text = "🥚 EGG HUNTER LITE"
Title.TextColor3 = Color3.fromRGB(200, 255, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.Parent = MainFrame

-- INFO (Telor di Server)
local ServerCountLabel = Instance.new("TextLabel")
ServerCountLabel.Size = UDim2.new(1, -10, 0, 15)
ServerCountLabel.Position = UDim2.new(0, 5, 0, 25)
ServerCountLabel.BackgroundTransparency = 1
ServerCountLabel.Text = "Server: --"
ServerCountLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
ServerCountLabel.Font = Enum.Font.GothamMedium
ServerCountLabel.TextSize = 10
ServerCountLabel.Parent = MainFrame

-- TOMBOL ESP (On/Off)
local EspBtn = Instance.new("TextButton")
EspBtn.Size = UDim2.new(1, -10, 0, 25)
EspBtn.Position = UDim2.new(0, 5, 0, 45)
EspBtn.BackgroundColor3 = _G.ESPToggled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
EspBtn.Text = _G.ESPToggled and "ESP: ON" or "ESP: OFF"
EspBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EspBtn.Font = Enum.Font.GothamBold
EspBtn.TextSize = 11
EspBtn.Parent = MainFrame
Instance.new("UICorner", EspBtn).CornerRadius = UDim.new(0, 4)

-- TOMBOL HYBRID ACTION (Kecilin jadi 25px)
local ActionBtn = Instance.new("TextButton")
ActionBtn.Size = UDim2.new(1, -10, 0, 30)
ActionBtn.Position = UDim2.new(0, 5, 1, -35)
ActionBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
ActionBtn.Text = "AUTO-NGEGRAB (1x)"
ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionBtn.Font = Enum.Font.GothamBold
ActionBtn.TextSize = 11
ActionBtn.Parent = MainFrame
Instance.new("UICorner", ActionBtn).CornerRadius = UDim.new(0, 4)

-- TOMBOL CLOSE (X) - Kecilin
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 18, 0, 18)
CloseBtn.Position = UDim2.new(1, -22, 0, 2)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 10
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

-- TOMBOL MINIMIZE (-) - Kecilin
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 18, 0, 18)
MinimizeBtn.Position = UDim2.new(1, -44, 0, 2)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 12
MinimizeBtn.Parent = MainFrame
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 4)

-- TOMBOL OPEN (Muncul pas diminimize - Buat bulet imut)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 30, 0, 30)
OpenBtn.Position = UDim2.new(1, -35, 0.5, -15)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
OpenBtn.Text = "🥚"
OpenBtn.TextSize = 15
OpenBtn.Visible = false
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0) -- Bulet
Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(150, 255, 150)

MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true OpenBtn.Visible = false end)

-- ==========================================
-- 2. LOGIKA ESP (ON/OFF)
-- ==========================================
local function CreateESP(obj)
    if obj:FindFirstChild("EggESP") then return end -- Ga usah bikin dobel
    
    -- Kita pake modern Highlight biar keliatan nembus tembok
    local highlight = Instance.new("Highlight")
    highlight.Name = "EggESP"
    highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Warna ijo cerah
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- Outline putih
    highlight.OutlineTransparency = 0
    highlight.Adornee = obj
    highlight.Parent = obj
    
    -- Tambah TextLabel melayang biar tau jarak (Opsional, gw matiin biar ga berat)
    --[[
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EggESPText"
    billboard.Size = UDim2.new(0, 50, 0, 20)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = obj
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "🥚"
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 25Studs)
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = billboard
    ]]
    
    espTable[obj] = highlight
end

local function RemoveESP(obj)
    if obj and espTable[obj] then
        if espTable[obj].Parent then espTable[obj]:Destroy() end
        espTable[obj] = nil
    end
end

local function ClearAllESP()
    for obj, visual in pairs(espTable) do
        if visual.Parent then visual:Destroy() end
    end
    espTable = {}
end

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

-- Update fungsi tombol ESP
local function UpdateESPState()
    _G.ESPToggled = not _G.ESPToggled
    EspBtn.Text = _G.ESPToggled and "ESP: ON" or "ESP: OFF"
    EspBtn.BackgroundColor3 = _G.ESPToggled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
    
    if not _G.ESPToggled then
        ClearAllESP()
    end
end

EspBtn.MouseButton1Click:Connect(UpdateESPState)

-- Loop background buat update ESP tiap 2 detik
task.spawn(function()
    while MainFrame.Parent do -- Stop kalo UI di-close
        if _G.ESPToggled then
            local currentEggs = FindAllEggs()
            
            -- Tambah ESP ke telur baru
            for _, egg in ipairs(currentEggs) do
                CreateESP(egg)
            end
            
            -- Hapus data ESP telur yang udah ilang
            for egg, _ in pairs(espTable) do
                if not egg.Parent then
                    espTable[egg] = nil -- Hapus dari table aja, destroyer diurus Roblox
                end
            end
        else
            -- Pastikan bener-bener bersih kalo OFF
            if next(espTable) ~= nil then ClearAllESP() end
        end
        task.wait(2)
    end
end)

-- ==========================================
-- 3. LOGIKA HYBRID (GET-CLOSEST -> AUTO-WALK)
-- ==========================================
local currentEggIndex = 1
local cachedEggs = {}

-- Setup Fast Travel & Pathfinding
local FastTravelRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("FastTravel")
local WaypointsFolder = workspace:WaitForChild("Map"):WaitForChild("Waypoints")

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

-- Loop background update counter telor
task.spawn(function()
    while MainFrame.Parent do
        cachedEggs = FindAllEggs()
        if ServerCountLabel then
            ServerCountLabel.Text = "Server: " .. #cachedEggs
        end
        task.wait(1)
    end
end)

ActionBtn.MouseButton1Click:Connect(function()
    if _G.IsWorking then
        _G.IsWorking = false
        ActionBtn.Text = "STOPPING..."
        return
    end
    
    cachedEggs = FindAllEggs()
    if #cachedEggs == 0 then
        ActionBtn.Text = "KOSONG! Menunggu..."
        task.delay(1.5, function() if not _G.IsWorking then ActionBtn.Text = "AUTO-NGEGRAB (1x)" end end)
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
            _G.IsWorking = true
            ActionBtn.Text = "🛑 STOP"
            ActionBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
            
            task.spawn(function()
                -- [LANGKAH 1] HYBRID TP: Cek jarak & pake Fast Travel resmi
                local destWP = GetClosestWaypoint(targetPos)
                local sourceWP = GetClosestWaypoint(hrp.Position)
                
                if destWP and sourceWP and destWP ~= sourceWP then
                    ActionBtn.Text = "🛑 FT OTW..."
                    FastTravelRemote:FireServer(sourceWP, destWP)
                    -- Sedikit optimalisasi jeda (2.5 detik harusnya aman)
                    task.wait(2.5) 
                end
                
                -- Kalo lu belom pencet STOP pas loading FT
                if not _G.IsWorking then return end
                
                -- [LANGKAH 2] AI JALAN KAKI: Jarak udah deket, gass lari!
                ActionBtn.Text = "🛑 LARI..."
                
                local path = PathfindingService:CreatePath({
                    AgentRadius = 3, AgentHeight = 5, AgentCanJump = true, WaypointSpacing = 4
                })
                
                local success, errorMessage = pcall(function()
                    path:ComputeAsync(hrp.Position, targetPos)
                end)
                
                if success and path.Status == Enum.PathStatus.Success then
                    local waypoints = path:GetWaypoints()
                    
                    for i, wp in ipairs(waypoints) do
                        if not _G.IsWorking then break end
                        
                        -- Loncat otomatis
                        if wp.Action == Enum.PathWaypointAction.Jump then hum.Jump = true end
                        
                        -- MoveTo murni (100% legal di mata server)
                        hum:MoveTo(wp.Position)
                        
                        -- Nunggu nyampe titik sub-rute
                        local timeout = 2
                        local startTimer = tick()
                        repeat task.wait(0.1) until not _G.IsWorking or (hrp.Position - wp.Position).Magnitude < 3 or (tick() - startTimer) > timeout
                    end
                    
                    if _G.IsWorking then
                        _G.IsWorking = false
                        currentEggIndex = currentEggIndex + 1
                        
                        -- Senggol Bacok Virtual
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
                            if not _G.IsWorking then 
                                ActionBtn.Text = "AUTO-NGEGRAB (1x)" 
                                ActionBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
                            end
                        end)
                    end
                else
                    _G.IsWorking = false
                    ActionBtn.Text = "BUNTU!"
                    task.delay(2, function() ActionBtn.Text = "AUTO-NGEGRAB (1x)" end)
                end
            end)
        end
    end
end)

-- ==========================================
-- 4. CLEAN UP PAS CLOSE
-- ==========================================
CloseBtn.MouseButton1Click:Connect(function()
    _G.IsWorking = false
    ClearAllESP()
    ScreenGui:Destroy()
end)
