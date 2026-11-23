-- REPO SKY - RECONSTRUCAO
-- PRINCIPAL / VELOCIDADE / CARROS
-- TAP AUTOMATICO NAO RECUPERADO

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local old = PlayerGui:FindFirstChild("RepoTPPanel")
if old then old:Destroy() end

local oldButton = PlayerGui:FindFirstChild("RepoSkyOpen")
if oldButton then oldButton:Destroy() end

local Connections = {}
local FlightConnection
local FlightVelocity
local FlightAttachment

local FlightActive = false
local Closed = false
local SelectedVehicle

local Speed = {
    Transport = 600,
    Ascent = 350,
    Descent = 250,
    Height = 1500
}

local function track(connection)
    table.insert(Connections, connection)
    return connection
end

local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function corner(obj, radius)
    make("UICorner", {
        CornerRadius = UDim.new(0, radius or 8)
    }, obj)
end

local function stroke(obj, color)
    make("UIStroke", {
        Color = color or Color3.fromRGB(55, 90, 65),
        Thickness = 1
    }, obj)
end

local function label(parent, text, size, pos)
    return make("TextLabel", {
        Size = size,
        Position = pos,
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(235, 235, 235),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    }, parent)
end

local function button(parent, text, pos, callback)
    local b = make("TextButton", {
        Size = UDim2.new(1, -12, 0, 36),
        Position = pos,
        BackgroundColor3 = Color3.fromRGB(43, 48, 45),
        Text = text,
        TextColor3 = Color3.fromRGB(245, 245, 245),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = true
    }, parent)
    corner(b, 7)
    stroke(b)
    track(b.MouseButton1Click:Connect(callback))
    return b
end

local function drag(obj, handle)
    local dragging = false
    local start
    local origin

    track(handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            start = input.Position
            origin = obj.Position
        end
    end))

    track(UIS.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - start
            obj.Position = UDim2.new(
                origin.X.Scale,
                origin.X.Offset + delta.X,
                origin.Y.Scale,
                origin.Y.Offset + delta.Y
            )
        end
    end))

    track(UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
end

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
    Size = UDim2.fromOffset(48, 48),
    Position = UDim2.new(0, 18, 0.5, 0),
    BackgroundColor3 = Color3.fromRGB(25, 125, 65),
    Text = "R",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 23,
    Font = Enum.Font.GothamBold
}, OpenGui)
corner(OpenButton, 12)
stroke(OpenButton, Color3.fromRGB(80, 220, 120))
drag(OpenButton, OpenButton)

local Main = make("Frame", {
    Size = UDim2.fromOffset(390, 330),
    Position = UDim2.new(0.5, -195, 0.5, -165),
    BackgroundColor3 = Color3.fromRGB(23, 25, 24),
    Visible = true
}, Screen)
corner(Main, 10)
stroke(Main)

local Header = make("Frame", {
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = Color3.fromRGB(31, 37, 33)
}, Main)
corner(Header, 10)

label(Header, "REPO SKY", UDim2.new(0, 150, 1, 0), UDim2.fromOffset(13, 0))

local Close = make("TextButton", {
    Size = UDim2.fromOffset(32, 28),
    Position = UDim2.new(1, -39, 0, 7),
    BackgroundColor3 = Color3.fromRGB(130, 45, 45),
    Text = "X",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 13
}, Header)
corner(Close, 6)

drag(Main, Header)

local Tabs = make("Frame", {
    Size = UDim2.new(0, 112, 1, -52),
    Position = UDim2.fromOffset(7, 47),
    BackgroundTransparency = 1
}, Main)

local Content = make("Frame", {
    Size = UDim2.new(1, -130, 1, -55),
    Position = UDim2.fromOffset(123, 48),
    BackgroundColor3 = Color3.fromRGB(29, 32, 30)
}, Main)
corner(Content, 8)

local Pages = {}
local CurrentPage

local function createPage(name)
    local page = make("ScrollingFrame", {
        Name = name,
        Size = UDim2.new(1, -8, 1, -8),
        Position = UDim2.fromOffset(4, 4),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
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
    CurrentPage = name
end

local function createTab(name, index)
    local tab = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 38),
        Position = UDim2.fromOffset(0, (index - 1) * 44),
        BackgroundColor3 = Color3.fromRGB(48, 53, 49),
        Text = name,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 11,
        Font = Enum.Font.GothamBold
    }, Tabs)
    corner(tab, 7)

    track(tab.MouseButton1Click:Connect(function()
        switchPage(name)
        for tabName, other in pairs(Tabs:GetChildren()) do
            if other:IsA("TextButton") then
                other.BackgroundColor3 =
                    other.Text == name
                    and Color3.fromRGB(30, 125, 65)
                    or Color3.fromRGB(48, 53, 49)
            end
        end
    end))
end

local Principal = createPage("PRINCIPAL")
local Velocidade = createPage("VELOCIDADE")
local Carros = createPage("CARROS")

createTab("PRINCIPAL", 1)
createTab("VELOCIDADE", 2)
createTab("CARROS", 3)

local function getCharacter()
    return Player.Character
end

local function getRoot(model)
    if not model then return nil end
    return model:FindFirstChild("PrimaryPart")
        or model:FindFirstChildWhichIsA("VehicleSeat", true)
        or model:FindFirstChildWhichIsA("BasePart", true)
end

