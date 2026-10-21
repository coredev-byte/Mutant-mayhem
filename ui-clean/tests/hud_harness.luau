local function signal()
 local s={callbacks={}}
 function s:Connect(fn) table.insert(self.callbacks,fn) return {Disconnect=function() end} end
 function s:Fire(...) for _,fn in self.callbacks do fn(...) end end
 return s
end
local methods={}
function methods:SetAttribute(k,v) self.Attributes[k]=v end
function methods:GetAttribute(k) return self.Attributes[k] end
function methods:GetPropertyChangedSignal(k) self.Signals[k]=self.Signals[k] or signal() return self.Signals[k] end
function methods:IsDescendantOf(p) local at=self.Parent while at do if at==p then return true end at=at.Parent end return false end
local function node(class,parent,props)
 local o={ClassName=class,Name=class,Parent=parent,Children={},Attributes={},Signals={},Visible=true,AbsoluteSize={X=390,Y=744}}
 setmetatable(o,{__index=function(t,k) if methods[k] then return methods[k] end for _,c in t.Children do if c.Name==k then return c end end end})
 for k,v in props or {} do o[k]=v end
 for _,name in {"MouseEnter","MouseLeave","SelectionGained","SelectionLost","Activated"} do o[name]=signal() end
 if parent then table.insert(parent.Children,o) end return o
end
local function dim(x,y) return {X={Offset=x,Scale=0},Y={Offset=y,Scale=0}} end
local U={fromOffset=dim,fromScale=function(x,y) return {X={Scale=x,Offset=0},Y={Scale=y,Offset=0}} end,new=function(a,b,c,d) return {X={Scale=a,Offset=b},Y={Scale=c,Offset=d}} end}
local C={New=node}
function C.Frame(p,n,c) return node("Frame",p,{Name=n,BackgroundColor3=c}) end
function C.Label(p,t,size,col) return node("TextLabel",p,{Text=t,TextSize=size,TextColor3=col}) end
function C.Corner(o,r) o.Radius=r or 12 end
function C.Stroke(p,c,w) return node("UIStroke",p,{Color=c,Thickness=w}) end
function C.Icon(p,k,size) return node("Frame",p,{Name="Icon",IconKey=k,Size=dim(size,size)}) end
local Theme={Text={},Muted={},ReducedMotion=true,Number=function(n) return tostring(math.floor(n or 0)) end}
local Gui=node("GuiService",nil,{MenuIsOpen=false})
local Input=node("Input",nil,{TouchEnabled=true,PreferredInput="Gamepad",InputBegan=signal()})
function Input:GetFocusedTextBox() return self.TextBox end
local CAS={Binds={}}
function CAS:BindActionAtPriority(name,fn) self.Binds[name]=fn end
local services={GuiService=Gui,UserInputService=Input,ContextActionService=CAS,TweenService={Create=function() return {Play=function() end,Cancel=function() end} end}}
local gameMock={ReplicatedStorage={MM={Shared={UI={Components="Components",Theme="Theme",HUDSkin="Skin",HUDLayout="Layout"}}}}}
function gameMock:GetService(name) return services[name] end
local enum=setmetatable({},{__index=function(t,k) local v=setmetatable({},{__index=function(_,name) return name end}) rawset(t,k,v) return v end})
local cache={Components=C}
local env=setmetatable({
 game=gameMock,Enum=enum,UDim2=U,Vector2={new=function(x,y) return {X=x,Y=y} end},
 Color3={fromRGB=function(...) return {...} end},TweenInfo={new=function() return {} end},
}, {__index=getfenv()})
env.require=function(name)
 if cache[name] then return cache[name] end
 local fn=assert(loadstring(sources[name],name));setfenv(fn,env);cache[name]=fn();return cache[name]
