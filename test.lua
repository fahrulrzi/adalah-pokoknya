-- ==========================================
-- BAREBONES LOADER (TANPA KEY SYSTEM)
-- ==========================================

local TargetGameID = 129827112113663 -- ID Game lu kemaren

-- 1. CEK ID GAME
if game.PlaceId ~= TargetGameID then
    game.Players.LocalPlayer:Kick("❌ SALAH GAME NGAB! Script ini khusus buat game Telur.")
    return -- Stop eksekusi kalo salah game
end

-- Kalo bener, kasih notif biar lu tau Loadernya berhasil jalan
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Loader Aktif",
        Text = "Game ID Valid! OTW manggil Script Utama...",
        Duration = 3
    })
end)

print("✅ Game Valid! Memanggil Script V8...")

-- 2. PANGGIL SCRIPT UTAMA (V8)
-- Pastikan isi dari link ini adalah script V8 PURE yang udah lu benerin kemaren
local success, err = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/KuliJawa-Maker/ojis/refs/heads/main/game/129827112113663.lua"))()
end)

-- Kalo linknya mati atau gagal ke-load, kasih tau errornya
if not success then
    warn("❌ Gagal manggil script V8! Error: " .. tostring(err))
end
