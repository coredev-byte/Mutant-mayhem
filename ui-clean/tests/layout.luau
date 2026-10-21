local L=require("../../outputs/MutantMayhem/src/Shared/UI/HUDLayout")
local sizes={{320,480,true},{390,744,true},{401,742,true},{568,260,true},{750,345,true},{1024,732,true},{1366,732,false},{1920,1044,false},{3440,1404,false}}
local function overlap(a,b)
 return a[1]<b[1]+b[3] and b[1]<a[1]+a[3] and a[2]<b[2]+b[4] and b[2]<a[2]+a[4]
end
for _,v in sizes do
 local l=L.Compute(v[1],v[2],v[3])
 local rects={l.Wallet,l.Collect,l.Status,l.Dock,l.Intro}
 for i,r in rects do
  assert(r[1]>=0 and r[2]>=0 and r[1]+r[3]<=v[1]+.01 and r[2]+r[4]<=v[2]+.01,"Outside safe content bounds")
  for j=i+1,#rects do assert(not overlap(r,rects[j]),"HUD rectangles overlap") end
 end
 assert((l.Dock[3]-28)/4>=44 and l.Dock[4]-10>=44,"Touch target too small")
 if v[3] and v[1]<650 and v[2]>v[1] then assert(v[2]-l.Dock[2]-l.Dock[4]>=132,"Touch controls reserve") end
 print(string.format("LAYOUT %d %d %s %g %g %g %g",v[1],v[2],tostring(v[3]),table.unpack(l.Dock)))
end
local s={Coins=100,Rate=0,Stored=0,Creatures={{Id="first"}},Daily=10,SaveHealthy=true,Event={Active=false},Cosmetics={},Quests={}}
local v=L.State(s,10)
assert(v.ShowIntro and not v.ShowCollect and not v.Attention and v.Status=="")
s.Creatures[1].Placed=true s.Stored=.9
v=L.State(s,10) assert(not v.ShowIntro and not v.ShowCollect)
s.Stored=1 s.SaveHealthy=false
v=L.State(s,10) assert(v.ShowCollect and v.Status~="")
s.Demo=true assert(L.State(s,10).Status=="Teste • progresso temporário")
s.Demo=false s.SaveHealthy=true s.Daily=9
assert(L.State(s,10).Attention)
s.Daily=10 s.Quests={{Goal=5,Progress=5,Claimed=false}}
assert(L.State(s,10).Attention)
s.Quests[1].Claimed=true assert(not L.State(s,10).Attention)
s.Quests={} s.Event.Active=true assert(L.State(s,10).Attention)
s.Event.Active=false s.Creatures={} assert(not L.State(s,10).ShowIntro)
s.Discovered={a=true,b=true,c=true} assert(L.State(s,10).Attention)
s.Cosmetics.discovery3=true assert(not L.State(s,10).Attention)
print("HUD layout and state tests passed")
