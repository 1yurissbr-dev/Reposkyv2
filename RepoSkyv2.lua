
if not game:IsLoaded() then game.Loaded:Wait() end
local P=game:GetService("Players").LocalPlayer
local RS=game:GetService("ReplicatedStorage")
local Run=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local PG=P:WaitForChild("PlayerGui")
for _,n in ipairs({"RepoTPPanel","RepoSkyOpen"}) do local x=PG:FindFirstChild(n) if x then x:Destroy() end end

local S={Transport=9999,Ascent=9999,Descent=9999,Height=400,Freeze=.25,Distance=16}
local C,Selected,Flight,Closed={},nil,nil,false
local function track(c) C[#C+1]=c return c end
local function make(t,p,parent)
 local x=Instance.new(t)
 for k,v in pairs(p or {}) do x[k]=v end
 x.Parent=parent
 return x
end
local function round(x,n) make("UICorner",{CornerRadius=UDim.new(0,n or 7)},x) end
local function label(p,t,h)
 return make("TextLabel",{Size=UDim2.new(1,0,0,h or 25),BackgroundTransparency=1,Text=t,TextColor3=Color3.fromRGB(220,228,240),Font=Enum.Font.Gotham,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},p)
end
local function btn(p,t,fn)
 local b=make("TextButton",{Size=UDim2.new(1,-6,0,34),BackgroundColor3=Color3.fromRGB(38,75,115),Text=t,TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=11},p)
 round(b) track(b.Activated:Connect(fn)) return b
end
local function root(m)
 if not m then return end
 if m:IsA("BasePart") then return m end
 return m.PrimaryPart or m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart",true)
end
local function owner(m)
 local s=m:FindFirstChild("Stats")
 local o=s and s:FindFirstChild("Owner")
 local v
 if o then pcall(function() v=o.Value end) end
 v=v or m:GetAttribute("Owner")
 if typeof(v)=="Instance" then return v.Name end
 if type(v)=="number" then
  if v==P.UserId then return P.Name end
  local pl=game:GetService("Players"):GetPlayerByUserId(v)
  if pl then return pl.Name end
  local ok,n=pcall(function() return P.Parent:GetNameFromUserIdAsync(v) end)
  if ok then return n end
 elseif type(v)=="string" then
  local pl=game:GetService("Players"):FindFirstChild(v)
  if pl then return pl.Name end
  return v
 end
 return "Desconhecido"
end
local function value(obj,key)
 if not obj then return nil end
 local x=obj:FindFirstChild(key,true)
 if x then
  local ok,v=pcall(function() return x.Value end)
  if ok and v~=nil then return v end
 end
 return obj:GetAttribute(key)
end
local function catalog()
 local d=RS:FindFirstChild("Data")
 local c=d and d:FindFirstChild("CarShopEntries")
 return c and c:FindFirstChild("ById")
end
local function info(m)
 local ct=m:FindFirstChild("CarType",true)
 local id
 if ct then pcall(function() id=tostring(ct.Value) end) end
 local cat=catalog()
 local e=id and cat and cat:FindFirstChild(id,true)
 local name=value(e,"DisplayName") or value(m,"DisplayName") or m.Name
 local img=value(e,"ThumbnailImage") or value(e,"Image") or value(m,"ThumbnailImage") or ""
 img=tostring(img)
 if img:match("^%d+$") then img="rbxassetid://"..img end
 return tostring(name),img,owner(m),id
end

-- DETECÇÃO AMPLIADA DE VEÍCULOS
local function isVehicle(m)
 if not m:IsA("Model") or not root(m) then return false end
 if m:FindFirstChildWhichIsA("VehicleSeat",true) then return true end
 if m:FindFirstChild("CarType",true) then return true end
 local stats=m:FindFirstChild("Stats")
 if stats and stats:FindFirstChild("Owner") then return true end
 if m:GetAttribute("Owner")~=nil then return true end
 local par=m.Parent
 return par and (par.Name=="Cars" or par.Name=="RepoCars")
end
local function vehicles()
 local out,seen={},{}
 for _,m in ipairs(workspace:GetDescendants()) do
  if m:IsA("Model") and isVehicle(m) then
   local chosen=m
   local par=m.Parent
   while par and par~=workspace do
    if par:IsA("Model") and isVehicle(par) then chosen=par end
    par=par.Parent
   end
   if not seen[chosen] then
    seen[chosen]=true
    out[#out+1]=chosen
   end
  end
 end
 return out
end
local function seatedCar()
 local ch=P.Character
 local hum=ch and ch:FindFirstChildOfClass("Humanoid")
 local seat=hum and hum.SeatPart
 if not seat then return end
 local m=seat:FindFirstAncestorOfClass("Model")
 while m do
  if isVehicle(m) then return m end
  m=m.Parent and m.Parent:FindFirstAncestorOfClass("Model")
 end
end
local function teleport(m)
 local ch=P.Character
 local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
 local hum=ch and ch:FindFirstChildOfClass("Humanoid")
 local r=root(m)
 if not hrp or not r then return end
 Selected=m
 local seat=m:FindFirstChildWhichIsA("VehicleSeat",true)
 if seat and hum then
  if hum.SeatPart~=seat then
   hrp.CFrame=seat.CFrame*CFrame.new(0,3,0)
   task.wait(.2)
   if seat.Parent and hum.Parent then seat:Sit(hum) end
  end
 else
  hrp.CFrame=r.CFrame*CFrame.new(0,5,0)
 end
end
local function chooseCar()
 local m=seatedCar()
 if m then Selected=m return m end
 for _,v in ipairs(vehicles()) do
  local s=v:FindFirstChild("Stats")
  local o=s and s:FindFirstChild("Owner")
  local own
  if o then pcall(function() own=o.Value end) end
  local attr=v:GetAttribute("Owner")
  if own==P or own==P.Name or own==P.UserId or attr==P.Name or attr==P.UserId then
   Selected=v return v
  end
 end
end
local function stop()
 if Flight then
  for _,x in ipairs(Flight) do pcall(function() x:Destroy() end) end
  Flight=nil
 end
end
local function fly(m,dest)
 stop()
 local r=root(m)
 if not r or not dest then return end
 local target=dest.Position+dest.LookVector*S.Distance
 local facing=CFrame.lookAt(target,target+dest.RightVector,dest.UpVector)
 local att=Instance.new("Attachment",r)
 local lv=Instance.new("LinearVelocity",r)
 lv.Attachment0=att
 lv.RelativeTo=Enum.ActuatorRelativeTo.World
 lv.MaxForce=math.huge
 local ao=Instance.new("AlignOrientation",r)
 ao.Attachment0=att
 ao.Mode=Enum.OrientationAlignmentMode.OneAttachment
 ao.CFrame=facing.Rotation
 ao.MaxTorque=math.huge
 ao.Responsiveness=35
 ao.RigidityEnabled=true
 Flight={lv,att,ao}
 local highY=r.Position.Y+S.Height
 local phase=1
 local conn
 conn=Run.Heartbeat:Connect(function()
  if not r.Parent or not lv.Parent then conn:Disconnect() stop() return end
  local pos=r.Position
  local flat=Vector3.new(pos.X,0,pos.Z)
  local goalFlat=Vector3.new(target.X,0,target.Z)
  local distance=(flat-goalFlat).Magnitude
  local goal,speed
  if phase==1 then
   goal=Vector3.new(pos.X,highY,pos.Z)
   speed=S.Ascent
   if math.abs(pos.Y-highY)<5 then phase=2 end
  elseif phase==2 then
   goal=Vector3.new(target.X,highY,target.Z)
   speed=S.Transport
   if distance<60 then phase=3 end
  else
   goal=Vector3.new(target.X,target.Y+8,target.Z)
   speed=S.Descent
   if (pos-goal).Magnitude<3 then
    lv.VectorVelocity=Vector3.zero
    conn:Disconnect()
    task.delay(S.Freeze,stop)
    return
   end
  end
  local delta=goal-pos
  lv.VectorVelocity=delta.Magnitude>1 and delta.Unit*math.min(speed,delta.Magnitude*3) or Vector3.zero
 end)
 track(conn)
end

local Gui=make("ScreenGui",{Name="RepoTPPanel",ResetOnSpawn=false,DisplayOrder=999},PG)
local OpenGui=make("ScreenGui",{Name="RepoSkyOpen",ResetOnSpawn=false,DisplayOrder=1000},PG)
local Open=make("TextButton",{Size=UDim2.fromOffset(42,42),Position=UDim2.new(0,15,.5,-21),BackgroundColor3=Color3.fromRGB(25,130,75),Text="R",TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=19},OpenGui)
round(Open,12)
local Main=make("Frame",{Size=UDim2.fromOffset(590,440),Position=UDim2.new(.5,-295,.5,-220),BackgroundColor3=Color3.fromRGB(12,16,24),Visible=false},Gui)
round(Main,10)
make("UIStroke",{Color=Color3.fromRGB(45,120,200),Thickness=1.2},Main)
local Header=make("Frame",{Size=UDim2.new(1,0,0,42),BackgroundColor3=Color3.fromRGB(22,29,42)},Main)
round(Header,8)
label(Header,"R | REPO SKY",36)
local Side=make("Frame",{Position=UDim2.fromOffset(9,50),Size=UDim2.new(0,126,1,-59),BackgroundColor3=Color3.fromRGB(18,23,33)},Main)
round(Side)
local Content=make("Frame",{Position=UDim2.fromOffset(144,50),Size=UDim2.new(1,-153,1,-59),BackgroundColor3=Color3.fromRGB(17,22,32)},Main)
round(Content)

local Pages={}
for i,n in ipairs({"PRINCIPAL","VELOCIDADE","CARROS","CÓDIGOS"}) do
 local pg=make("ScrollingFrame",{Name=n,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=5,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),Visible=i==1},Content)
 make("UIListLayout",{Padding=UDim.new(0,7)},pg)
 make("UIPadding",{PaddingTop=UDim.new(0,8),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)},pg)
 Pages[n]=pg
 local tab=make("TextButton",{Name=n,Size=UDim2.new(1,-12,0,39),Position=UDim2.fromOffset(6,8+(i-1)*46),BackgroundColor3=i==1 and Color3.fromRGB(35,105,185) or Color3.fromRGB(39,46,59),Text=n,TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=10},Side)
 round(tab)
 track(tab.Activated:Connect(function()
  for k,v in pairs(Pages) do v.Visible=k==n end
  for _,b in ipairs(Side:GetChildren()) do
   if b:IsA("TextButton") then b.BackgroundColor3=b.Name==n and Color3.fromRGB(35,105,185) or Color3.fromRGB(39,46,59) end
  end
 end))
