
if not game:IsLoaded() then game.Loaded:Wait() end
local P=game:GetService("Players").LocalPlayer
local RS=game:GetService("ReplicatedStorage")
local Run=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local PG=P:WaitForChild("PlayerGui")
for _,n in ipairs({"RepoTPPanel","RepoSkyOpen"}) do local x=PG:FindFirstChild(n) if x then x:Destroy() end end

local S={Transport=600,Ascent=350,Descent=450,Height=685,Freeze=1.5,Distance=9}
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
local function playerName(v)
 if typeof(v)=="Instance" then
  if v:IsA("Player") then return v.Name,v==P end
  if v:IsA("Model") then
   local pl=game:GetService("Players"):FindFirstChild(v.Name)
   if pl then return pl.Name,pl==P end
  end
 end
 if type(v)=="number" then
  if v==P.UserId then return P.Name,true end
  local pl=game:GetService("Players"):GetPlayerByUserId(v)
  if pl then return pl.Name,false end
  local ok,n=pcall(function() return P.Parent:GetNameFromUserIdAsync(v) end)
  if ok then return n,false end
 elseif type(v)=="string" then
  local pl=game:GetService("Players"):FindFirstChild(v)
  if pl then return pl.Name,pl==P end
  for _,p in ipairs(game:GetService("Players"):GetPlayers()) do
   if p.DisplayName==v then return p.Name,p==P end
  end
  return v,v==P.Name
 end
 return "Desconhecido",false
end
local function owner(m)
 local s=m:FindFirstChild("Stats")
 local o=s and s:FindFirstChild("Owner")
 local v
 if o then
  pcall(function()
   if o:IsA("ObjectValue") or o:IsA("ValueBase") then v=o.Value end
  end)
 end
 v=v or m:GetAttribute("Owner")
 return playerName(v)
end
local function catalog()
 local ok,x=pcall(function() return RS:WaitForChild("Data"):WaitForChild("CarShopEntries"):WaitForChild("ById") end)
 return ok and x
end
local function imageId(v)
 if v==nil then return "" end
 local s=tostring(v)
 if s=="" then return "" end
 if s:match("^%d+$") then return "rbxassetid://"..s end
 return s
end
local function info(m)
 local ct=m:FindFirstChild("CarType",true)
 local id=ct and tostring(ct.Value)
 local cat=catalog()
 local e=id and cat and cat:FindFirstChild(id)
 local function field(obj,n)
  if not obj then return nil end
  local x=obj:FindFirstChild(n)
  if x then
   local ok,v=pcall(function() return x.Value end)
   if ok and v~=nil then return v end
  end
  return obj:GetAttribute(n)
 end
 local name=field(e,"DisplayName") or (e and e:GetAttribute("DisplayName")) or m.Name
 local img=field(e,"ThumbnailImage") or field(e,"Image") or ""
 local own=owner(m)
 return tostring(name),imageId(img),own,id
end
local function vehicles()
 local out,seen={},{}
 for _,folderName in ipairs({"Cars","RepoCars"}) do
  local f=workspace:FindFirstChild(folderName)
  if f then
   for _,m in ipairs(f:GetChildren()) do
    if m:IsA("Model") and root(m) and not seen[m] then
     seen[m]=true out[#out+1]=m
    end
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
 while m and m.Parent do
  if m.Parent==workspace:FindFirstChild("Cars") or m.Parent==workspace:FindFirstChild("RepoCars") then return m end
  m=m.Parent:IsA("Model") and m.Parent or nil
 end
end
local function teleport(m)
 local ch=P.Character
 local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
 local r=root(m)
 if not hrp or not r then return end
 Selected=m
 local seat=m:FindFirstChildWhichIsA("VehicleSeat",true)
 local hum=ch:FindFirstChildOfClass("Humanoid")
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
 for _,folder in ipairs({"Cars","RepoCars"}) do
  local f=workspace:FindFirstChild(folder)
  if f then
   for _,v in ipairs(f:GetChildren()) do
    if v:IsA("Model") then
     local _,mine=owner(v)
     if mine then Selected=v return v end
    end
   end
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
 local target=dest.Position-dest.LookVector*S.Distance
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
for i,n in ipairs({"PRINCIPAL","VELOCIDADE","CARROS"}) do
 local pg=make("ScrollingFrame",{Name=n,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=5,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),Visible=i==1},Content)
 make("UIListLayout",{Padding=UDim.new(0,7)},pg)
 make("UIPadding",{PaddingTop=UDim.new(0,8),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)},pg)
 Pages[n]=pg
 local tab=make("TextButton",{Name=n,Size=UDim2.new(1,-12,0,39),Position=UDim2.fromOffset(6,8+(i-1)*46),BackgroundColor3=i==1 and Color3.fromRGB(35,105,185) or Color3.fromRGB(39,46,59),Text=n,TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=11},Side)
 round(tab)
 track(tab.Activated:Connect(function()
  for k,v in pairs(Pages) do v.Visible=k==n end
  for _,b in ipairs(Side:GetChildren()) do
   if b:IsA("TextButton") then b.BackgroundColor3=b.Name==n and Color3.fromRGB(35,105,185) or Color3.fromRGB(39,46,59) end
  end
 end))
end

local A=Pages.PRINCIPAL
btn(A,"TP REPO [7]",function()
 local f=workspace:FindFirstChild("RepoCars")
 if f then
  for _,m in ipairs(f:GetChildren()) do
   if m:IsA("Model") then
    local _,mine=owner(m)
    if mine then teleport(m) return end
   end
  end
 end
end)
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
 label(V,k=="Distance" and "Distância da garagem (studs)  "..S[k] or k.."  "..S[k],22)
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
 for _,x in ipairs(Grid:GetChildren()) do
  if x:IsA("Frame") then x:Destroy() end
 end
 local q=string.lower(Search.Text)
 local count=0
 for _,m in ipairs(vehicles()) do
  local name,img,own=info(m)
  if q=="" or string.find(string.lower(name),q,1,true) or string.find(string.lower(own),q,1,true) then
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
 Status.Text=count.." veículo(s), incluindo Repos quando encontrados"
end
track(Search:GetPropertyChangedSignal("Text"):Connect(refresh))
btn(Car,"ATUALIZAR",refresh)

local function drag(obj,handle)
 local moving,start,pos
 track(handle.InputBegan:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
   moving=true start=i.Position pos=obj.Position
  end
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
 Closed=true
 stop()
 for _,c in ipairs(C) do pcall(function() c:Disconnect() end) end
 Gui:Destroy()
 OpenGui:Destroy()
end)
track(UIS.InputBegan:Connect(function(i,g)
 if g or Closed then return end
 if i.KeyCode==Enum.KeyCode.Seven then
  local f=workspace:FindFirstChild("RepoCars")
  if f then for _,m in ipairs(f:GetChildren()) do if m:IsA("Model") then local _,mine=owner(m) if mine then teleport(m) break end end end end
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
