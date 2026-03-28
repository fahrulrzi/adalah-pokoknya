local player = game:GetService("Players").LocalPlayer

-- ==========================================
-- BIKIN UI TOMBOL STOP
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XRayScannerUI"
ScreenGui.ResetOnSpawn = false

-- Bypass executor GUI
local success, target = pcall(function() return gethui() end)
if success and target then
    ScreenGui.Parent = target
else
    local coreSuccess = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not coreSuccess then ScreenGui.Parent = player:WaitForChild("PlayerGui") end
end

local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(0, 150, 0, 40)
StopBtn.Position = UDim2.new(0.5, -75, 0, 20) -- Di tengah atas layar
StopBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
StopBtn.Text = "🛑 STOP X-RAY"
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 14
StopBtn.Parent = ScreenGui
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 8)

-- ==========================================
-- LOGIKA X-RAY
-- ==========================================
local isScanning = true
local scannedEggs = {} -- Biar ga nyepam telur yang sama

print("===============================")
print("🥚 X-RAY SCANNER AKTIF!")
print("Nungguin telor spawn buat dibongkar jeroannya...")
print("===============================")

task.spawn(function()
    while isScanning do
        -- Cari telur di workspace
        for _, obj in ipairs(workspace:GetDescendants()) do
            if not isScanning then break end
            
            if obj.Name == "EasterEgg" then
                -- Cek biar ga nyepam log buat telur yang sama
                if not scannedEggs[obj] then
                    scannedEggs[obj] = true
                    
                    print("===============================")
                    print("🥚 BONGKAR JEROAN EASTER EGG:")
                    print("Path: " .. obj:GetFullName())
                    print("-------------------------------")
                    
                    local items = obj:GetDescendants()
                    if #items == 0 then
                        print("Telurnya kosong melompong (ga ada child).")
                    else
                        for _, v in ipairs(items) do
                            print(" - [" .. v.ClassName .. "] " .. v.Name)
                        end
                    end
                    print("===============================")
                end
            end
        end
        task.wait(1) -- Cek tiap 1 detik
    end
end)

-- ==========================================
-- KONEKSI TOMBOL STOP
-- ==========================================
StopBtn.MouseButton1Click:Connect(function()
    isScanning = false
    print("✅ X-RAY SCANNER DIMATIKAN!")
    ScreenGui:Destroy()
end)
