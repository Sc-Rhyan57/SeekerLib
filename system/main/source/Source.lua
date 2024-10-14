local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Lib = {
    Elements = {},
    ThemeObjects = {},
    Connections = {},
    Flags = {},
    Themes = {
        Default = {
            Background = Color3.fromRGB(35, 35, 35),
            Frame = Color3.fromRGB(45, 45, 45),
            Accent = Color3.fromRGB(0, 122, 204),
            Text = Color3.fromRGB(255, 255, 255),
            TextDark = Color3.fromRGB(200, 200, 200),
            Stroke = Color3.fromRGB(60, 60, 60),
            Divider = Color3.fromRGB(80, 80, 80)
        }
    },
    SelectedTheme = "Default"
}

-- Function to create new UI elements
function Lib:CreateElement(type, properties, children)
    local element = Instance.new(type)
    for prop, val in pairs(properties) do
        element[prop] = val
    end
    for _, child in pairs(children or {}) do
        child.Parent = element
    end
    return element
end

-- Function to add themes to elements
function Lib:AddThemeObject(object, type)
    if not self.ThemeObjects[type] then
        self.ThemeObjects[type] = {}
    end
    table.insert(self.ThemeObjects[type], object)
    object.BackgroundColor3 = self.Themes[self.SelectedTheme][type] or Color3.fromRGB(255, 255, 255)
end

-- Function to add spacing between elements
function Lib:AddSpacing(parent, amount)
    local spacing = Instance.new("Frame")
    spacing.Size = UDim2.new(1, 0, 0, amount or 10)
    spacing.BackgroundTransparency = 1
    spacing.Parent = parent
end

-- Core Function: Create a new window
function Lib:CreateWindow(windowConfig)
    windowConfig = windowConfig or {}

    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = self:CreateElement("Frame", {
        BackgroundColor3 = self.Themes.Default.Background,
        Size = UDim2.new(0, 700, 0, 400),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Parent = ScreenGui
    })

    -- Rounded corners for modern UI
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame

    -- Title Bar
    local TitleBar = self:CreateElement("TextLabel", {
        Text = windowConfig.Title or "Modern UI",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        TextColor3 = self.Themes.Default.Text,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Parent = MainFrame
    })

    -- Sidebar for pages
    local Sidebar = self:CreateElement("Frame", {
        BackgroundColor3 = self.Themes.Default.Frame,
        Size = UDim2.new(0, 150, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        Parent = MainFrame
    })

    -- Rounded corners for sidebar
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 10)
    SidebarCorner.Parent = Sidebar

    -- Main content area
    local ContentArea = self:CreateElement("Frame", {
        BackgroundColor3 = self.Themes.Default.Frame,
        Size = UDim2.new(1, -150, 1, -40),
        Position = UDim2.new(0, 150, 0, 40),
        Parent = MainFrame
    })

    -- Rounded corners for content area
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 10)
    ContentCorner.Parent = ContentArea

    -- Layout for sidebar buttons
    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.Padding = UDim.new(0, 5)
    SidebarLayout.Parent = Sidebar

    -- Add theme to elements
    self:AddThemeObject(MainFrame, "Background")
    self:AddThemeObject(Sidebar, "Frame")
    self:AddThemeObject(ContentArea, "Frame")
    self:AddThemeObject(TitleBar, "Text")

    ScreenGui.Parent = game.CoreGui
    return {MainFrame = MainFrame, Sidebar = Sidebar, ContentArea = ContentArea}
end

