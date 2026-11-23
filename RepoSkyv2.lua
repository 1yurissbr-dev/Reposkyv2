-- REPO SKY V2
-- RECONSTRUCAO DO PAINEL ORIGINAL
-- PRINCIPAL / VELOCIDADE / CARROS

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

for _, name in ipairs({"RepoTPPanel", "RepoSkyOpen"}) do
    local old = PlayerGui:FindFirstChild(name)
    if old then old:Destroy() end
end

local Connections = {}
local Closed = false
local Minimized = false
local FlightActive = false
local FlightConnection
local FlightVelocity
local FlightAttachment
local SelectedVehicle

local Speed = {
    Transport = 600,
    Ascent = 350,
    Descent = 250,
    Height = 1500
}

local function connect(signal, callback)
    local c = signal:Connect(callback)
    table.insert(Connections, c)
    return c
end

local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function round(obj, radius)
    make("UICorner", {
        CornerRadius = UDim.new(0, radius or 7)
    }, obj)
end

local function outline(obj, color)
    make("UIStroke", {
        Color = color or Color3.fromRGB(65, 105, 75),
        Thickness = 1
    }, obj)
end

local function text(parent, value, size, position, font)
    return make("TextLabel", {
        Size = size,
        Position = position,
        BackgroundTransparency = 1,
        Text = value,
        TextColor3 = Color3.fromRGB(235, 235, 235),
        TextSize = 12,
        Font = font or Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    }, parent)
end

local function drag(object, handle)
    local active = false
    local startPosition
    local objectPosition

    connect(handle.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            active = true
            startPosition = input.Position
            objectPosition = object.Position
        end
    end)

    connect(UIS.InputChanged, function(input)
        if active and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - startPosition
            object.Position = UDim2.new(
                objectPosition.X.Scale,
                objectPosition.X.Offset + delta.X,
                objectPosition.Y.Scale,
                objectPosition.Y.Offset + delta.Y
            )
        end
    end)

    connect(UIS.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            active = false
        end
    end)
end

local function getCharacter()
    return Player.Character
end

local function getRoot(model)
    if not model then return nil end

    if model:IsA("BasePart") then
        return model
    end

    return model.PrimaryPart
        or model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChildWhichIsA("VehicleSeat", true)
        or model:FindFirstChildWhichIsA("BasePart", true)
end

local function getVehicleModels()
    local found = {}

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("VehicleSeat") then
            local model = obj:FindFirstAncestorOfClass("Model")
            if model then
                found[model] = true
            end
        end
    end

    local result = {}
    for model in pairs(found) do
        table.insert(result, model)
    end

    table.sort(result, function(a, b)
        return a.Name < b.Name
    end)

    return result
end

local function findRepo()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local name = string.lower(obj.Name)

            if string.find(name, "repo") then
                if getRoot(obj) then
                    return obj
                end
            end
        end
    end
end

local function findGarage()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = string.lower(obj.Name)

            if string.find(name, "garage")
            or string.find(name, "spawn") then
                return obj
            end
        end
    end
end

local function teleportTo(model)
    local character = getCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local target = getRoot(model)

    if root and target then
        root.CFrame = target.CFrame * CFrame.new(0, 5, 0)
        return true
    end

    return false
end

local function stopFlight()
    FlightActive = false

    if FlightConnection then
        FlightConnection:Disconnect()
        FlightConnection = nil
    end

    if FlightVelocity then
        FlightVelocity:Destroy()
        FlightVelocity = nil
    end

    if FlightAttachment then
        FlightAttachment:Destroy()
        FlightAttachment = nil
    end
end

local function flyVehicle(model, destination)
    stopFlight()

    local root = getRoot(model)
    if not root or not destination then return end

    FlightActive = true

    FlightAttachment = Instance.new("Attachment")
    FlightAttachment.Parent = root

    FlightVelocity = Instance.new("LinearVelocity")
    FlightVelocity.Attachment0 = FlightAttachment
    FlightVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    FlightVelocity.MaxForce = math.huge
    FlightVelocity.VectorVelocity = Vector3.zero
    FlightVelocity.Parent = root

    FlightConnection = RS.Heartbeat:Connect(function()
        if not FlightActive or not root.Parent then
            stopFlight()
            return
        end

        local difference = destination.Position - root.Position

        if difference.Magnitude <= 15 then
            stopFlight()
            return
        end

        FlightVelocity.VectorVelocity =
            difference.Unit * Speed.Transport
    end)
