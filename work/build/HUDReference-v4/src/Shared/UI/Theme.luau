local T={}
T.Bg=Color3.fromRGB(7,15,36)
T.Panel=Color3.fromRGB(12,30,61)
T.Card=Color3.fromRGB(19,43,77)
T.Text=Color3.fromRGB(245,249,255)
T.Muted=Color3.fromRGB(156,182,211)
T.Cyan=Color3.fromRGB(40,213,255)
T.Purple=Color3.fromRGB(172,85,255)
T.Pink=Color3.fromRGB(255,86,199)
T.Green=Color3.fromRGB(41,193,91)
T.Gold=Color3.fromRGB(255,204,65)
T.Red=Color3.fromRGB(233,69,99)
T.Rarity={Color3.fromRGB(170,191,213),Color3.fromRGB(104,230,101),T.Cyan,T.Purple,T.Gold,T.Pink}
T.RarityNames={"Comum","Incomum","Raro","Épico","Lendário","Mítico"}
T.ReducedMotion=false
function T.Number(n)
 n=tonumber(n) or 0
 if n>=1e6 then return string.format("%.2fM",n/1e6) elseif n>=1e3 then return string.format("%.1fK",n/1e3) end
 return tostring(math.floor(n))
end
function T.Time(n) return string.format("%02d:%02d",math.floor(n/60),n%60) end
return T