end

local A=Pages.PRINCIPAL
local function ownVehicle(folder)
 for _,m in ipairs(vehicles()) do
  local par=m
  local inFolder=false
  while par and par~=workspace do
   if par.Name==folder then inFolder=true break end
   par=par.Parent
  end
  if inFolder then
   local s=m:FindFirstChild("Stats")
   local o=s and s:FindFirstChild("Owner")
   local v
   if o then pcall(function() v=o.Value end) end
   if v==P or v==P.Name or v==P.UserId or m:GetAttribute("Owner")==P.Name or m:GetAttribute("Owner")==P.UserId then
    teleport(m) return
   end
  end
 end
end
btn(A,"TP REPO [7]",function() ownVehicle("RepoCars") end)
btn(A,"TP CARRO [8]",function()
 local m=seatedCar() or chooseCar()
 if m then teleport(m) end
end)
btn(A,"VOAR PARA GARAGEM [9]",function()
 local m=seatedCar() or Selected
 local d=workspace:FindFirstChild("RepoShutterBase")
 local part=d and (d:IsA("BasePart") and d or root(d))
 if m and part then Selected=m fly(m,part.CFrame) end
end)
btn(A,"PARAR TRANSPORTE [P]",stop)
label(A,"7 REPO | 8 CARRO | 9 VOAR | P PARAR",24)

