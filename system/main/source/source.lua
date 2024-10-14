--// Seeker UI //--

local CustomUILib = {}

print("[ Seeker Logs ] 👋 Seeker inicializada com sucesso! Criada por Rhyan57.")

function CustomUILib:CreateMainMenu(titleText)
    local menu = Instance.new("ScreenGui")
    local mainFrame = Instance.new("Frame")
    local title = Instance.new("TextLabel")

    menu.Name = "Seeker UI V1"
    menu.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    mainFrame.Name = "MainFrame"
    mainFrame.Parent = menu
    mainFrame.Size = UDim2.new(0, 400, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BackgroundTransparency = 0.3
    mainFrame.BorderSizePixel = 0
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)

    title.Name = "text"
    title.Parent = mainFrame
    title.Text = titleText or "Seeker UI"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true

    return {
        MakeTab = function(self, tabConfig)
            return CustomUILib:CreateTab(mainFrame, tabConfig)
        end
    }
end

function CustomUILib:CreateTab(parent, tabConfig)
    local tabFrame = Instance.new("Frame")
    tabFrame.Name = tabConfig.Name
    tabFrame.Parent = parent
    tabFrame.Size = UDim2.new(1, 0, 1, -50)
    tabFrame.Position = UDim2.new(0, 0, 0, 50)
    tabFrame.BackgroundTransparency = 1

    return {
        AddButton = function(self, buttonConfig)
            return CustomUILib:AddButton(tabFrame, buttonConfig.Name, buttonConfig.Callback)
        end,
        AddNotification = function(self, notificationConfig)
            return CustomUILib:AddNotification(parent, notificationConfig.Message, notificationConfig.Duration)
        end,
        AddToggle = function(self, toggleConfig)
            return CustomUILib:AddToggle(tabFrame, toggleConfig.Name, toggleConfig.Default, toggleConfig.Callback)
        end,
        AddColorPicker = function(self, colorConfig)
            return CustomUILib:AddColorPicker(tabFrame, colorConfig.Default, colorConfig.Callback)
        end,
        AddParagraph = function(self, paragraphText)
            return CustomUILib:AddParagraph(tabFrame, paragraphText)
        end,
        AddTextInput = function(self, inputConfig)
            return CustomUILib:AddTextInput(tabFrame, inputConfig.Placeholder, inputConfig.Callback)
        end,
        AddDropdown = function(self, dropdownConfig)
            return CustomUILib:AddDropdown(tabFrame, dropdownConfig.Items, dropdownConfig.Callback)
        end
    }
end

function CustomUILib:AddButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Text = text
    button.Size = UDim2.new(1, 0, 0, 50)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Parent = parent
    button.MouseButton1Click:Connect(function()
        print("Botão '".. text .."' pressionado.")
        callback()
    end)
    return button
end

function CustomUILib:AddNotification(parent, message, duration)
    local notification = Instance.new("TextLabel")
    notification.Text = message
    notification.Size = UDim2.new(1, 0, 0, 50)
    notification.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    notification.TextColor3 = Color3.new(1, 1, 1)
    notification.TextScaled = true
    notification.Parent = parent

    task.delay(duration or 3, function()
        notification:Destroy()
        print("Notificação removida:", message)
    end)

    return notification
end

function CustomUILib:AddToggle(parent, text, default, callback)
    local toggle = Instance.new("TextButton")
    local state = default or false
    toggle.Text = text .. ": " .. tostring(state)
    toggle.Size = UDim2.new(1, 0, 0, 50)
    toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.Parent = parent
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = text .. ": " .. tostring(state)
        print("Toggle '".. text .."' alterado para: ".. tostring(state))
        callback(state)
    end)
    return toggle
end

function CustomUILib:AddColorPicker(parent, default, callback)
    local picker = Instance.new("TextButton")
    local color = default or Color3.new(1, 1, 1)
    picker.Text = "Selecionar cor"
    picker.BackgroundColor3 = color
    picker.Size = UDim2.new(1, 0, 0, 50)
    picker.Parent = parent
    picker.MouseButton1Click:Connect(function()
        color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
        picker.BackgroundColor3 = color
        print("Cor selecionada:", color)
        callback(color)
    end)
    return picker
end

function CustomUILib:AddTextInput(parent, placeholder, callback)
    local input = Instance.new("TextBox")
    input.PlaceholderText = placeholder
    input.Size = UDim2.new(1, 0, 0, 50)
    input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    input.TextColor3 = Color3.new(1, 1, 1)
    input.Parent = parent
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            print("Texto inserido: "..input.Text)
            callback(input.Text)
        end
    end)
    return input
end

function CustomUILib:AddDropdown(parent, items, callback)
    local dropdown = Instance.new("TextButton")
    local currentItem = items[1]
    dropdown.Text = "Selecionar: " .. currentItem
    dropdown.Size = UDim2.new(1, 0, 0, 50)
    dropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    dropdown.TextColor3 = Color3.new(1, 1, 1)
    dropdown.Parent = parent
    local dropdownOpened = false

    dropdown.MouseButton1Click:Connect(function()
        dropdownOpened = not dropdownOpened
        print("Dropdown aberto:", dropdownOpened)
        if dropdownOpened then
            for i, item in ipairs(items) do
                local itemButton = Instance.new("TextButton")
                itemButton.Text = item
                itemButton.Size = UDim2.new(1, 0, 0, 50)
                itemButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                                itemButton.TextColor3 = Color3.new(1, 1, 1)
                itemButton.Parent = parent
                itemButton.MouseButton1Click:Connect(function()
                    currentItem = item
                    dropdown.Text = "Selecionar: " .. currentItem
                    print("Item selecionado:", currentItem)
                    callback(currentItem)
                end)
            end
        else
            for _, child in ipairs(parent:GetChildren()) do
                if child:IsA("TextButton") and child ~= dropdown then
                    child:Destroy()
                end
            end
        end
    end)
    return dropdown
end

function CustomUILib:AddParagraph(parent, text)
    local paragraph = Instance.new("TextLabel")
    paragraph.Text = text
    paragraph.Size = UDim2.new(1, 0, 0, 50)
    paragraph.BackgroundTransparency = 1
    paragraph.TextColor3 = Color3.new(1, 1, 1)
    paragraph.TextScaled = true
    paragraph.Parent = parent
    return paragraph
end

function CustomUILib:AddNotification(parent, message, duration)
    local notification = Instance.new("TextLabel")
    notification.Text = message
    notification.Size = UDim2.new(1, 0, 0, 50)
    notification.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    notification.TextColor3 = Color3.new(1, 1, 1)
    notification.TextScaled = true
    notification.Parent = parent

    task.delay(duration or 3, function()
        notification:Destroy()
        print("Notificação removida:", message)
    end)

    return notification
end

return CustomUILib
