local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

-- ==========================================
-- 1. BIKIN GUI DASAR & SISTEM MINIMIZE
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ManualEggTeleporterTween"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true 

-- Bypass UI buat semua jenis executor
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
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
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
Title.Text = "🥚 MANUAL TP EGG"
Title.TextColor3 = Color3.fromRGB(255, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
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
TpBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 180)
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
-- 2. LOGIKA TWEENING (TERBANG) KE TELUR
-- ==========================================
local isRunning = true
local currentEggIndex = 1
local cachedEggs = {}
local isFlying = false -- Mencegah tombol dipencet dobel pas lagi terbang

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

-- Background loop buat update jumlah telur di UI
task.spawn(function()
    while isRunning do
        cachedEggs = FindAllEggs()
        if ServerCountLabel then
            ServerCountLabel.Text = "Telur di Server ada: " .. #cachedEggs
        end
        task.wait(1)
    end
end)

-- ==========================================
-- 3. EKSEKUSI TWEENING
-- ==========================================
TpBtn.MouseButton1Click:Connect(function()
    if isFlying then return end -- Blokir klik kalo karakter masih OTW terbang
    
    cachedEggs = FindAllEggs()
    
    if #cachedEggs == 0 then
        TpBtn.Text = "KOSONG! Nunggu..."
        task.delay(1.5, function() 
            if not isFlying then TpBtn.Text = "TELEPORT (1x)" end
        end)
        return
    end

    if currentEggIndex > #cachedEggs then
        currentEggIndex = 1
    end

    local targetEgg = cachedEggs[currentEggIndex]
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hrp and targetEgg and targetEgg.Parent then
        local targetPos = nil
        if targetEgg:IsA("Model") then
            targetPos = targetEgg:GetPivot().Position
        elseif targetEgg:IsA("BasePart") then
            targetPos = targetEgg.Position
        end
        
        if targetPos then
            isFlying = true
            TpBtn.Text = "OTW TERBANG..."
            TpBtn.BackgroundColor3 = Color3.fromRGB(180, 120, 50)
            
            -- Teleport 3 studs di atas telur biar ga nyangkut di tanah
            local targetCFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
            local distance = (hrp.Position - targetPos).Magnitude
            
            -- Set kecepatan terbang (Studs per detik). 150 = ngebut tapi aman dari anti-cheat.
            local speed = 150
            local timeToReach = distance / speed
            
            -- Kalo jaraknya udah deket, langsung sekejap aja (0.1 detik)
            if distance < 50 then
                timeToReach = 0.1
            end

            -- Bikin efek terbang nembus map
            local tweenInfo = TweenInfo.new(timeToReach, Enum.EasingStyle.Linear)
            local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
            
            -- Bekuin fisika karakter biar bisa ngesot terbang mulus nembus halangan
            hrp.Anchored = true
            tween:Play()
            
            -- Tunggu sampe karakter mendarat di telur
            tween.Completed:Connect(function()
                hrp.Anchored = false -- Balikin fisika normal biar bisa gerak lagi
                isFlying = false
                currentEggIndex = currentEggIndex + 1
                
                TpBtn.Text = "SUKSES TP!"
                TpBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
                
                task.delay(0.8, function() 
                    if not isFlying then 
                        TpBtn.Text = "TELEPORT (1x)" 
                        TpBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 180)
                    end
                end)
            end)
        end
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    isRunning = false
    ScreenGui:Destroy()
end)