local V=Pages.VELOCIDADE
for _,k in ipairs({"Transport","Ascent","Descent","Height","Freeze","Distance"}) do
 label(V,(k=="Distance" and "Distância da garagem" or k).."  "..S[k],22)
 local b=make("TextBox",{Size=UDim2.new(1,0,0,30),BackgroundColor3=Color3.fromRGB(29,36,49),TextColor3=Color3.new(1,1,1),Text=tostring(S[k]),ClearTextOnFocus=false,Font=Enum.Font.Gotham,TextSize=12},V)
 round(b)
 track(b.FocusLost:Connect(function()
  S[k]=math.max(0,tonumber(b.Text) or S[k])
  b.Text=tostring(S[k])
 end))
end

local Car=Pages.CARROS
local Search=make("TextBox",{Size=UDim2.new(1,0,0,34),BackgroundColor3=Color3.fromRGB(29,36,49),TextColor3=Color3.new(1,1,1),PlaceholderText="Pesquisar carro ou dono...",Text="",ClearTextOnFocus=false,Font=Enum.Font.Gotham,TextSize=12},Car)
round(Search)
local Status=label(Car,"",22)
local Grid=make("Frame",{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1},Car)
local Layout=make("UIGridLayout",{CellSize=UDim2.new(0,155,0,160),CellPadding=UDim2.fromOffset(7,7)},Grid)
track(Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
 Grid.Size=UDim2.new(1,0,0,Layout.AbsoluteContentSize.Y)
end))
local function refresh()
 for _,x in ipairs(Grid:GetChildren()) do if x:IsA("Frame") then x:Destroy() end end
 local q=string.lower(Search.Text)
 local count=0
 for _,m in ipairs(vehicles()) do
  local name,img,own=info(m)
  if q=="" or name:lower():find(q,1,true) or own:lower():find(q,1,true) then
   local card=make("Frame",{BackgroundColor3=Color3.fromRGB(27,34,47)},Grid)
   round(card)
   make("ImageLabel",{Size=UDim2.new(1,-10,0,85),Position=UDim2.fromOffset(5,5),BackgroundTransparency=1,Image=img,ScaleType=Enum.ScaleType.Fit},card)
   make("TextLabel",{Size=UDim2.new(1,-8,0,25),Position=UDim2.fromOffset(4,91),BackgroundTransparency=1,Text=name,TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=10,TextWrapped=true},card)
   make("TextLabel",{Size=UDim2.new(1,-8,0,18),Position=UDim2.fromOffset(4,116),BackgroundTransparency=1,Text="Dono: "..own,TextColor3=Color3.fromRGB(145,185,225),Font=Enum.Font.Gotham,TextSize=9,TextWrapped=true},card)
   local go=make("TextButton",{Size=UDim2.new(1,-10,0,22),Position=UDim2.fromOffset(5,136),BackgroundColor3=Color3.fromRGB(35,95,155),Text="TP CARRO",TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=9},card)
   round(go,4)
   track(go.Activated:Connect(function() teleport(m) end))
   count+=1
  end
 end
 Status.Text=count.." veículo(s) encontrados"
