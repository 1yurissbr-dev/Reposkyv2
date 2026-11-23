
-- REPO SKY | CAR DEALERSHIP TYCOON
-- PAINEL + PESQUISA DE VEICULOS
-- INSPECAO LOCAL

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local old = PlayerGui:FindFirstChild("RepoTPPanel")
if old then old:Destroy() end

local Speed = {
    Transport = 600,
    Ascent = 350,
    Descent = 450,
    Height = 685,
    Freeze = 1.5
}

local Connections = {}
local Closed = false

local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(Connections, c)
    return c
end

local function make(class, props, parent)
    local obj = Instance.new(class)
    for k,v in pairs(props) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local function corner(obj, n)
    make("UICorner", {CornerRadius=UDim.new(0,n or 7)}, obj)
end

local function stroke(obj, color)
    make("UIStroke", {Color=color, Thickness=1.2}, obj)
end

local function label(parent, text, height)
    return make("TextLabel", {
        Size=UDim2.new(1,0,0,height or 26),
        BackgroundTransparency=1,
        Text=text,
        TextColor3=Color3.fromRGB(205,215,230),
        Font=Enum.Font.Gotham,
        TextSize=12,
        TextWrapped=true,
        TextXAlignment=Enum.TextXAlignment.Left
    }, parent)
end

local function button(parent, text, color)
    local b=make("TextButton", {
        Size=UDim2.new(1,0,0,35),
        BackgroundColor3=color or Color3.fromRGB(38,91,150),
        BorderSizePixel=0,
        Text=text,
        TextColor3=Color3.new(1,1,1),
        Font=Enum.Font.GothamBold,
        TextSize=11
    }, parent)
    corner(b,6)
    return b
end

local Gui=make("ScreenGui", {
    Name="RepoTPPanel",
    ResetOnSpawn=false,
    DisplayOrder=999,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling
}, PlayerGui)

-- BOTAO FLUTUANTE

local Open=make("TextButton", {
    Name="RepoSkyOpen",
    Size=UDim2.fromOffset(42,42),
    Position=UDim2.new(0,15,0.5,-21),
    BackgroundColor3=Color3.fromRGB(30,125,80),
    BorderSizePixel=0,
    Text="R",
    TextColor3=Color3.new(1,1,1),
    Font=Enum.Font.GothamBold,
    TextSize=19,
    Active=true,
    ZIndex=100
},Gui)
corner(Open,12)

-- PAINEL

local Main=make("Frame", {
    Size=UDim2.fromOffset(590,440),
    Position=UDim2.new(0.5,-295,0.5,-220),
    BackgroundColor3=Color3.fromRGB(12,16,24),
    BorderSizePixel=0,
    Visible=false,
    Active=true
},Gui)
corner(Main,10)
stroke(Main,Color3.fromRGB(40,115,205))

local Header=make("Frame", {
    Size=UDim2.new(1,0,0,42),
    BackgroundColor3=Color3.fromRGB(20,27,39),
    BorderSizePixel=0
},Main)
corner(Header,9)

make("TextLabel", {
    Size=UDim2.new(1,-110,1,0),
    Position=UDim2.fromOffset(13,0),
    BackgroundTransparency=1,
    Text="R | REPO SKY",
    TextColor3=Color3.fromRGB(80,160,255),
    Font=Enum.Font.GothamBold,
    TextSize=15,
    TextXAlignment=Enum.TextXAlignment.Left
},Header)

local Min=make("TextButton", {
    Size=UDim2.fromOffset(30,28),
    Position=UDim2.new(1,-73,0,7),
    BackgroundColor3=Color3.fromRGB(45,85,135),
    Text="_",
    TextColor3=Color3.new(1,1,1),
    Font=Enum.Font.GothamBold
},Header)
corner(Min,5)

local Close=make("TextButton", {
    Size=UDim2.fromOffset(32,28),
    Position=UDim2.new(1,-38,0,7),
    BackgroundColor3=Color3.fromRGB(145,43,50),
    Text="X",
    TextColor3=Color3.new(1,1,1),
    Font=Enum.Font.GothamBold
},Header)
corner(Close,5)

local Side=make("Frame", {
    Position=UDim2.fromOffset(9,51),
    Size=UDim2.new(0,126,1,-60),
    BackgroundColor3=Color3.fromRGB(18,23,33),
    BorderSizePixel=0
},Main)
corner(Side,8)

local Content=make("Frame", {
    Position=UDim2.fromOffset(144,51),
    Size=UDim2.new(1,-153,1,-60),
    BackgroundColor3=Color3.fromRGB(17,22,32),
    BorderSizePixel=0
},Main)
corner(Content,8)

