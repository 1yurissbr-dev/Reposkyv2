-- CAR DEALERSHIP TYCOON
-- REPO SKY - PAINEL VISUAL
-- SOMENTE INTERFACE - SEM FUNCOES DE TP

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- LIMPAR VERSAO ANTERIOR

local Old = PlayerGui:FindFirstChild("RepoTPPanel")
if Old then
    Old:Destroy()
end

local Connections = {}
local Closed = false

local Speed = {
    Transport = 600,
    Ascent = 350,
    Descent = 250,
    Height = 1500,
    Freeze = 1
}

local function connect(signal, callback)
    local c = signal:Connect(callback)
    table.insert(Connections, c)
    return c
end

local function make(class, props, parent)
    local obj = Instance.new(class)

    for k, v in pairs(props) do
        obj[k] = v
    end

    obj.Parent = parent
    return obj
end

local function corner(obj, radius)
    make("UICorner", {
        CornerRadius = UDim.new(0, radius or 7)
    }, obj)
end

local function stroke(obj, color, thickness)
    make("UIStroke", {
        Color = color,
        Thickness = thickness or 1
    }, obj)
end

-- GUI

local Gui = make("ScreenGui", {
    Name = "RepoTPPanel",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999
}, PlayerGui)

-- BOTAO R

local OpenButton = make("TextButton", {
    Name = "RepoSkyOpen",
    Size = UDim2.fromOffset(42, 42),
    Position = UDim2.new(0, 15, 0.5, -21),
    BackgroundColor3 = Color3.fromRGB(30, 125, 80),
    BorderSizePixel = 0,
    Text = "R",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 19,
    Active = true,
    ZIndex = 100
}, Gui)

corner(OpenButton, 12)

-- PAINEL PRINCIPAL

local Main = make("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(590, 440),
    Position = UDim2.new(0.5, -295, 0.5, -220),
    BackgroundColor3 = Color3.fromRGB(12, 16, 24),
    BorderSizePixel = 0,
    Visible = false,
    Active = true
}, Gui)

corner(Main, 10)
stroke(Main, Color3.fromRGB(40, 115, 205), 1.4)

-- CABECALHO

local Header = make("Frame", {
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = Color3.fromRGB(20, 27, 39),
    BorderSizePixel = 0
}, Main)

corner(Header, 9)

make("TextLabel", {
    Size = UDim2.new(1, -110, 1, 0),
    Position = UDim2.fromOffset(13, 0),
    BackgroundTransparency = 1,
    Text = "R | REPO SKY TELEPORT",
    TextColor3 = Color3.fromRGB(80, 160, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    TextXAlignment = Enum.TextXAlignment.Left
}, Header)

local Minimize = make("TextButton", {
    Size = UDim2.fromOffset(30, 28),
    Position = UDim2.new(1, -73, 0, 7),
    BackgroundColor3 = Color3.fromRGB(45, 85, 135),
    Text = "_",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 16
}, Header)

corner(Minimize, 5)

local Close = make("TextButton", {
    Size = UDim2.fromOffset(32, 28),
    Position = UDim2.new(1, -38, 0, 7),
    BackgroundColor3 = Color3.fromRGB(145, 43, 50),
    Text = "X",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 15
}, Header)

corner(Close, 5)

-- MENU LATERAL

local Side = make("Frame", {
    Position = UDim2.fromOffset(9, 51),
    Size = UDim2.new(0, 126, 1, -60),
    BackgroundColor3 = Color3.fromRGB(18, 23, 33),
    BorderSizePixel = 0
}, Main)

corner(Side, 8)

-- CONTEUDO

local Content = make("Frame", {
    Position = UDim2.fromOffset(144, 51),
    Size = UDim2.new(1, -153, 1, -60),
    BackgroundColor3 = Color3.fromRGB(17, 22, 32),
    BorderSizePixel = 0
}, Main)

corner(Content, 8)

-- PAGINAS

local Pages = {}

for _, name in ipairs({
    "PRINCIPAL",
    "VELOCIDADE",
    "CARROS"
}) do

    local page = make("ScrollingFrame", {
        Name = name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = Color3.fromRGB(65, 125, 200),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false
    }, Content)

    make("UIListLayout", {
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, page)

    make("UIPadding", {
        PaddingTop = UDim.new(0, 9),
        PaddingLeft = UDim.new(0, 9),
        PaddingRight = UDim.new(0, 9),
        PaddingBottom = UDim.new(0, 10)
    }, page)

    Pages[name] = page
end

-- ELEMENTOS

local function label(parent, txt, height)
    return make("TextLabel", {
        Size = UDim2.new(1, 0, 0, height or 28),
        BackgroundTransparency = 1,
        Text = txt,
        TextColor3 = Color3.fromRGB(195, 207, 225),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left
    }, parent)
end

local function button(parent, txt, color)
    local b = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = color or Color3.fromRGB(37, 91, 155),
        BorderSizePixel = 0,
        Text = txt,
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        AutoButtonColor = true
    }, parent)

    corner(b, 6)
    return b
end

-- TROCAR ABAS

local function selectTab(name)
    for n, page in pairs(Pages) do
        page.Visible = n == name
    end

    for _, obj in ipairs(Side:GetChildren()) do
        if obj:IsA("TextButton") then
            obj.BackgroundColor3 =
                obj.Name == name
                and Color3.fromRGB(35, 105, 185)
                or Color3.fromRGB(39, 46, 59)
        end
    end
end

for i, name in ipairs({
    "PRINCIPAL",
    "VELOCIDADE",
    "CARROS"
}) do

    local b = make("TextButton", {
        Name = name,
        Size = UDim2.new(1, -12, 0, 39),
        Position = UDim2.fromOffset(6, 8 + (i - 1) * 46),
        BackgroundColor3 = Color3.fromRGB(39, 46, 59),
        BorderSizePixel = 0,
        Text = name,
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 11
    }, Side)

    corner(b, 6)

    connect(b.Activated, function()
        selectTab(name)
    end)