end
track(Search:GetPropertyChangedSignal("Text"):Connect(refresh))
btn(Car,"ATUALIZAR",refresh)

-- CÓDIGOS
local CP=Pages["CÓDIGOS"]
local Http=game:GetService("HttpService")
local URL="https://raw.githubusercontent.com/1yurissbr-dev/Reposkyv2/main/codes.json"
local Codes,Chosen,Busy={},nil,false
local CS=label(CP,"Aguardando códigos...",30)
local Entry=make("TextBox",{Size=UDim2.new(1,-6,0,34),BackgroundColor3=Color3.fromRGB(29,36,49),TextColor3=Color3.new(1,1,1),PlaceholderText="Código selecionado ou manual...",Text="",ClearTextOnFocus=false,Font=Enum.Font.Gotham,TextSize=12},CP)
round(Entry)
local function loadCodes()
 local ok,data=pcall(function() return Http:JSONDecode(game:HttpGet(URL)) end)
 if not ok or type(data)~="table" or type(data.codes)~="table" then CS.Text="Falha ao carregar códigos." return end
 Codes={}
 local seen={}
 for _,v in ipairs(data.codes) do
  local code=type(v)=="string" and v or type(v)=="table" and (v.code or v.Code)
  if type(code)=="string" and code~="" and not seen[code] then
   seen[code]=true Codes[#Codes+1]=code
  end
 end
 CS.Text=#Codes.." código(s) carregado(s)."
end
local function fillCode(code)
 local menu=PG:FindFirstChild("Menu")
 local settings=menu and menu:FindFirstChild("Settings")
 local panel=settings and settings:FindFirstChild("Code")
 local input=panel and panel:FindFirstChild("TextBox")
 if not input or not input:IsA("TextBox") then
  CS.Text="Abra Menu > Settings > Code."
  return false
 end
 input:CaptureFocus()
 input.Text=code
 input:ReleaseFocus()
 CS.Text="Código preenchido. Toque em Submit."
 return true
end
btn(CP,"CARREGAR CÓDIGOS",loadCodes)
btn(CP,"PREENCHER CÓDIGO",function()
 if Busy then return end
 Busy=true
 fillCode(Entry.Text)
 Busy=false
end)
btn(CP,"PREENCHER TODOS",function()
 if Busy then return end
 if #Codes==0 then CS.Text="Nenhum código carregado." return end
 Busy=true
 local n=0
 for _,code in ipairs(Codes) do
  if Closed then break end
  Entry.Text=code
  if fillCode(code) then n+=1 end
  task.wait(1)
 end
 CS.Text=n.."/"..#Codes.." códigos preenchidos. Envie no jogo."
 Busy=false
end)
btn(CP,"PRÓXIMO CÓDIGO",function()
 if #Codes==0 then CS.Text="Carregue os códigos primeiro." return end
 local i=table.find(Codes,Chosen) or 0
 i=i%#Codes+1
 Chosen=Codes[i]
 Entry.Text=Chosen
 CS.Text="Selecionado "..i.."/"..#Codes
end)

local function drag(obj,handle)
 local moving,start,pos
 track(handle.InputBegan:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then moving=true start=i.Position pos=obj.Position end
 end))
 track(UIS.InputChanged:Connect(function(i)
  if moving and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then
   local d=i.Position-start
   obj.Position=UDim2.new(pos.X.Scale,pos.X.Offset+d.X,pos.Y.Scale,pos.Y.Offset+d.Y)
  end
 end))
 track(UIS.InputEnded:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then moving=false end
 end))