end

-- INTERFACE

local Screen = make("ScreenGui", {
    Name = "RepoTPPanel",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, PlayerGui)

local OpenGui = make("ScreenGui", {
    Name = "RepoSkyOpen",
    ResetOnSpawn = false
}, PlayerGui)

local OpenButton = make("TextButton", {
    Size = UDim2.fromOffset(45, 45),
    Position = UDim2.new(0, 18, 0.5, 0),
    BackgroundColor3 = Color3.fromRGB(25, 125, 65),
    Text = "R",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 23,
    Font = Enum.Font.GothamBold
}, OpenGui)

round(OpenButton, 12)
outline(OpenButton, Color3.fromRGB(80, 220, 120))
drag(OpenButton, OpenButton)

local Main = make("Frame", {
    Size = UDim2.fromOffset(420, 340),
    Position = UDim2.new(0.5, -210, 0.5, -170),
    BackgroundColor3 = Color3.fromRGB(20, 22, 21),
    BorderSizePixel = 0
}, Screen)

round(Main, 10)
outline(Main)

local Header = make("Frame", {
    Size = UDim2.new(1, 0, 0, 38),
    BackgroundColor3 = Color3.fromRGB(30, 35, 31),
    BorderSizePixel = 0
}, Main)

round(Header, 10)
drag(Main, Header)

text(
    Header,
    "REPO SKY",
    UDim2.new(0, 150, 1, 0),
    UDim2.fromOffset(12, 0),
    Enum.Font.GothamBold
)

local Minimize = make("TextButton", {
    Size = UDim2.fromOffset(28, 25),
    Position = UDim2.new(1, -65, 0, 6),
    BackgroundColor3 = Color3.fromRGB(65, 75, 65),
    Text = "-",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 17
}, Header)
round(Minimize, 5)

local Close = make("TextButton", {
    Size = UDim2.fromOffset(28, 25),
    Position = UDim2.new(1, -33, 0, 6),
    BackgroundColor3 = Color3.fromRGB(130, 45, 45),
    Text = "X",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 12
}, Header)
round(Close, 5)

local Tabs = make("Frame", {
    Size = UDim2.new(0, 112, 1, -48),
    Position = UDim2.fromOffset(7, 44),
    BackgroundTransparency = 1
}, Main)

local Content = make("Frame", {
    Size = UDim2.new(1, -130, 1, -48),
    Position = UDim2.fromOffset(123, 44),
    BackgroundColor3 = Color3.fromRGB(28, 31, 29),
    BorderSizePixel = 0
}, Main)
round(Content, 8)

local Pages = {}
local TabButtons = {}

local function createPage(name)
    local page = make("ScrollingFrame", {
        Name = name,
        Size = UDim2.new(1, -8, 1, -8),
        Position = UDim2.fromOffset(4, 4),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(75, 145, 90),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false
    }, Content)

    make("UIListLayout", {
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, page)

    Pages[name] = page
    return page
end

local function switchPage(name)
    for pageName, page in pairs(Pages) do
        page.Visible = pageName == name
    end

    for tabName, tab in pairs(TabButtons) do
        tab.BackgroundColor3 = tabName == name
            and Color3.fromRGB(30, 125, 65)
            or Color3.fromRGB(45, 50, 46)
    end
end

local function createTab(name, index)
    local tab = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 38),
        Position = UDim2.fromOffset(0, (index - 1) * 44),
        BackgroundColor3 = Color3.fromRGB(45, 50, 46),
        Text = name,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 11,
        Font = Enum.Font.GothamBold
    }, Tabs)

    round(tab, 7)
    TabButtons[name] = tab

    connect(tab.MouseButton1Click, function()
        switchPage(name)
    end)
end