local Pages={}
for _,name in ipairs({"PRINCIPAL","VELOCIDADE","CARROS"}) do
    local page=make("ScrollingFrame", {
        Name=name,
        Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ScrollBarThickness=5,
        CanvasSize=UDim2.new(),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        Visible=false
    },Content)

    make("UIListLayout", {
        Padding=UDim.new(0,7),
        SortOrder=Enum.SortOrder.LayoutOrder
    },page)

    make("UIPadding", {
        PaddingTop=UDim.new(0,9),
        PaddingLeft=UDim.new(0,9),
        PaddingRight=UDim.new(0,9),
        PaddingBottom=UDim.new(0,10)
    },page)

    Pages[name]=page
end

local function selectTab(name)
    for n,p in pairs(Pages) do p.Visible=(n==name) end
    for _,v in ipairs(Side:GetChildren()) do
        if v:IsA("TextButton") then
            v.BackgroundColor3=(v.Name==name)
                and Color3.fromRGB(35,105,185)
                or Color3.fromRGB(39,46,59)
        end
    end
end

for i,name in ipairs({"PRINCIPAL","VELOCIDADE","CARROS"}) do
    local b=make("TextButton", {
        Name=name,
        Size=UDim2.new(1,-12,0,39),
        Position=UDim2.fromOffset(6,8+(i-1)*46),
        BackgroundColor3=Color3.fromRGB(39,46,59),
        BorderSizePixel=0,
        Text=name,
        TextColor3=Color3.new(1,1,1),
        Font=Enum.Font.GothamBold,
        TextSize=11
    },Side)
    corner(b,6)
    connect(b.Activated,function() selectTab(name) end)
end
selectTab("PRINCIPAL")

-- ARRASTAR PAINEL E BOTAO R

local function draggable(obj,handle)
    local dragging=false
    local startPos,startInput

    connect(handle.InputBegan,function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true
            startInput=input.Position
            startPos=obj.Position
        end
    end)

    connect(UIS.InputChanged,function(input)
        if dragging and (
            input.UserInputType==Enum.UserInputType.MouseMovement
            or input.UserInputType==Enum.UserInputType.Touch
        ) then
            local delta=input.Position-startInput
            obj.Position=UDim2.new(
                startPos.X.Scale,startPos.X.Offset+delta.X,
                startPos.Y.Scale,startPos.Y.Offset+delta.Y
            )
        end
    end)

    connect(UIS.InputEnded,function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.Touch then
            dragging=false
        end
    end)
end

draggable(Main,Header)
draggable(Open,Open)

connect(Open.Activated,function()
    if not Closed then Main.Visible=not Main.Visible end
end)

connect(Min.Activated,function() Main.Visible=false end)
connect(Close.Activated,function() Main.Visible=false end)

-- ENCERRAR

local End=make("TextButton", {
    Size=UDim2.fromOffset(88,25),
    Position=UDim2.new(1,-98,1,-32),
    BackgroundColor3=Color3.fromRGB(145,43,50),
    BorderSizePixel=0,
    Text="ENCERRAR",
    TextColor3=Color3.new(1,1,1),
    Font=Enum.Font.GothamBold,
    TextSize=10,
    ZIndex=10
},Main)
corner(End,5)

connect(End.Activated,function()
    Closed=true
    for _,c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    Gui:Destroy()
end)

-- PRINCIPAL

local Principal=Pages.PRINCIPAL
label(Principal,"REPO SKY | CAR DEALERSHIP TYCOON",30)
label(Principal,"Painel de consulta e configuracao local.",30)
label(Principal,"TP, TAP e voo nao estao ativos nesta versao.",40)

-- VELOCIDADE

local Velocity=Pages.VELOCIDADE
label(Velocity,"CONFIGURACOES",26)

local function speedInput(title,key)
    label(Velocity,title,20)
    local box=make("TextBox", {
        Size=UDim2.new(1,0,0,32),
        BackgroundColor3=Color3.fromRGB(29,36,49),
        TextColor3=Color3.new(1,1,1),
        Text=tostring(Speed[key]),
        ClearTextOnFocus=false,
        Font=Enum.Font.Gotham,
        TextSize=13
    },Velocity)
    corner(box,5)

    connect(box.FocusLost,function()
        local n=tonumber(box.Text)
        if n then Speed[key]=math.clamp(n,0,99999) end
        box.Text=tostring(Speed[key])
    end)
end

speedInput("Velocidade horizontal","Transport")
speedInput("Velocidade de subida","Ascent")
speedInput("Velocidade de descida","Descent")
speedInput("Altura da subida","Height")
speedInput("Tempo de congelamento","Freeze")

-- CARROS: CATALOGO E PESQUISA

local CarPage=Pages.CARROS
label(CarPage,"PESQUISAR VEICULOS",24)

