local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui", 5)

if PlayerGui then
    -- Memaksa layar jadi Landscape (memanjang) dan otomatis ngikutin sensor
    PlayerGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor
    
    -- Kasih notif biar ketahuan scriptnya jalan
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Rotasi Sukses",
            Text = "Layar udah dipaksa jadi Landscape ngab!",
            Duration = 3
        })
    end)
else
    warn("Gagal nemuin PlayerGui cuy!")
end