local Principal = createPage("PRINCIPAL")
local Velocidade = createPage("VELOCIDADE")
local Carros = createPage("CARROS")

createTab("PRINCIPAL", 1)
createTab("VELOCIDADE", 2)
createTab("CARROS", 3)

local function createButton(parent, name, callback)
    local b = make("TextButton", {
        Size = UDim2.new(1, -8, 0, 36),
        BackgroundColor3 = Color3.fromRGB(43, 49, 44),
        Text = name,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 12,
        Font = Enum.Font.GothamBold
    }, parent)

    round(b, 7)
    outline(b)

    connect(b.MouseButton1Click, callback)
    return b
end

local function createInfo(parent, name, value)
    local holder = make("Frame", {
        Size = UDim2.new(1, -8, 0, 29),
        BackgroundColor3 = Color3.fromRGB(37, 42, 38)
    }, parent)

    round(holder, 6)

    text(holder, name, UDim2.new(0.7, 0, 1, 0), UDim2.fromOffset(8, 0))

    local right = text(
        holder,
        value,
        UDim2.new(0.25, 0, 1, 0),
        UDim2.new(0.72, 0, 0, 0)
    )

    right.TextXAlignment = Enum.TextXAlignment.Right
    return right
end

-- PRINCIPAL

createButton(Principal, "TP REPO  [7]", function()
    local repo = findRepo()
    if repo then
        teleportTo(repo)
    else
        warn("[REPO SKY] REPO nao encontrado")
    end
end)

createButton(Principal, "TP CARRO  [8]", function()
    local character = getCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local nearest
    local distance = math.huge

    for _, model in ipairs(getVehicleModels()) do
        local part = getRoot(model)

        if part then
            local d = (part.Position - root.Position).Magnitude

            if d < distance then
                distance = d
                nearest = model
            end
        end
    end

    if nearest then
        SelectedVehicle = nearest
        teleportTo(nearest)
    end
end)

createButton(Principal, "VOAR PARA GARAGEM  [9]", function()
    local garage = findGarage()

    if not garage then
        warn("[REPO SKY] GARAGEM nao encontrada")
        return
    end

    if SelectedVehicle and SelectedVehicle.Parent then
        flyVehicle(SelectedVehicle, garage.CFrame)
    else
        warn("[REPO SKY] Selecione um veiculo primeiro")
    end
end)

createButton(Principal, "PARAR TRANSPORTE  [P]", function()
    stopFlight()
end)

createInfo(Principal, "ATALHOS", "7 / 8 / 9 / P")

-- VELOCIDADE

local function createSpeedControl(name, key)
    local holder = make("Frame", {
        Size = UDim2.new(1, -8, 0, 57),
        BackgroundColor3 = Color3.fromRGB(38, 43, 39)
    }, Velocidade)

    round(holder, 7)

    text(
        holder,
        name,
        UDim2.new(0.7, 0, 0, 25),
        UDim2.fromOffset(8, 2)
    )

    local value = text(
        holder,
        tostring(Speed[key]),
        UDim2.new(0.25, 0, 0, 25),
        UDim2.new(0.72, 0, 0, 2)
    )

    value.TextXAlignment = Enum.TextXAlignment.Right

    local minus = make("TextButton", {
        Size = UDim2.fromOffset(48, 23),
        Position = UDim2.fromOffset(8, 30),
        BackgroundColor3 = Color3.fromRGB(65, 70, 66),
        Text = "-",
        TextColor3 = Color3.new(1, 1, 1)
    }, holder)
    round(minus, 5)

    local plus = make("TextButton", {
        Size = UDim2.fromOffset(48, 23),
        Position = UDim2.fromOffset(62, 30),
        BackgroundColor3 = Color3.fromRGB(30, 115, 60),
        Text = "+",
        TextColor3 = Color3.new(1, 1, 1)
    }, holder)
    round(plus, 5)

    connect(minus.MouseButton1Click, function()
        Speed[key] = math.max(10, Speed[key] - 50)
        value.Text = tostring(Speed[key])
    end)

    connect(plus.MouseButton1Click, function()
        Speed[key] = Speed[key] + 50
        value.Text = tostring(Speed[key])
    end)
