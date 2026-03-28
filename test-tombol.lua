local player = game:GetService("Players").LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- Bikin UI Tombol Stop
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScannerUI"
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
StopBtn.Text = "🛑 STOP SCANNER"
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 14
StopBtn.Parent = ScreenGui
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 8)

local isScanning = true
local alreadyPrinted = {} -- Biar ga nyepam objek yang sama berkali-kali

print("=================================")
print("🔍 REAL-TIME SCANNER AKTIF!")
print("Silakan jalan keliling deketin itemnya...")
print("=================================")

-- Looping Scanner yang jalan di background
task.spawn(function()
    while isScanning do
        -- Update karakter kalo misal lu mati/respawn
        if not char or not hrp or not hrp.Parent then
            char = player.Character
            hrp = char and char:FindFirstChild("HumanoidRootPart")
        end

        if hrp then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if not isScanning then break end -- Langsung stop loop kalo tombol dipencet

                if obj:IsA("Model") or obj:IsA("BasePart") then
                    local pos = nil
                    
                    if obj:IsA("Model") and obj.PrimaryPart then
                        pos = obj.PrimaryPart.Position
                    elseif obj:IsA("BasePart") then
                        pos = obj.Position
                    elseif obj:IsA("Model") then
                        pos = obj:GetPivot().Position
                    end

                    if pos then
                        local dist = (hrp.Position - pos).Magnitude
                        -- Cek kalo jaraknya deket (15 studs)
                        if dist <= 15 then
                            if not obj:IsDescendantOf(char) and not obj:IsDescendantOf(workspace.CurrentCamera) and obj.Name ~= "Baseplate" and obj.Name ~= "Terrain" then
                                
                                local topParent = obj
                                if obj.Parent ~= workspace and obj.Parent.Name ~= "Map" then
                                    topParent = obj.Parent
                                end

                                -- Kalo objeknya belom pernah kecatet, baru di-print
                                if not alreadyPrinted[topParent] then
                                    alreadyPrinted[topParent] = true
                                    print("📦 NAMA OBJEK : " .. topParent.Name)
                                    print("📁 FOLDER     : " .. (topParent.Parent and topParent.Parent.Name or "Workspace"))
                                    print("📏 JARAK      : " .. math.floor(dist) .. " studs")
                                    print("---------------------------------")
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(1) -- Scan tiap 1 detik aja biar HP/PC lu ga meleduk
    end
end)

-- Kalo tombol Stop dipencet
StopBtn.MouseButton1Click:Connect(function()
    isScanning = false
    print("✅ SCANNER DIMATIKAN! Silakan cek hasil log di atas.")
    ScreenGui:Destroy()
end)