-- Create a new page/tab
function Lib:CreatePage(window, pageConfig)
    pageConfig = pageConfig or {}

    -- Page button in the sidebar
    local PageButton = self:CreateElement("TextButton", {
        Text = pageConfig.Name or "Page",
        Size = UDim2.new(1, -10, 0, 40),
        BackgroundColor3 = self.Themes.Default.Accent,
        TextColor3 = self.Themes.Default.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 16,
        Parent = window.Sidebar
    })

    -- Content for the page
    local PageContent = self:CreateElement("Frame", {
        BackgroundColor3 = self.Themes.Default.Frame,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
        Parent = window.ContentArea
    })

    -- Toggle page visibility on button click
    PageButton.MouseButton1Click:Connect(function()
        for _, page in pairs(window.ContentArea:GetChildren()) do
            if page:IsA("Frame") then
                page.Visible = false
            end
        end
        PageContent.Visible = true
    end)

    -- Rounded corners
    local PageCorner = Instance.new("UICorner")
    PageCorner.CornerRadius = UDim.new(0, 10)
    PageCorner.Parent = PageContent

    -- Make first page visible by default
    if #window.ContentArea:GetChildren() == 1 then
        PageContent.Visible = true
    end

    -- Add theme to elements
    self:AddThemeObject(PageButton, "Accent")
    self:AddThemeObject(PageContent, "Frame")

    return PageContent
end

-- Create a button element
function Lib:CreateButton(parent, buttonConfig)
    buttonConfig = buttonConfig or {}
    local Button = self:CreateElement("TextButton", {
        Text = buttonConfig.Text or "Button",
        Size = UDim2.new(0, 120, 0, 40),
        BackgroundColor3 = self.Themes.Default.Accent,
        TextColor3 = self.Themes.Default.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        Parent = parent
    })

    -- Button interaction callback
    Button.MouseButton1Click:Connect(buttonConfig.Callback or function() end)

    -- Rounded corners for button
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = Button

    -- Add theme to button
    self:AddThemeObject(Button, "Accent")

    -- Add spacing
    self:AddSpacing(parent)

    return Button
end

-- Create a Label
function Lib:CreateLabel(parent, text)
    local Label = self:CreateElement("TextLabel", {
        Text = text or "Label",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        TextColor3 = self.Themes.Default.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        Parent = parent
    })

    -- Add theme to label
    self:AddThemeObject(Label, "Text")

    -- Add spacing
    self:AddSpacing(parent)

    return Label
end

-- Create a Textbox
function Lib:CreateTextbox(parent, textConfig)
    textConfig = textConfig or {}

    local Textbox = self:CreateElement("TextBox", {
        Text = textConfig.Default or "",
        PlaceholderText = textConfig.Placeholder or "Enter text",
        Size = UDim2.new(0, 200, 0, 30),
        TextColor3 = self.Themes.Default.Text,
        BackgroundColor3 = self.Themes.Default.Frame,
                Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        Parent = parent
    })

    -- Rounded corners for textbox
    local TextboxCorner = Instance.new("UICorner")
    TextboxCorner.CornerRadius = UDim.new(0, 8)
    TextboxCorner.Parent = Textbox

    -- Handle textbox interaction
    Textbox.FocusLost:Connect(function(enterPressed)
        if enterPressed and textConfig.Callback then
            textConfig.Callback(Textbox.Text)
        end
    end)

    -- Add theme to textbox
    self:AddThemeObject(Textbox, "Frame")

    -- Add spacing
    self:AddSpacing(parent)

    return Textbox
end

