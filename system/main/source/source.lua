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

--// CustomUILib //--

local CustomUILib = {}

-- Mensagem de inicialização
print("CustomUILib inicializada com sucesso!")

-- Função para criar a janela principal
function CustomUILib:CreateWindow(config)
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local TitleBar = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local CloseButton = Instance.new("TextButton")
    
    -- Estilo do MainFrame (moderno, com bordas arredondadas e transparência)
    MainFrame.Size = UDim2.new(0, 500, 0, 350)
    MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    MainFrame.BackgroundTransparency = 0.15
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Parent = ScreenGui
    MainFrame.ClipsDescendants = true

    -- Adiciona bordas arredondadas
    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, 12)

    -- Título da Janela
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    TitleBar.Parent = MainFrame

    Title.Text = config.Name or "Custom UI"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextScaled = true
    Title.Parent = TitleBar

    -- Botão de Fechar
    CloseButton.Text = "X"
    CloseButton.Size = UDim2.new(0, 40, 1, 0)
    CloseButton.Position = UDim2.new(1, -40, 0, 0)
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    CloseButton.Parent = TitleBar

    CloseButton.MouseButton1Click:Connect(function()
        -- Fechar janela com confirmação
        if MainFrame.Visible then
            MainFrame.Visible = false
        else
            MainFrame.Visible = true
        end
    end)

    -- Função para criar uma aba
    function CustomUILib:MakeTab(tabConfig)
        local TabFrame = Instance.new("Frame")
        local TabButton = Instance.new("TextButton")
        
        -- Estilo do TabFrame
        TabFrame.Size = UDim2.new(1, 0, 1, 0)
        TabFrame.BackgroundTransparency = 1
        TabFrame.Visible = false
        TabFrame.Parent = MainFrame

        -- Estilo do botão da aba
        TabButton.Text = tabConfig.Name or "Aba"
        TabButton.Size = UDim2.new(0, 100, 0, 30)
        TabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        TabButton.TextColor3 = Color3.new(1, 1, 1)
        TabButton.Parent = TitleBar
        TabButton.Position = UDim2.new(0, 100 * #MainFrame:GetChildren(), 0, 0)

        TabButton.MouseButton1Click:Connect(function()
            -- Mostrar a aba selecionada e esconder as outras
            for _, v in pairs(MainFrame:GetChildren()) do
                if v:IsA("Frame") and v ~= TabFrame then
                    v.Visible = false
                end
            end
            TabFrame.Visible = true
        end)

        -- Função para adicionar botões
        function TabFrame:AddButton(buttonConfig)
            local Button = Instance.new("TextButton")
            Button.Text = buttonConfig.Name or "Button"
            Button.Size = UDim2.new(0, 200, 0, 40)
            Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Button.TextColor3 = Color3.new(1, 1, 1)
            Button.Parent = TabFrame

            Button.MouseButton1Click:Connect(function()
                print("Botão clicado:", Button.Text)
                buttonConfig.Callback()
            end)
        end

        -- Função para adicionar toggles
        function TabFrame:AddToggle(toggleConfig)
            local Toggle = Instance.new("TextButton")
            local State = toggleConfig.Default or false
            Toggle.Text = toggleConfig.Name .. ": " .. tostring(State)
            Toggle.Size = UDim2.new(0, 200, 0, 40)
            Toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Toggle.TextColor3 = Color3.new(1, 1, 1)
            Toggle.Parent = TabFrame

            Toggle.MouseButton1Click:Connect(function()
                State = not State
                Toggle.Text = toggleConfig.Name .. ": " .. tostring(State)
                print("Toggle alterado:", State)
                toggleConfig.Callback(State)
            end)
        end

        -- Função para adicionar picker de cores
        function TabFrame:AddColorPicker(colorConfig)
            local ColorPicker = Instance.new("TextButton")
            local Color = colorConfig.Default or Color3.fromRGB(255, 255, 255)
            ColorPicker.Text = colorConfig.Name
            ColorPicker.BackgroundColor3 = Color
            ColorPicker.Size = UDim2.new(0, 200, 0, 40)
            ColorPicker.Parent = TabFrame

            ColorPicker.MouseButton1Click:Connect(function()
                Color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
                ColorPicker.BackgroundColor3 = Color
                print("Cor selecionada:", Color)
                colorConfig.Callback(Color)
            end)
        end

        return TabFrame
    end

    -- Função para notificações
    function CustomUILib:Notify(notificationConfig)
        local Notification = Instance.new("TextLabel")
        Notification.Text = notificationConfig.Title .. ": " .. notificationConfig.Content
        Notification.Size = UDim2.new(0, 300, 0, 50)
        Notification.Position = UDim2.new(0.5, -150, 0, 0)
        Notification.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Notification.TextColor3 = Color3.new(1, 1, 1)
        Notification.TextScaled = true
        Notification.Parent = ScreenGui

                task.delay(notificationConfig.Duration or 3, function()
            Notification:Destroy()
            print("Notificação removida:", notificationConfig.Title)
        end)
    end

    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    return {
        MakeTab = function(self, tabConfig)
            return CustomUILib:MakeTab(tabConfig)
        end,
        Notify = function(self, notificationConfig)
            return CustomUILib:Notify(notificationConfig)
        end
    }
end

return CustomUILib
            