end

createSpeedControl("VELOCIDADE TRANSPORTE", "Transport")
createSpeedControl("VELOCIDADE SUBIDA", "Ascent")
createSpeedControl("VELOCIDADE DESCIDA", "Descent")
createSpeedControl("ALTURA", "Height")

createButton(Velocidade, "PARAR TRANSPORTE", stopFlight)

-- CARROS

local CatalogStatus = createInfo(Carros, "VEICULOS ENCONTRADOS", "0")

local function refreshCars()
    for _, child in ipairs(Carros:GetChildren()) do
        if child:GetAttribute("CatalogCard") then
            child:Destroy()
        end
    end

    local vehicles = getVehicleModels()
    CatalogStatus.Text = tostring(#vehicles)

    for _, model in ipairs(vehicles) do
        local card = make("TextButton", {
            Size = UDim2.new(1, -8, 0, 43),
            BackgroundColor3 = Color3.fromRGB(40, 46, 41),
            Text = model.Name,
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 12,
            Font = Enum.Font.GothamBold
        }, Carros)

        card:SetAttribute("CatalogCard", true)
        round(card, 7)

        connect(card.MouseButton1Click, function()
            SelectedVehicle = model
            teleportTo(model)
        end)
    end
end

createButton(Carros, "ATUALIZAR CATALOGO", refreshCars)
createButton(Carros, "IR ATE VEICULO SELECIONADO", function()
    if SelectedVehicle and SelectedVehicle.Parent then
        teleportTo(SelectedVehicle)
    end
end)

-- ATALHOS

connect(UIS.InputBegan, function(input, processed)
    if processed or Closed then return end

    if input.KeyCode == Enum.KeyCode.Seven
    or input.KeyCode == Enum.KeyCode.KeypadSeven then
        local repo = findRepo()
        if repo then teleportTo(repo) end

    elseif input.KeyCode == Enum.KeyCode.Eight
    or input.KeyCode == Enum.KeyCode.KeypadEight then
        local character = getCharacter()
        local root = character and character:FindFirstChild("HumanoidRootPart")

        if root then
            local nearest
            local distance = math.huge

            for _, model in ipairs(getVehicleModels()) do
                local part = getRoot(model)
                if part then
                    local d = (part.Position - root.Position).Magnitude
                    if d < distance then
                        distance = d
                        nearest = model
                    end
                end
            end

            if nearest then
                SelectedVehicle = nearest
                teleportTo(nearest)
            end
        end

    elseif input.KeyCode == Enum.KeyCode.Nine
    or input.KeyCode == Enum.KeyCode.KeypadNine then
        local garage = findGarage()

        if garage and SelectedVehicle and SelectedVehicle.Parent then
            flyVehicle(SelectedVehicle, garage.CFrame)
        end

    elseif input.KeyCode == Enum.KeyCode.P then
        stopFlight()
    end
end)

-- MINIMIZAR / ABRIR / ENCERRAR

connect(Minimize.MouseButton1Click, function()
    Minimized = not Minimized
    Tabs.Visible = not Minimized
    Content.Visible = not Minimized
    Main.Size = Minimized
        and UDim2.fromOffset(420, 38)
        or UDim2.fromOffset(420, 340)
end)

connect(Close.MouseButton1Click, function()
    Main.Visible = false
end)

connect(OpenButton.MouseButton1Click, function()
    Main.Visible = not Main.Visible
end)

local EndButton = make("TextButton", {
    Size = UDim2.fromOffset(105, 27),
    Position = UDim2.new(1, -112, 1, -32),
    BackgroundColor3 = Color3.fromRGB(130, 40, 40),
    Text = "ENCERRAR",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 11,
    Font = Enum.Font.GothamBold
}, Main)

round(EndButton, 6)

local function shutdown()
    if Closed then return end
    Closed = true

    stopFlight()

    for _, connection in ipairs(Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    Screen:Destroy()
    OpenGui:Destroy()
end

connect(EndButton.MouseButton1Click, shutdown)

switchPage("PRINCIPAL")
refreshCars()