local function getVehicleModels()
    local found = {}

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("VehicleSeat") then
            local model = obj:FindFirstAncestorOfClass("Model")
            if model and not found[model] then
                found[model] = true
            end
        end
    end

    local list = {}
    for model in pairs(found) do
        table.insert(list, model)
    end

    return list
end

local function findRepo()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model")
        and string.find(string.lower(obj.Name), "repo") then
            if getRoot(obj) then
                return obj
            end
        end
    end
end

local function findGarage()
    for _, obj in ipairs(workspace:GetDescendants()) do
        local n = string.lower(obj.Name)
        if (string.find(n, "garage") or string.find(n, "spawn"))
        and obj:IsA("BasePart") then
            return obj
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
    if not root then return end

    FlightActive = true

    FlightAttachment = Instance.new("Attachment")
    FlightAttachment.Parent = root

    FlightVelocity = Instance.new("LinearVelocity")
    FlightVelocity.Attachment0 = FlightAttachment
    FlightVelocity.MaxForce = math.huge
    FlightVelocity.VectorVelocity = Vector3.zero
    FlightVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    FlightVelocity.Parent = root

    FlightConnection = RS.Heartbeat:Connect(function()
        if not FlightActive or not root.Parent then
            stopFlight()
            return
        end

        local difference = destination.Position - root.Position
        if difference.Magnitude < 15 then
            stopFlight()
            return
        end

        FlightVelocity.VectorVelocity =
            difference.Unit * Speed.Transport
    end)
end

button(Principal, "TP REPO", UDim2.new(), function()
    local repo = findRepo()
    if repo then
        teleportTo(repo)
    end
end)

button(Principal, "TP CARRO", UDim2.new(), function()
    local vehicles = getVehicleModels()
    local character = getCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not root then return end

    local nearest
    local distance = math.huge

    for _, model in ipairs(vehicles) do
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

button(Principal, "VOAR PARA GARAGEM", UDim2.new(), function()
    local garage = findGarage()
    if not garage then return end

    local vehicle = SelectedVehicle
    if not vehicle or not vehicle.Parent then
        local seat = getCharacter()
            and getCharacter():FindFirstChildOfClass("Humanoid")
        vehicle = seat and seat.SeatPart
            and seat.SeatPart:FindFirstAncestorOfClass("Model")
    end

    if vehicle then
        flyVehicle(vehicle, garage.CFrame)
    end
end)

button(Principal, "PARAR TRANSPORTE", UDim2.new(), function()
    stopFlight()
end)

local function createSpeedControl(name, key)
    local holder = make("Frame", {
        Size = UDim2.new(1, -8, 0, 58),
        BackgroundColor3 = Color3.fromRGB(39, 43, 40)
    }, Velocidade)
    corner(holder, 7)

    label(holder, name, UDim2.new(0.6, 0, 0, 25), UDim2.fromOffset(8, 2))

    local value = label(
        holder,
        tostring(Speed[key]),
        UDim2.new(0.3, 0, 0, 25),
        UDim2.new(0.68, 0, 0, 2)
    )
    value.TextXAlignment = Enum.TextXAlignment.Right

    local minus = make("TextButton", {
        Size = UDim2.fromOffset(45, 23),
        Position = UDim2.fromOffset(8, 30),
        BackgroundColor3 = Color3.fromRGB(65, 70, 66),
        Text = "-",
        TextColor3 = Color3.new(1, 1, 1)
    }, holder)
    corner(minus, 5)

    local plus = make("TextButton", {
        Size = UDim2.fromOffset(45, 23),
        Position = UDim2.fromOffset(59, 30),
        BackgroundColor3 = Color3.fromRGB(30, 115, 60),
        Text = "+",
        TextColor3 = Color3.new(1, 1, 1)
    }, holder)
    corner(plus, 5)

    track(minus.MouseButton1Click:Connect(function()
        Speed[key] = math.max(10, Speed[key] - 50)
        value.Text = tostring(Speed[key])
    end))

    track(plus.MouseButton1Click:Connect(function()
        Speed[key] = Speed[key] + 50
        value.Text = tostring(Speed[key])
    end))
end

createSpeedControl("VELOCIDADE TRANSPORTE", "Transport")
createSpeedControl("SUBIDA", "Ascent")
createSpeedControl("DESCIDA", "Descent")
createSpeedControl("ALTURA", "Height")

local function refreshCars()
    for _, child in ipairs(Carros:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local vehicles = getVehicleModels()

    for _, model in ipairs(vehicles) do
        local name = model.Name

        local b = make("TextButton", {
            Size = UDim2.new(1, -8, 0, 35),
            BackgroundColor3 = Color3.fromRGB(43, 49, 44),
            Text = name,
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 11,
            Font = Enum.Font.Gotham
        }, Carros)
        corner(b, 6)

        track(b.MouseButton1Click:Connect(function()
            SelectedVehicle = model
            teleportTo(model)
        end))
    end
end

button(Carros, "ATUALIZAR CATÁLOGO", UDim2.new(), refreshCars)

local function closeAll()
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

track(Close.MouseButton1Click:Connect(function()
    Main.Visible = false
end))

track(OpenButton.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end))

-- BOTAO ENCERRAR
local EndButton = make("TextButton", {
    Size = UDim2.new(1, -12, 0, 32),
    Position = UDim2.new(0, 6, 1, -38),
    BackgroundColor3 = Color3.fromRGB(130, 40, 40),
    Text = "ENCERRAR",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 12
}, Main)
corner(EndButton, 7)

track(EndButton.MouseButton1Click:Connect(closeAll))

switchPage("PRINCIPAL")
refreshCars()
