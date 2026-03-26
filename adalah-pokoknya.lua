local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer

-- ==========================================
-- 1. BIKIN GUI DASAR & SISTEM MINIMIZE
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TreasureHunterGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true -- Biar aman di HP ga kena poni layar

-- Bypass masukin GUI (Support HP Executor)
local function ParentGUI()
    local success, target = pcall(function() return gethui() end)
    if success and target then
        pcall(function() ScreenGui.Parent = target end)
    end
    if not ScreenGui.Parent then
        pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    end
    if not ScreenGui.Parent then
        ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    end
end
ParentGUI()

-- Frame Utama
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 140)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -70)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Bikin GUI bisa digeser
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

-- Elemen UI di MainFrame
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "🗺️ Treasure Hunter"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 40)
Status.Position = UDim2.new(0, 10, 0, 35)
Status.BackgroundTransparency = 1
Status.Text = "Status: Idle\nMaps Completed: 0"
Status.TextColor3 = Color3.fromRGB(200, 200, 200)
Status.Font = Enum.Font.Gotham
Status.TextSize = 13
Status.Parent = MainFrame

local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(0, 100, 0, 35)
StartBtn.Position = UDim2.new(0, 15, 1, -45)
StartBtn.BackgroundColor3 = Color3.fromRGB(40, 187, 109)
StartBtn.Text = "START"
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.Font = Enum.Font.GothamBold
StartBtn.Parent = MainFrame
Instance.new("UICorner", StartBtn).CornerRadius = UDim.new(0, 6)

local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(0, 100, 0, 35)
StopBtn.Position = UDim2.new(1, -115, 1, -45)
StopBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 69)
StopBtn.Text = "STOP"
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.Font = Enum.Font.GothamBold
StopBtn.Parent = MainFrame
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 6)

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

-- Tombol Open (Buat buka pas lagi di-minimize)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 45, 0, 45)
OpenBtn.Position = UDim2.new(0, 15, 0.5, -22) -- Di pinggir kiri layar
OpenBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
OpenBtn.Text = "🗺️"
OpenBtn.TextSize = 20
OpenBtn.Visible = false -- Awalnya disembunyiin
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0) -- Bikin bulet
Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(255, 255, 255)

-- Logic Buka-Tutup (Minimize/Maximize)
MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenBtn.Visible = true
end)

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenBtn.Visible = false
end)


-- ==========================================
-- 2. LOGIKA TREASURE HUNTER (ANTI-FLICKER)
-- ==========================================
local TreasureHunter = {
    isHunting = false,
    mapsCompleted = 0
}

function TreasureHunter.UpdateStatus(text)
    Status.Text = text .. "\nMaps Completed: " .. TreasureHunter.mapsCompleted
end

function TreasureHunter.findNextMap()
    local character = Player.Character
    if character then
        for _, item in ipairs(character:GetChildren()) do
            if item:IsA("Tool") and item:GetAttribute("ItemType") == "TreasureMap" then
                return item
            end
        end
    end

    local backpack = Player:FindFirstChild("BackpackTwo")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:GetAttribute("ItemType") == "TreasureMap" then
                return item
            end
        end
    end
    return nil
end

function TreasureHunter.getPan()
    local character = Player.Character
    if not character then return nil end

    local equipped = character:FindFirstChildOfClass("Tool")
    if equipped and equipped:GetAttribute("ItemType") == "Pan" then
        return equipped
    end

    local backpack = Player:FindFirstChild("BackpackTwo")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:GetAttribute("ItemType") == "Pan" then
                pcall(function()
                    ReplicatedStorage.Remotes.CustomBackpack.EquipRemote:FireServer(item)
                end)
                task.wait(1)
                return item
            end
        end
    end
    return nil
end

