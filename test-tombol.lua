local player = game:GetService("Players").LocalPlayer

-- ==========================================
-- 1. BIKIN UI TOMBOL STOP
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportSpyUI"
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
StopBtn.Text = "🛑 STOP SPY"
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 14
StopBtn.Parent = ScreenGui
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 8)

-- ==========================================
-- 2. LOGIKA PENYADAP (METATABLE HOOK)
-- ==========================================
local isSpying = true
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall

-- Buka gembok metatable biar bisa disadap
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    -- Kalo tombol stop udah dipencet, biarin game jalan normal tanpa disadap
    if not isSpying then
        return oldNamecall(self, ...)
    end

    local method = getnamecallmethod()
    local args = {...}
    
    -- Kita cuma nyadap komunikasi Client ke Server
    if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
        
        -- Filter kata kunci yang berhubungan sama pindah tempat
        local name = string.lower(self.Name)
        local parentName = self.Parent and string.lower(self.Parent.Name) or ""
        
        if name:find("teleport") or name:find("travel") or name:find("spawn") or name:find("move") or parentName:find("location") then
            print("=========================================")
            print("🚨 SURAT IZIN TELEPORT TERDETEKSI 🚨")
            print("Remote Name : " .. self.Name)
            print("Remote Path : " .. self:GetFullName())
            print("Method      : " .. method)
            print("--- ISI SURAT (ARGUMENTS) ---")
            
            if #args == 0 then
                print(" - Kosong (Ga bawa data apa-apa)")
            else
                for i, v in ipairs(args) do
                    local valType = typeof(v)
                    local valStr = tostring(v)
                    
                    -- Kalo isinya objek, print nama objek/path-nya biar kita tau
                    if valType == "Instance" then
                        valStr = v:GetFullName()
                    end
                    
                    print(" ["..i.."] = " .. valStr .. " (Tipe: " .. valType .. ")")
                end
            end
            print("=========================================")
        end
    end
    
    -- Lanjutin proses aslinya biar game ga error
    return oldNamecall(self, ...)
end)

setreadonly(mt, true)
print("✅ PENYADAP TELEPORT AKTIF! Silakan pake fitur Fast Travel / masuk portal di dalem game sekarang.")

-- ==========================================
-- 3. KONEKSI TOMBOL STOP
-- ==========================================
StopBtn.MouseButton1Click:Connect(function()
    isSpying = false
    print("✅ TELEPORT SPY DIMATIKAN! Cek log F9 lu.")
    ScreenGui:Destroy()
end)