end
local calls={}
local app={Root=node("ScreenGui"),Window={Visible=false},CloseButton=node("TextButton"),Data={}}
function app:Open(page) self.Page=page self.Window.Visible=true end
function app:Close() self.Page=nil self.Window.Visible=false end
function app:Travel(...) table.insert(calls,{...}) return {Ok=true} end
function app:Toast(message) self.LastToast=message end
local H=env.require("HUD").Build(app)
local root=app.Root.MainHUD
local s={Coins=100,Rate=1,Stored=0,Creatures={{Id="one"}},Daily=math.floor(os.time()/86400),SaveHealthy=true,Event={Active=false},Cosmetics={},Quests={}}
H.Update(s)
assert(root.FirstPet.Visible and not root.Collect.Visible)
assert(root.Wallet.Amount.Text=="100")
assert(root.PrimaryDock.Pets.HitTarget.NextSelectionRight==root.PrimaryDock.Mutation.HitTarget)
root.FirstPet.HitTarget.Activated:Fire()
assert(calls[1][1]=="Lab" and calls[1][2]=="Place" and calls[1][3]=="one")
Gui.SelectedObject=root.FirstPet.HitTarget
s.Creatures[1].Placed=true s.Stored=25 H.Update(s)
assert(not root.FirstPet.Visible and root.Collect.Visible and Gui.SelectedObject==app.FirstNav)
s.SaveHealthy=false H.Update(s) root.Collect.HitTarget.Activated:Fire()
assert(#calls==1,"Unhealthy saving must block collect")
s.SaveHealthy=true H.Update(s) root.Collect.HitTarget.Activated:Fire()
assert(#calls==2 and calls[2][2]=="Collect")
for _,pair in {{"Pets","Pets"},{"Mutation","Mutation"},{"Laboratory","Lab"},{"Menu","Menu"}} do
 root.PrimaryDock[pair[1]].HitTarget.Activated:Fire() assert(app.Page==pair[2])
end
app:Close()
env.require("Navigation").Start(app)
assert(CAS.Binds.MMNext("MMNext","Begin")=="Pass","Bumpers must pass during gameplay")
CAS.Binds.MMOpen("MMOpen","Begin") assert(app.Page=="Menu")
CAS.Binds.MMBack("MMBack","Begin") assert(not app.Page)
app:Open("Shop") CAS.Binds.MMBack("MMBack","Begin") assert(app.Page=="Menu")
app:Open("Details") CAS.Binds.MMBack("MMBack","Begin") assert(app.Page=="Pets")
Input.TextBox={} app:Close()
assert(CAS.Binds.MMOpen("MMOpen","Begin")=="Pass" and not app.Page)
print("Actual HUD/controller callbacks, conditional visibility, focus recovery and gamepad routing passed with UI API doubles")

-- Serialize the real HUD tree to a layout illustration, not a Roblox screenshot.
local function esc(x) return tostring(x):gsub("&","&amp;"):gsub("<","&lt;"):gsub(">","&gt;") end
local function color(c) if not c then return "#eaf2fa" end return string.format("#%02x%02x%02x",c[1] or 0,c[2] or 0,c[3] or 0) end
local function svg(w,h)
 local out={string.format('<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d">',w,h,w,h)}
 table.insert(out,'<defs><radialGradient id="bg"><stop stop-color="#375d72"/><stop offset="1" stop-color="#142c40"/></radialGradient></defs><rect width="100%" height="100%" fill="url(#bg)"/>')
 table.insert(out,string.format('<text x="%g" y="%g" fill="#a1beca" opacity=".65" font-family="sans-serif" font-size="14" text-anchor="middle">Área livre para o jogo</text>',w/2,h*.44))
 local function draw(o,px,py,pw,ph)
  if not o.Visible then return end
  local pos=o.Position or U.fromOffset(0,0)
  local size=o.Size or U.fromOffset(0,0)
  local width=size.X.Scale*pw+size.X.Offset local height=size.Y.Scale*ph+size.Y.Offset
  local a=o.AnchorPoint or {X=0,Y=0}
  local x=px+pos.X.Scale*pw+pos.X.Offset-a.X*width local y=py+pos.Y.Scale*ph+pos.Y.Offset-a.Y*height
  if o.IconKey then
   local glyph=({Coins="●",Pets="♧",Mutation="⌘",Laboratory="⚗"})[o.IconKey] or "•"
   table.insert(out,string.format('<text x="%g" y="%g" text-anchor="middle" fill="%s" font-family="sans-serif" font-size="%g">%s</text>',x+width/2,y+height*.8,o.IconKey=="Coins" and "#ffcc41" or "#64d3e5",width,esc(glyph)))
  elseif o.ClassName=="Frame" and o.BackgroundColor3 and (o.BackgroundTransparency or 0)<1 then
   table.insert(out,string.format('<rect x="%g" y="%g" width="%g" height="%g" rx="%g" fill="%s" opacity="%g"/>',x,y,width,height,o.Radius or 0,color(o.BackgroundColor3),1-(o.BackgroundTransparency or 0)))
  elseif o.ClassName=="TextLabel" and o.Text~="" then
   local center=o.TextXAlignment=="Center"
   table.insert(out,string.format('<text x="%g" y="%g" text-anchor="%s" fill="%s" font-family="sans-serif" font-size="%g">%s</text>',center and x+width/2 or x,y+height/2+(o.TextSize or 14)*.35,center and "middle" or "start",color(o.TextColor3),o.TextSize or 14,esc(o.Text)))
  end
  for _,child in o.Children do draw(child,x,y,width,height) end
 end
 draw(root,0,0,w,h)
 table.insert(out,'</svg>') return table.concat(out)
end
s.SaveHealthy=true s.Demo=false s.Stored=120 s.Coins=12450 s.Rate=24 s.Creatures[1].Placed=true
for _,view in {{"desktop",1280,720,false},{"portrait",390,744,true},{"landscape",750,345,true}} do
 root.AbsoluteSize={X=view[2],Y=view[3]} Input.TouchEnabled=view[4]
 H.Update(s)
 print("UI_PREVIEW_"..view[1]..":"..svg(view[2],view[3]))
end