function TreasureHunter.huntSingleMap(map, savedCFrame)
    local character = Player.Character
    -- Ditambahin ngecek Humanoid biar bisa ngatur speed
    if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then 
        warn("[TreasureHunter] Gagal: Tidak ada karakter/Humanoid")
        return false 
    end
    local hrp = character.HumanoidRootPart
    local humanoid = character.Humanoid

    local location = map:GetAttribute("Location")
    
    if not location then 
        return false 
    end

    local targetPosition = typeof(location) == "CFrame" and location.Position or location
    -- Y offset kita kurangin jadi 2.5 biar karakternya napak tanah, ga melayang
    local targetCFrame = CFrame.new(targetPosition + Vector3.new(0, 2.5, 0))

    local pan = TreasureHunter.getPan()
    if not pan then 
        TreasureHunter.UpdateStatus("Status: Error - No Pan")
        return false 
    end

    local collectScript = pan:FindFirstChild("Scripts") and pan.Scripts:FindFirstChild("Collect")
    if not collectScript then 
        return false 
    end

    TreasureHunter.UpdateStatus("Status: Digging...")

    -- AWAL GALI: Bikin napak tapi gabisa gerak
    hrp.CFrame = targetCFrame
    local oldWalkSpeed = humanoid.WalkSpeed
    local oldJumpPower = humanoid.JumpPower
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0

    local timeout = 120 
    local startTime = tick()
    local lastCollectTime = 0
    local success = false

    while TreasureHunter.isHunting and (tick() - startTime) < timeout do
        if not map or map.Parent == nil then
            success = true
            break
        end

        local backpackTwo = Player:FindFirstChild("BackpackTwo")
        local isStillOwned = (map.Parent == character) or 
                             (map.Parent == Player.Backpack) or 
                             (backpackTwo and map.Parent == backpackTwo)

        if not isStillOwned then
            success = true
            break
        end

        -- Trik anti-flicker tanpa Anchor: 
        -- Cek kalo karakter lu kegeser lebih dari 3 stud (ditarik server), baru kita paksa balik posisinya.
        -- Kalo ga kegeser jauh, biarin aja dia napak natural.
        if (hrp.Position - targetPosition).Magnitude > 3 then
            hrp.CFrame = targetCFrame
        end

        -- Tahan velocity X dan Z biar ga licin/geser-geser sendiri, tapi Y tetep ada biar jatoh (napak)
        hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)

        -- Gali tiap 0.2 detik
        if tick() - lastCollectTime > 0.2 then
            pcall(function()
                collectScript:InvokeServer(0)
            end)
            lastCollectTime = tick()
        end

        task.wait(0.05)
    end

    -- CLEANUP KELAR GALI: Balikin speed sama bisa lompat lagi
    humanoid.WalkSpeed = oldWalkSpeed
    humanoid.JumpPower = oldJumpPower
    
    -- Teleport balik ke koordinat awal
    if savedCFrame then
        hrp.CFrame = savedCFrame
    end

    return success
end

function TreasureHunter.Start()
    if TreasureHunter.isHunting then return end
    TreasureHunter.isHunting = true
    TreasureHunter.UpdateStatus("Status: Starting...")

    task.spawn(function()
        -- SIMPEN POSISI AWAL (XYZ) SEBELUM LOOPING
        local char = Player.Character
        local savedCFrame
        if char and char:FindFirstChild("HumanoidRootPart") then
            savedCFrame = char.HumanoidRootPart.CFrame
        end

        while TreasureHunter.isHunting do
            local map = TreasureHunter.findNextMap()

            if not map then
                TreasureHunter.UpdateStatus("Status: Waiting for Maps...")
                task.wait(1)
                continue
            end

            TreasureHunter.UpdateStatus("Status: Found Map!")
            
            -- Lempar posisi awal ke fungsi eksekutor
            local success = TreasureHunter.huntSingleMap(map, savedCFrame)

            if success then
                TreasureHunter.mapsCompleted = TreasureHunter.mapsCompleted + 1
                TreasureHunter.UpdateStatus("Status: Map Completed!")
                task.wait(1.5) -- Jeda bentar biar natural
            else
                TreasureHunter.UpdateStatus("Status: Stuck/Failed. Retrying...")
                task.wait(2)
            end
        end
        TreasureHunter.UpdateStatus("Status: Stopped")
    end)
end

function TreasureHunter.Stop()
    TreasureHunter.isHunting = false
    TreasureHunter.UpdateStatus("Status: Stopping...")
end

-- ==========================================
-- 3. KONEKSI TOMBOL UTAMA
-- ==========================================
StartBtn.MouseButton1Click:Connect(TreasureHunter.Start)

StopBtn.MouseButton1Click:Connect(TreasureHunter.Stop)

CloseBtn.MouseButton1Click:Connect(function()
    TreasureHunter.Stop()
    ScreenGui:Destroy()
end)
