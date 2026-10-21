-- Pure layout policy; all rectangles are inside the ScreenGui's safe content area.
local L={}
function L.Compute(w,h,touch)
 local compact=w<650 or h<500
 local margin=compact and 12 or 20
 local dockW=math.min(w-24,compact and 296 or 392)
 local dockH=compact and 62 or 72
 local bottom=touch and w<650 and h>w and 132 or 20
 local dockY=math.max(100,h-bottom-dockH)
 local walletW=math.min(232,math.floor(w*.55))
 local collectW=compact and 112 or 148
 return {
  Compact=compact,
  Wallet={margin,12,walletW,56},
  Collect={w-margin-collectW,12,collectW,56},
  Status={margin,74,math.min(w-2*margin,310),20},
  Dock={(w-dockW)/2,dockY,dockW,dockH},
  Intro={(w-math.min(320,w-32))/2,dockY-58,math.min(320,w-32),46},
 }
end
function L.State(s,day)
 local placed=false for _,pet in s.Creatures or {} do if pet.Placed then placed=true break end end
 local claimable=false
 for _,q in s.Quests or {} do if q.Progress>=q.Goal and not q.Claimed then claimable=true break end end
 local discoveries=0 for _ in s.Discovered or {} do discoveries+=1 end
 for _,goal in {3,6,9,12} do
  if discoveries>=goal and not (s.Cosmetics or {})["discovery"..goal] then claimable=true end
 end
 local status=s.Demo and "Teste • progresso temporário" or (s.SaveHealthy==false and "Salvando progresso…" or "")
 return {
  ShowCollect=(s.Stored or 0)>=1,
  ShowIntro=not placed and #(s.Creatures or {})>0,
  Attention=claimable or (s.Daily or day)<day or (s.Event and s.Event.Active) or false,
  Status=status,
 }
end
return L
