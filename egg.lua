local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer

-- ==========================================
-- 1. BIKIN GUI DASAR & SISTEM MINIMIZE
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EasterEggHunterGUI"
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

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 140)
MainFrame.Position = UDim2.new(0.5, 130, 0.5, -70) -- Gw geser dikit ke kanan biar ga numpuk kalo lu buka bareng script lain
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 20, 40) -- Warna agak ungu biar beda tema
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
Title.Text = "🥚 Easter Egg Hunter"
Title.TextColor3 = Color3.fromRGB(255, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 40)
Status.Position = UDim2.new(0, 10, 0, 35)
Status.BackgroundTransparency = 1
Status.Text = "Status: Idle\nEggs Collected: 0"
Status.TextColor3 = Color3.fromRGB(200, 200, 200)
Status.Font = Enum.Font.Gotham
Status.TextSize = 13
Status.Parent = MainFrame

local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(0, 100, 0, 35)
StartBtn.Position = UDim2.new(0, 15, 1, -45)
StartBtn.BackgroundColor3 = Color3.fromRGB(150, 80, 200)
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
OpenBtn.Position = UDim2.new(1, -60, 0.5, -22) -- Di pinggir kanan layar biar ga nabrak tombol map
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
-- 2. LOGIKA EASTER EGG HUNTER
-- ==========================================
local EggHunter = {
    isHunting = false,
    eggsCollected = 0
}

function EggHunter.UpdateStatus(text)
    Status.Text = text .. "\nEggs Collected: " .. EggHunter.eggsCollected
end

function EggHunter.FindEggs()
    local foundEggs = {}
    -- Fokus nyari di dalem folder Geode biar ga berat nyecan seluruh map
    local geodeFolder = workspace:FindFirstChild("Geode")
    
    if geodeFolder then
        for _, obj in ipairs(geodeFolder:GetChildren()) do
            if obj.Name == "EasterEgg" then
                table.insert(foundEggs, obj)
            end
        end
    else
        -- Backup plan kalo folder Geode ga ada
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "EasterEgg" then
                table.insert(foundEggs, obj)
            end
        end
    end
    
    return foundEggs
end

function EggHunter.Start()
    if EggHunter.isHunting then return end
    EggHunter.isHunting = true
    EggHunter.UpdateStatus("Status: Starting...")

    task.spawn(function()
        while EggHunter.isHunting do
            local eggs = EggHunter.FindEggs()

            if #eggs == 0 then
                EggHunter.UpdateStatus("Status: Waiting for Eggs...")
                task.wait(2) -- Jeda nunggu telurnya spawn lagi
                continue
            end

            for i, egg in ipairs(eggs) do
                if not EggHunter.isHunting then break end
                
                -- Pastikan telurnya belum di-collect orang lain
                if not egg or not egg.Parent then continue end

                local char = Player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                
                if hrp then
                    local targetPos = nil
                    if egg:IsA("Model") then
                        targetPos = egg:GetPivot().Position
                    elseif egg:IsA("BasePart") then
                        targetPos = egg.Position
                    end
                    
                    if targetPos then
                        EggHunter.UpdateStatus("Status: Collecting... ("..i.."/"..#eggs..")")
                        
                        -- Teleport ke atas telur persis (biar nyenggol hitboxnya)
                        local targetCFrame = CFrame.new(targetPos + Vector3.new(0, 1.5, 0))
                        
                        -- Anti-flicker teleport (paksa 3x biar server nerima posisinya)
                        for j = 1, 3 do
                            hrp.CFrame = targetCFrame
                            hrp.Velocity = Vector3.zero
                            task.wait(0.05)
                        end
                        
                        -- Tunggu bentar biar server ngasih itemnya ke tas lu
                        task.wait(0.3)
                        
                        -- Kalo objeknya hancur/ilang, berarti berhasil ke-collect
                        if not egg or not egg.Parent then
                            EggHunter.eggsCollected = EggHunter.eggsCollected + 1
                        end
                    end
                end
            end
            task.wait(0.5) -- Jeda bentar sebelum nyari telur ronde selanjutnya
        end
        EggHunter.UpdateStatus("Status: Stopped")
    end)
end

function EggHunter.Stop()
    EggHunter.isHunting = false
    EggHunter.UpdateStatus("Status: Stopping...")
end

-- ==========================================
-- 3. KONEKSI TOMBOL
-- ==========================================
StartBtn.MouseButton1Click:Connect(EggHunter.Start)
StopBtn.MouseButton1Click:Connect(EggHunter.Stop)
CloseBtn.MouseButton1Click:Connect(function()
    EggHunter.Stop()
    ScreenGui:Destroy()
end)
