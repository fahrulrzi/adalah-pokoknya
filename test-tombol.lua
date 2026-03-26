local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Bikin GUI kecil buat Kill Switch (Tombol Stop)
local SpyGui = Instance.new("ScreenGui")
SpyGui.Name = "UISpyGUI"
SpyGui.ResetOnSpawn = false

-- Bypass executor GUI
local success, target = pcall(function() return gethui() end)
if success and target then
    pcall(function() SpyGui.Parent = target end)
else
    local coreSuccess = pcall(function() SpyGui.Parent = game:GetService("CoreGui") end)
    if not coreSuccess then SpyGui.Parent = PlayerGui end
end

local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(0, 120, 0, 35)
StopBtn.Position = UDim2.new(0.5, -60, 0, 10) -- Di tengah atas layar
StopBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
StopBtn.Text = "🛑 STOP SPY"
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.Font = Enum.Font.GothamBold
StopBtn.Parent = SpyGui
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 6)

-- Tempat nyimpen semua koneksi sensor biar bisa dimatiin barengan
local connections = {}

print("🕵️ Spy UI Aktif! Silakan klik tombol Auto Pan-nya...")

-- Fungsi buat nempelin sensor dan nyatet koneksinya
local function attachSpy(button)
    if button:IsA("GuiButton") then
        local conn = button.MouseButton1Click:Connect(function()
            print("====================================")
            print("👉 LOG SPY DITEMUKAN!")
            print("Nama Tombol: " .. button.Name)
            print("Path UI    : " .. button:GetFullName())
            print("====================================")
        end)
        table.insert(connections, conn) -- Simpen sensornya ke daftar
    end
end

-- 1. Tempelin ke semua UI yang udah ada
for _, child in ipairs(PlayerGui:GetDescendants()) do
    attachSpy(child)
end

-- 2. Tempelin ke UI yang baru muncul (kayak menu pop-up)
local addedConn = PlayerGui.DescendantAdded:Connect(function(newChild)
    attachSpy(newChild)
end)
table.insert(connections, addedConn)

-- 3. LOGIKA TOMBOL STOP (KILL SWITCH)
StopBtn.MouseButton1Click:Connect(function()
    -- Matiin semua sensor satu-satu
    for _, conn in ipairs(connections) do
        if conn.Connected then
            conn:Disconnect()
        end
    end
    table.clear(connections) -- Kosongin daftarnya
    
    print("🛑 Spy UI berhasil dimatiin! Koneksi terputus. Game lu aman dari lag.")
    SpyGui:Destroy() -- Ilangin tombol stop dari layar
end)
