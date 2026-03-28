local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer

-- ==========================================
-- 1. BIKIN GUI DASAR
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ManualEggTeleporter"
ScreenGui.ResetOnSpawn = false

local success, target = pcall(function() return gethui() end)
if success and target then
    ScreenGui.Parent = target
else
    local coreSuccess = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not coreSuccess then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 130)
MainFrame.Position = UDim2.new(0.5, 150, 0.5, -65)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Bikin bisa di-drag
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
ServerCountLabel.TextSize = 14
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

-- ==========================================
-- 2. LOGIKA UTAMA
-- ==========================================
local isRunning = true
local currentEggIndex = 1
local cachedEggs = {}

-- Fungsi buat nyari semua telur yang ada di map
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

-- LOOP BACKGROUND: Cuma buat update teks jumlah telur di server
task.spawn(function()
    while isRunning do
        cachedEggs = FindAllEggs()
        if ServerCountLabel then
            ServerCountLabel.Text = "Telur di Server: " .. #cachedEggs
        end
        task.wait(1) -- Update counter tiap 1 detik
    end
end)

-- TOMBOL TELEPORT: Murni manual, dipencet baru jalan 1x
TpBtn.MouseButton1Click:Connect(function()
    -- Refresh list telur terbaru pas tombol dipencet
    cachedEggs = FindAllEggs()
    
    if #cachedEggs == 0 then
        TpBtn.Text = "KOSONG! Nunggu Spawn..."
        task.delay(2, function() TpBtn.Text = "TELEPORT (1x)" end)
        return
    end

    -- Kalo index kelewatan jumlah telur, balik ke telur pertama
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
            -- Teleport 3 studs di atas telur
            hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
            
            -- Majuin index buat target selanjutnya (kalo lu pencet tombolnya lagi)
            currentEggIndex = currentEggIndex + 1
            
            TpBtn.Text = "SUKSES TP!"
            task.delay(0.5, function() TpBtn.Text = "TELEPORT (1x)" end)
        end
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    isRunning = false
    ScreenGui:Destroy()
end)