-- Create a Dropdown
function Lib:CreateDropdown(parent, dropdownConfig)
    dropdownConfig = dropdownConfig or {}
    local Dropdown = {Value = dropdownConfig.Default or "", Options = dropdownConfig.Options or {}}

    -- Dropdown button
    local DropdownButton = self:CreateElement("TextButton", {
        Text = Dropdown.Value,
        Size = UDim2.new(0, 200, 0, 40),
        BackgroundColor3 = self.Themes.Default.Accent,
        TextColor3 = self.Themes.Default.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        Parent = parent
    })

    -- Dropdown list frame
    local DropdownList = self:CreateElement("Frame", {
        BackgroundColor3 = self.Themes.Default.Frame,
        Size = UDim2.new(0, 200, 0, 0),
        ClipsDescendants = true,
        Parent = DropdownButton
    })

    local DropdownLayout = Instance.new("UIListLayout")
    DropdownLayout.Parent = DropdownList
    DropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Populate dropdown options
    local function AddOption(option)
        local OptionButton = self:CreateElement("TextButton", {
            Text = option,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = self.Themes.Default.Frame,
            TextColor3 = self.Themes.Default.Text,
            Parent = DropdownList
        })

        OptionButton.MouseButton1Click:Connect(function()
            Dropdown.Value = option
            DropdownButton.Text = option
            if dropdownConfig.Callback then
                dropdownConfig.Callback(option)
            end
            TweenService:Create(DropdownList, TweenInfo.new(0.2), {Size = UDim2.new(0, 200, 0, 0)}):Play()
        end)
    end

    -- Add options
    for _, option in ipairs(Dropdown.Options) do
        AddOption(option)
    end

    -- Toggle dropdown visibility
    DropdownButton.MouseButton1Click:Connect(function()
        if DropdownList.Size.Y.Offset == 0 then
            TweenService:Create(DropdownList, TweenInfo.new(0.2), {Size = UDim2.new(0, 200, 0, #Dropdown.Options * 30)}):Play()
        else
            TweenService:Create(DropdownList, TweenInfo.new(0.2), {Size = UDim2.new(0, 200, 0, 0)}):Play()
        end
    end)

    -- Add theme to dropdown elements
    self:AddThemeObject(DropdownButton, "Accent")
    self:AddThemeObject(DropdownList, "Frame")

    -- Add spacing
    self:AddSpacing(parent)

    return Dropdown
end

-- Create a KeyBinder
function Lib:CreateKeyBinder(parent, binderConfig)
    binderConfig = binderConfig or {}
    local Binder = {Value = binderConfig.Default or Enum.KeyCode.Unknown}

    -- Binder button
    local BinderButton = self:CreateElement("TextButton", {
        Text = Binder.Value.Name or "Bind Key",
        Size = UDim2.new(0, 200, 0, 40),
        BackgroundColor3 = self.Themes.Default.Accent,
        TextColor3 = self.Themes.Default.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        Parent = parent
    })

    local binding = false

    -- Toggle binding
    BinderButton.MouseButton1Click:Connect(function()
        if not binding then
            binding = true
            BinderButton.Text = "Press Key..."
        end
    end)

    -- Capture key input
    UserInputService.InputBegan:Connect(function(input)
        if binding then
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                Binder.Value = input.KeyCode
                BinderButton.Text = Binder.Value.Name
                binding = false
                if binderConfig.Callback then
                    binderConfig.Callback(Binder.Value)
                end
            end
        end
    end)

    -- Add theme to binder
    self:AddThemeObject(BinderButton, "Accent")

    -- Add spacing
    self:AddSpacing(parent)

    return Binder
end

-- Create Notifications
function Lib:CreateNotification(notifConfig)
    notifConfig = notifConfig or {}
    local Notification = self:CreateElement("Frame", {
        BackgroundColor3 = self.Themes.Default.Accent,
        Size = UDim2.new(0, 300, 0, 100),
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -10, 1, -10),
        Parent = game.CoreGui
    })

    -- Title
    local Title = self:CreateElement("TextLabel", {
        Text = notifConfig.Title or "Notification",
        Size = UDim2.new(1, 0, 0, 25),
        TextColor3 = self.Themes.Default.Text,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        Parent = Notification
    })

    -- Content
    local Content = self:CreateElement("TextLabel", {
        Text = notifConfig.Content or "Notification content",
        Size = UDim2.new(1, 0, 1, -25),
        Position = UDim2.new(0, 0, 0, 25),
        TextColor3 = self.Themes.Default.TextDark,
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        Parent = Notification
    })

    -- Animation and dismissal
    TweenService:Create(Notification, TweenInfo.new(0.5), {Position = UDim2.new(1, -10, 1, -110)}):Play()
    task.delay(notifConfig.Time or 5, function()
        TweenService:Create(Notification, TweenInfo.new(0.5), {Position = UDim2.new(1, -10, 1, -10)}):Play()
        wait(0.5)
        Notification:Destroy()
    end)
end




      
