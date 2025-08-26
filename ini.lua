-- 📁 File: main.lua
-- Fish It Auto Tool - GUI dengan Tampilan Penuh LinoriaLib

-- ✅ Load LinoriaLib
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- ✅ Buat Window Utama
local Window = Library:CreateWindow({
    Title = 'Fish It Autofarm GUI',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Farming = Window:AddTab('Farming'),
    Teleport = Window:AddTab('Teleport'),
    ['UI Settings'] = Window:AddTab('UI Settings')
}

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:SetFolder('FishItAuto')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()

-- ✅ Flags
local autoPerfect, autoSell, autoTap = false, false, false
local chosenIsland = nil

-- ✅ Farming Tab (kiri)
local FarmLeft = Tabs.Farming:AddLeftGroupbox('Automation')
FarmLeft:AddToggle('AutoPerfect', {
    Text = '🎯 Auto Cast 2.0x',
    Default = false,
    Tooltip = 'Casting perfect dengan randomizer anti cheat',
    Callback = function(v) autoPerfect = v end
})
FarmLeft:AddToggle('AutoSell', {
    Text = '💰 Auto Sell (Non-Mythic)',
    Default = false,
    Tooltip = 'Jual semua ikan kecuali Mythic dan Unique',
    Callback = function(v) autoSell = v end
})
FarmLeft:AddToggle('AutoTap', {
    Text = '🐟 Auto Tap Button',
    Default = false,
    Tooltip = 'Klik otomatis pada tombol TAP layar',
    Callback = function(v) autoTap = v end
})

-- ✅ Farming Tab (kanan)
local FarmRight = Tabs.Farming:AddRightGroupbox('Kustomisasi Delay')
FarmRight:AddSlider('CastDelay', {
    Text = 'Delay Cast (ms)',
    Default = 120,
    Min = 50,
    Max = 300,
    Rounding = 0,
    Compact = false
})
FarmRight:AddSlider('TapDelay', {
    Text = 'Delay TAP (ms)',
    Default = 100,
    Min = 50,
    Max = 300,
    Rounding = 0,
    Compact = false
})

-- ✅ Teleport Tab
local TPLeft = Tabs.Teleport:AddLeftGroupbox('Daftar Pulau')
local islands = {
    ['Fisherman Island'] = Vector3.new(120, 20, -140),
    ['Snowcap Island'] = Vector3.new(385, 20, -120),
    ['Mystic Jungle'] = Vector3.new(730, 25, 90)
}
local islandNames = {}
for name, _ in pairs(islands) do table.insert(islandNames, name) end

TPLeft:AddDropdown('IslandPicker', {
    Values = islandNames,
    Default = 1,
    Text = 'Pilih Pulau',
    Tooltip = 'Klik teleport ke pulau',
    Callback = function(v) chosenIsland = v end
})
TPLeft:AddButton('🚀 Teleport Sekarang', function()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild('HumanoidRootPart') and chosenIsland then
        char.HumanoidRootPart.CFrame = CFrame.new(islands[chosenIsland])
    end
end)

-- ✅ Services dan Remotes
local RS = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local VIM = game:GetService('VirtualInputManager')
local net = RS.Packages._Index['sleitnick_net@0.2.0'].net
local miniGameRF = net:WaitForChild('RF/RequestFishingMinigameStarted')
local sellRF = net:WaitForChild('RF/SellItem')
local fishEvent = net:WaitForChild('RE/ObtainedNewFishNotification')

-- ✅ Hook: Auto 2.0x Cast
hookmetamethod(game, '__namecall', function(Self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    if Method == 'InvokeServer' and Self == miniGameRF and autoPerfect then
        local x = 0.5 + math.random(-3,3)*0.001
        local y = 2.0 + math.random()*0.03
        local delay = Library.Flags.CastDelay or 120
        task.wait(delay / 1000)
        return Self:InvokeServer(x, y)
    end
    return getrawmetatable(game).__namecall(Self, ...)
end)

-- ✅ Auto Sell Hook
fishEvent.OnClientEvent:Connect(function(_, _, data)
    if not autoSell then return end
    local item = data and data.InventoryItem
    if item and item.Rarity then
        local rarity = item.Rarity:lower()
        if not rarity:find('mythic') and not rarity:find('unique') then
            task.wait(0.2)
            sellRF:InvokeServer(item.UUID)
        end
    end
end)

-- ✅ Auto Tap Bulat
local function CreateTapButton()
    local gui = Instance.new('ScreenGui', game.CoreGui)
    gui.Name = 'TapButtonGUI'

    local btn = Instance.new('TextButton', gui)
    btn.Size = UDim2.new(0, 50, 0, 50)
    btn.Position = UDim2.new(0, 400, 0, 400)
    btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    btn.BackgroundTransparency = 0.5
    btn.Text = ''
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false

    Instance.new('UICorner', btn).CornerRadius = UDim.new(1, 0)

    local dragging, offset = false, Vector2.zero
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            offset = i.Position - btn.AbsolutePosition
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local newPos = i.Position - offset
            btn.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    task.spawn(function()
        while task.wait(0.1) do
            if not autoTap then continue end
            local pos = btn.AbsolutePosition
            local size = btn.AbsoluteSize
            local x = pos.X + size.X / 2
            local y = pos.Y + size.Y / 2
            local delay = Library.Flags.TapDelay or 100
            VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
            task.wait(0.02)
            VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
            task.wait(delay / 1000)
        end
    end)
end

CreateTapButton()
-- ✅ END