end
drag(Main,Header)
drag(Open,Open)
track(Open.Activated:Connect(function() Main.Visible=not Main.Visible end))
local Min=make("TextButton",{Size=UDim2.fromOffset(30,28),Position=UDim2.new(1,-73,0,7),BackgroundColor3=Color3.fromRGB(45,85,135),Text="_",TextColor3=Color3.new(1,1,1)},Header)
local Close=make("TextButton",{Size=UDim2.fromOffset(32,28),Position=UDim2.new(1,-38,0,7),BackgroundColor3=Color3.fromRGB(145,43,50),Text="X",TextColor3=Color3.new(1,1,1)},Header)
track(Min.Activated:Connect(function() Main.Visible=false end))
track(Close.Activated:Connect(function() Main.Visible=false end))
btn(A,"ENCERRAR",function()
 if Closed then return end
 Closed=true stop()
 for _,c in ipairs(C) do pcall(function() c:Disconnect() end) end
 Gui:Destroy() OpenGui:Destroy()
end)
track(UIS.InputBegan:Connect(function(i,g)
 if g or Closed then return end
 if i.KeyCode==Enum.KeyCode.Seven then ownVehicle("RepoCars")
 elseif i.KeyCode==Enum.KeyCode.Eight then
  local m=seatedCar() or chooseCar()
  if m then teleport(m) end
 elseif i.KeyCode==Enum.KeyCode.Nine then
  local m=seatedCar() or Selected
  local d=workspace:FindFirstChild("RepoShutterBase")
  local part=d and (d:IsA("BasePart") and d or root(d))
  if m and part then fly(m,part.CFrame) end
 elseif i.KeyCode==Enum.KeyCode.P then stop() end
end))
refresh()