local Search=make("TextBox", {
    Size=UDim2.new(1,0,0,34),
    BackgroundColor3=Color3.fromRGB(29,36,49),
    TextColor3=Color3.new(1,1,1),
    PlaceholderText="Digite o nome do veiculo...",
    PlaceholderColor3=Color3.fromRGB(145,155,170),
    Text="",
    ClearTextOnFocus=false,
    Font=Enum.Font.Gotham,
    TextSize=12
},CarPage)
corner(Search,5)

local Status=label(CarPage,"Aguardando pesquisa...",24)

local Grid=make("ScrollingFrame", {
    Size=UDim2.new(1,0,0,300),
    BackgroundTransparency=1,
    BorderSizePixel=0,
    ScrollBarThickness=5,
    CanvasSize=UDim2.new(),
    AutomaticCanvasSize=Enum.AutomaticSize.Y
},CarPage)

make("UIGridLayout", {
    CellSize=UDim2.new(0,124,0,143),
    CellPadding=UDim2.fromOffset(7,7),
    SortOrder=Enum.SortOrder.LayoutOrder
},Grid)

local function clearGrid()
    for _,v in ipairs(Grid:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
end

local function addCard(name,image,details)
    local card=make("Frame", {
        BackgroundColor3=Color3.fromRGB(27,34,47),
        BorderSizePixel=0
    },Grid)
    corner(card,7)

    local img=make("ImageLabel", {
        Size=UDim2.new(1,-12,0,82),
        Position=UDim2.fromOffset(6,6),
        BackgroundColor3=Color3.fromRGB(19,25,36),
        BorderSizePixel=0,
        Image=image or "",
        ScaleType=Enum.ScaleType.Fit
    },card)
    corner(img,5)

    make("TextLabel", {
        Size=UDim2.new(1,-10,0,28),
        Position=UDim2.fromOffset(5,91),
        BackgroundTransparency=1,
        Text=name,
        TextColor3=Color3.fromRGB(220,228,240),
        Font=Enum.Font.GothamBold,
        TextSize=10,
        TextWrapped=true
    },card)

    make("TextLabel", {
        Size=UDim2.new(1,-10,0,17),
        Position=UDim2.fromOffset(5,120),
        BackgroundTransparency=1,
        Text=details or "",
        TextColor3=Color3.fromRGB(130,175,220),
        Font=Enum.Font.Gotham,
        TextSize=9
    },card)
end

local function getCatalog()
    local ok,result=pcall(function()
        return RS:WaitForChild("Data")
            :WaitForChild("CarShopEntries")
            :WaitForChild("ById")
    end)
    if ok then return result end
end

local function updateCars()
    clearGrid()
    local query=string.lower(Search.Text or "")
    local count=0
    local catalog=getCatalog()

    if not catalog then
        Status.Text="Catalogo CarShopEntries.ById nao encontrado."
        return
    end

    for _,entry in ipairs(catalog:GetChildren()) do
        local display=entry:FindFirstChild("DisplayName")
        local thumb=entry:FindFirstChild("ThumbnailImage")

        local name=display and tostring(display.Value) or entry.Name
        local image=thumb and tostring(thumb.Value) or ""

        if query=="" or string.find(string.lower(name),query,1,true) then
            addCard(name,image,"ID: "..entry.Name)
            count=count+1
        end
    end

    Status.Text=count.." veiculo(s) encontrado(s) no catalogo."
end

local Refresh=button(CarPage,"ATUALIZAR CATALOGO",Color3.fromRGB(35,105,85))
connect(Refresh.Activated,updateCars)
connect(Search:GetPropertyChangedSignal("Text"),updateCars)

-- VEICULOS DO JOGADOR

label(CarPage,"SEUS VEICULOS",24)

local function getOwner(model)
    local stats=model:FindFirstChild("Stats")
    local owner=stats and stats:FindFirstChild("Owner")

    if owner then
        local value
        pcall(function() value=owner.Value end)
        if value==Player or value==Player.Name or value==Player.UserId then
            return true
        end
    end

    local attribute=model:GetAttribute("Owner")
    return attribute==Player.Name or attribute==Player.UserId
end

local function updateOwned()
    local folder=workspace:FindFirstChild("Cars")
    if not folder then
        Status.Text="Workspace.Cars nao encontrado."
        return
    end

    local count=0
    for _,model in ipairs(folder:GetChildren()) do
        if getOwner(model) then
            addCard(model.Name,"","VEICULO SEU")
            count=count+1
        end
    end

    Status.Text=count.." veiculo(s) seu(s) encontrado(s)."
end

local Owned=button(CarPage,"LISTAR MEUS VEICULOS")
connect(Owned.Activated,updateOwned)

print("[REPO SKY] Painel e pesquisa carregados.")
