-- Ссылка на Библиотеку
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Robojini/Tuturial_UI_Library/main/UI_Template_1"))()

-- Создать окно UI
local Window = Library.CreateLib("AutoFarm", "RJTheme3")

-- Секция
local Tab = Window:NewTab("Main")

-- Подсекция
local Section = Tab:NewSection("Auto Farm Settings")

-- Переменные
local autoFarmEnabled = false
local farmConnection
local maxBackpack = 0

-- Текстовое поле для ввода макс. бэкпака
Section:NewTextBox("Max Backpack", "Введите максимальную вместимость бэкпака", function(txt)
    maxBackpack = tonumber(txt) or 0
    print("Макс. бэкпак установлен: " .. maxBackpack)
end)

-- Функция получения ресурсов
local function getResources()
    local player = game.Players.LocalPlayer
    local stones = player:FindFirstChild("Stones")
    local bricks = player:FindFirstChild("Bricks")
    
    local stoneValue = stones and stones.Value or 0
    local brickValue = bricks and bricks.Value or 0
    
    return stoneValue, brickValue
end

-- Функция проверки заполненности бэкпака
local function isBackpackFull()
    local stone, brick = getResources()
    local total = stone + brick
    return total >= maxBackpack
end

-- Функция для нажатия E
local function pressE()
    local virtualInput = game:GetService("VirtualInputManager")
    virtualInput:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    virtualInput:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- Функция телепорта к координатам точилки
local function teleportToSawCoordinates()
    local character = game.Players.LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(
            40.8491211, 3.00899982, -21.5196381,
            0.00261973077, 9.56846868e-09, 0.999996543,
            6.81581582e-08, 1, -9.74705827e-09,
            -0.999996543, 6.81834607e-08, 0.00261973077
        )
        return true
    end
    return false
end

-- Функция телепорта к камню
local function teleportToStone()
    local character = game.Players.LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(
            53.959671, 3.00266671, -21.616888,
            -0.00351829501, -0.00140307471, -0.999992847,
            0.000359030149, 0.999998927, -0.00140434643,
            0.999993742, -0.000363968458, -0.00351778767
        )
        return true
    end
    return false
end

-- Основная функция автофарма
local function startAutoFarm()
    autoFarmEnabled = true
    
    farmConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not autoFarmEnabled then return end
        
        local character = game.Players.LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        
        local stone, brick = getResources()
        
        -- Проверяем заполненность бэкпака
        if isBackpackFull() then
            print("Бэкпак полный! Нельзя положить больше ресурсов")
            return
        end
        
        -- Логика фарма
        if stone > 0 then
            -- Если есть камни, точим их на координатах
            if teleportToSawCoordinates() then
                pressE()
                wait(0.1)
            end
        else
            -- Если камней нет, фармим новые
            if teleportToStone() then
                pcall(function()
                    game:GetService("ReplicatedStorage").KickStone:InvokeServer(true)
                end)
                wait(0.1)
            end
        end
        
        -- Строим если есть кирпичи
        if brick > 0 then
            pcall(function()
                game:GetService("ReplicatedStorage").Place:InvokeServer(workspace.Floors.Base.Example.Part)
            end)
        end
    end)
end

-- Функция остановки
local function stopAutoFarm()
    autoFarmEnabled = false
    if farmConnection then
        farmConnection:Disconnect()
        farmConnection = nil
    end
end

-- Кнопка вкл/выкл автофарма
Section:NewToggle("Auto Farm", "Включает умный автофарм", function(state)
    if state then
        if maxBackpack == 0 then
            Library:Notify("Сначала установите макс. бэкпак!")
            return
        end
        startAutoFarm()
    else
        stopAutoFarm()
    end
end)

-- Секция информации
local InfoSection = Tab:NewSection("Resource Info")

-- Метка для отображения ресурсов
local resourceText = "Ожидание..."
local resourceLabel = InfoSection:NewLabel(resourceText)

-- Обновление информации о ресурсах
game:GetService("RunService").Heartbeat:Connect(function()
    local stone, brick = getResources()
    local total = stone + brick
    local backpackStatus = ""
    
    if maxBackpack > 0 then
        if isBackpackFull() then
            backpackStatus = " | БЭКПАК ПОЛНЫЙ! ⚠️"
        else
            backpackStatus = " | Бэкпак: " .. total .. "/" .. maxBackpack
        end
    end
    
    resourceText = "Камни: " .. stone .. " | Кирпичи: " .. brick .. backpackStatus
    resourceLabel:UpdateLabel(resourceText)
end)

-- Отдельные кнопки для ручного управления
local ManualSection = Tab:NewSection("Manual Controls")

ManualSection:NewButton("TP to Saw Coords + E", "Телепорт к координатам точилки и E", function()
    if teleportToSawCoordinates() then
        pressE()
    end
end)

ManualSection:NewButton("TP to Stone", "Телепорт к камню", function()
    teleportToStone()
end)

ManualSection:NewButton("Kick Stone", "Ударить камень", function()
    pcall(function()
        game:GetService("ReplicatedStorage").KickStone:InvokeServer(true)
    end)
end)

ManualSection:NewButton("Build Part", "Построить часть", function()
    pcall(function()
        game:GetService("ReplicatedStorage").Place:InvokeServer(workspace.Floors.Base.Example.Part)
    end)
end)

print("AutoFarm loaded! Set max backpack capacity first.")