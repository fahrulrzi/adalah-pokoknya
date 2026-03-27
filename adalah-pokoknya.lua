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
ScreenGui.IgnoreGuiInset = true 

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

-- Frame Utama (Tingginya gw tambahin jadi 180 biar muat tombol Set Home)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 180) 
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -90)
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

-- Tombol SET HOME Baru
local SetHomeBtn = Instance.new("TextButton")
SetHomeBtn.Size = UDim2.new(1, -30, 0, 30)
SetHomeBtn.Position = UDim2.new(0, 15, 1, -85) -- Posisinya di atas Start & Stop
SetHomeBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 210)
SetHomeBtn.Text = "SET HOME POS"
SetHomeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SetHomeBtn.Font = Enum.Font.GothamBold
SetHomeBtn.Parent = MainFrame
Instance.new("UICorner", SetHomeBtn).CornerRadius = UDim.new(0, 6)

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

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 45, 0, 45)
OpenBtn.Position = UDim2.new(0, 15, 0.5, -22)
OpenBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
OpenBtn.Text = "🗺️"
OpenBtn.TextSize = 20
OpenBtn.Visible = false
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(255, 255, 255)

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenBtn.Visible = true
end)

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenBtn.Visible = false
end)


-- ==========================================
-- 2. LOGIKA TREASURE HUNTER (WITH HOME POS & AUTO PAN FIX)
-- ==========================================
local TreasureHunter = {
    isHunting = false,
    mapsCompleted = 0,
    homeCFrame = nil 
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

-- Fungsi Reset Auto Pan versi Cabut-Colok
function TreasureHunter.ResetAutoPan(pan)
    -- 1. Copot Pan (Toggle Unequip pake remote bawaan gamenya)
    if pan then
        print("[TreasureHunter] Mencopot Pan biar Auto kereset OFF...")
        pcall(function()
            ReplicatedStorage.Remotes.CustomBackpack.EquipRemote:FireServer(pan)
        end)
        task.wait(0.8) -- Kasih jeda lumayan biar server beneran masukin ke tas
    end
    
    -- 2. Pegang lagi Pan-nya
    print("[TreasureHunter] Equip ulang Pan...")
    local newPan = TreasureHunter.getPan()
    task.wait(0.8) -- Tunggu UI MobileDig muncul lagi di layar
    
    -- 3. Karena sekarang PASTI OFF, kita tembak 1x biar jadi ON
    local playerGui = Player:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    local toolUI = playerGui:FindFirstChild("ToolUI")
    if toolUI then
        local mobileDig = toolUI:FindFirstChild("MobileDig")
        if mobileDig then
            local autoBtn = mobileDig:FindFirstChild("AutoButton")
            
            if autoBtn then
                print("[TreasureHunter] Nembak tombol Auto Pan 1x biar langsung ON!")
                pcall(function()
                    if firesignal then
                        firesignal(autoBtn.MouseButton1Click)
                    elseif getconnections then
                        for _, conn in ipairs(getconnections(autoBtn.MouseButton1Click)) do
                            conn:Function()
                        end
                    end
                end)
            end
        end
    end
end

function TreasureHunter.huntSingleMap(map)
    local character = Player.Character
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

        if (hrp.Position - targetPosition).Magnitude > 3 then
            hrp.CFrame = targetCFrame
        end

        hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)

        if tick() - lastCollectTime > 0.2 then
            pcall(function()
                collectScript:InvokeServer(0)
            end)
            lastCollectTime = tick()
        end

        task.wait(0.05)
    end

    -- Balikin movement
    humanoid.WalkSpeed = oldWalkSpeed
    humanoid.JumpPower = oldJumpPower
    
    -- TELEPORT BALIK KE HOME (Maksa 3x biar server pasrah)
    if TreasureHunter.homeCFrame then
        for i = 1, 3 do
            hrp.CFrame = TreasureHunter.homeCFrame
            task.wait(0.1)
        end
    end

    -- RESET AUTO PAN PAKE JURUS CABUT-COLOK
    task.wait(0.5)
    TreasureHunter.ResetAutoPan(pan) -- pan-nya diselipin ke sini

    return success
end

function TreasureHunter.Start()
    if TreasureHunter.isHunting then return end
    TreasureHunter.isHunting = true
    
    if not TreasureHunter.homeCFrame then
        local char = Player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            TreasureHunter.homeCFrame = char.HumanoidRootPart.CFrame
        end
    end

    TreasureHunter.UpdateStatus("Status: Starting...")

    task.spawn(function()
        while TreasureHunter.isHunting do
            local map = TreasureHunter.findNextMap()

            if not map then
                TreasureHunter.UpdateStatus("Status: Waiting for Maps...")
                task.wait(1)
                continue
            end

            TreasureHunter.UpdateStatus("Status: Found Map!")
            
            local success = TreasureHunter.huntSingleMap(map)

            if success then
                TreasureHunter.mapsCompleted = TreasureHunter.mapsCompleted + 1
                TreasureHunter.UpdateStatus("Status: Map Completed!")
                task.wait(1.5) 
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
SetHomeBtn.MouseButton1Click:Connect(function()
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        TreasureHunter.homeCFrame = char.HumanoidRootPart.CFrame
        TreasureHunter.UpdateStatus("Status: Home Set! Ready to Farm.")
    end
end)

StartBtn.MouseButton1Click:Connect(TreasureHunter.Start)

StopBtn.MouseButton1Click:Connect(TreasureHunter.Stop)

CloseBtn.MouseButton1Click:Connect(function()
    TreasureHunter.Stop()
    ScreenGui:Destroy()
end)