end

selectTab("PRINCIPAL")

-- ARRASTAR

local function makeDraggable(obj, handle)
    local dragging = false
    local dragStart
    local startPosition

    connect(handle.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then

            dragging = true
            dragStart = input.Position
            startPosition = obj.Position
        end
    end)

    connect(UIS.InputChanged, function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseMovement
        ) then

            local delta = input.Position - dragStart

            obj.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    connect(UIS.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

makeDraggable(Main, Header)
makeDraggable(OpenButton, OpenButton)

-- ABRIR E MINIMIZAR

connect(OpenButton.Activated, function()
    if not Closed then
        Main.Visible = true
        OpenButton.Visible = false
    end
end)

connect(Minimize.Activated, function()
    Main.Visible = false
    OpenButton.Visible = true
end)

connect(Close.Activated, function()
    Main.Visible = false
    OpenButton.Visible = true
end)

-- ENCERRAR

local EndButton = make("TextButton", {
    Name = "Encerrar",
    Size = UDim2.fromOffset(88, 25),
    Position = UDim2.new(1, -98, 1, -32),
    BackgroundColor3 = Color3.fromRGB(145, 43, 50),
    BorderSizePixel = 0,
    Text = "ENCERRAR",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    ZIndex = 10
}, Main)

corner(EndButton, 5)

connect(EndButton.Activated, function()
    Closed = true

    for _, c in ipairs(Connections) do
        pcall(function()
            c:Disconnect()
        end)
    end

    Gui:Destroy()
end)

-- PRINCIPAL

local Principal = Pages.PRINCIPAL

label(Principal, "7 REPO | 8 CARRO | 9 VOAR | P PARAR", 38)

button(Principal, "TP REPO [7]")
button(Principal, "TP CARRO [8]")

button(
    Principal,
    "VOAR PARA GARAGEM [9]",
    Color3.fromRGB(35, 125, 85)
)

button(
    Principal,
    "PARAR TRANSPORTE [P]",
    Color3.fromRGB(145, 45, 50)
)

-- VELOCIDADE

local Velocity = Pages.VELOCIDADE

label(Velocity, "CONFIGURACOES DO VOO", 26)

local function speedInput(title, key)
    label(Velocity, title, 20)

    local box = make("TextBox", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Color3.fromRGB(29, 36, 49),
        TextColor3 = Color3.new(1, 1, 1),
        Text = tostring(Speed[key]),
        ClearTextOnFocus = false,
        Font = Enum.Font.Gotham,
        TextSize = 13
    }, Velocity)

    corner(box, 5)

    connect(box.FocusLost, function()
        local n = tonumber(box.Text)

        if n then
            Speed[key] = math.clamp(n, 1, 99999)
        end

        box.Text = tostring(Speed[key])
    end)
end

speedInput("Velocidade horizontal", "Transport")
speedInput("Velocidade de subida", "Ascent")
speedInput("Velocidade de descida", "Descent")
speedInput("Altura da subida", "Height")
speedInput("Tempo congelado na chegada", "Freeze")

-- CATALOGO

local CarPage = Pages.CARROS

label(CarPage, "CATALOGO DE VEICULOS", 22)

local Status = label(CarPage, "Visualizacao do catalogo", 22)

button(
    CarPage,
    "ATUALIZAR VEICULOS",
    Color3.fromRGB(35, 105, 85)
)

local GridHolder = make("ScrollingFrame", {
    Name = "GridHolder",
    Size = UDim2.new(1, 0, 0, 310),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 6,
    ScrollBarImageColor3 = Color3.fromRGB(65, 125, 200),
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y
}, CarPage)

make("UIGridLayout", {
    CellSize = UDim2.new(0, 124, 0, 143),
    CellPadding = UDim2.fromOffset(7, 7),
    SortOrder = Enum.SortOrder.LayoutOrder
}, GridHolder)

-- CARTOES VISUAIS

local function createCarCard(name, index)
    local card = make("Frame", {
        Name = "CarCard" .. index,
        BackgroundColor3 = Color3.fromRGB(27, 34, 47),
        BorderSizePixel = 0
    }, GridHolder)

    corner(card, 7)

    local image = make("ImageLabel", {
        Size = UDim2.new(1, -12, 0, 88),
        Position = UDim2.fromOffset(6, 6),
        BackgroundColor3 = Color3.fromRGB(19, 25, 36),
        BorderSizePixel = 0,
        Image = "",
        ScaleType = Enum.ScaleType.Fit
    }, card)

    corner(image, 5)

    make("TextLabel", {
        Size = UDim2.new(1, -10, 0, 24),
        Position = UDim2.fromOffset(5, 98),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Color3.fromRGB(220, 228, 240),
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextWrapped = true
    }, card)

    local selectButton = make("TextButton", {
        Size = UDim2.new(1, -12, 0, 22),
        Position = UDim2.fromOffset(6, 119),
        BackgroundColor3 = Color3.fromRGB(37, 91, 155),
        BorderSizePixel = 0,
        Text = "SELECIONAR",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 9
    }, card)

    corner(selectButton, 4)
end

for i = 1, 12 do
    createCarCard("VEICULO " .. i, i)
end

-- ATALHOS VISUAIS
-- Nenhuma acao de TP ou voo e executada.

connect(UIS.InputBegan, function(input, processed)
    if processed or Closed then return end

    if input.KeyCode == Enum.KeyCode.P then
        Status.Text = "ATALHO P PRESSIONADO"
    end
end)

print("[REPO SKY] Painel visual carregado.")
