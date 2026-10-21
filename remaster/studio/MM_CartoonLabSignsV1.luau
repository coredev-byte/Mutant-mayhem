-- CAOS MUTANTE — placas cartunescas para os 12 laboratorios.
-- Somente visual; mantem BillboardGui.TextLabel (nome do dono atualizado por Bootstrap/PlotService).
-- Idempotente. Nao altera pads, donos, economia, modelos ou interacoes.
local M = {}

local INK = Color3.fromRGB(33, 43, 78)
local MILK = Color3.fromRGB(255, 250, 235)
local GOLD = Color3.fromRGB(255, 218, 100)
local PALETTES = {
 {main=Color3.fromRGB(255, 153, 169),soft=Color3.fromRGB(255, 221, 211),accent=Color3.fromRGB(255, 110, 157)},
 {main=Color3.fromRGB(104, 215, 196),soft=Color3.fromRGB(211, 248, 231),accent=Color3.fromRGB(35, 173, 180)},
 {main=Color3.fromRGB(179, 153, 250),soft=Color3.fromRGB(229, 214, 255),accent=Color3.fromRGB(137, 108, 228)},
 {main=Color3.fromRGB(255, 198, 111),soft=Color3.fromRGB(255, 242, 185),accent=Color3.fromRGB(249, 149, 88)}
}

local function corner(parent,radius)
 local x=Instance.new("UICorner")
 x.CornerRadius=UDim.new(0,radius)
 x.Parent=parent
 return x
end
local function border(parent,width,color,alpha)
 local x=Instance.new("UIStroke")
 x.Thickness=width
 x.Color=color
 x.Transparency=alpha or 0
 x.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
 x.Parent=parent
 return x
end
local function rect(parent,name,position,size,color,z,transparency,radius)
 local x=Instance.new("Frame")
 x.Name=name
 x.BorderSizePixel=0
 x.Position=position
 x.Size=size
 x.BackgroundColor3=color
 x.BackgroundTransparency=transparency or 0
 x.ZIndex=z
 x.Parent=parent
 if radius then corner(x,radius) end
 return x
end
local function text(parent,name,value,position,size,color,font,textSize,z)
 local x=Instance.new("TextLabel")
 x.Name=name
 x.BackgroundTransparency=1
 x.Position=position
 x.Size=size
 x.Text=value
 x.TextColor3=color
 x.Font=font
 x.TextSize=textSize
 x.TextXAlignment=Enum.TextXAlignment.Center
 x.TextYAlignment=Enum.TextYAlignment.Center
 x.ZIndex=z
 x.Parent=parent
 return x
end

function M.StylePlot(plot)
 if not plot or not plot:IsA("Model") then return false end
 local sign=plot:FindFirstChild("Sign")
 if not(sign and sign:IsA("BasePart")) then return false end
 local gui=sign:FindFirstChildOfClass("BillboardGui")
 local title=gui and gui:FindFirstChild("TextLabel")
 if not(title and title:IsA("TextLabel")) then return false end
 if gui:FindFirstChild("MM_CartoonPlate") then return false end

 local id=tonumber(plot:GetAttribute("PlotId")) or tonumber(plot.Name:match("%d+")) or 1
 local scheme=PALETTES[((id-1)%#PALETTES)+1]
 sign.Transparency=1
 sign.CanCollide=false
 sign.CanTouch=false
 sign.CanQuery=false
 gui.Enabled=true
 gui.Size=UDim2.fromOffset(296,94)
 gui.StudsOffset=Vector3.new(0,5.1,0)
 gui.StudsOffsetWorldSpace=Vector3.zero
 gui.MaxDistance=110
 gui.AlwaysOnTop=false
 gui.LightInfluence=0
 gui.ZIndexBehavior=Enum.ZIndexBehavior.Global

 -- 2D sticker shadow + thick ink outline, in front of the canopy.
 local shadow=rect(gui,"MM_CartoonDropShadow",UDim2.fromOffset(9,10),UDim2.new(1,-13,1,-15),INK,1,.35,21)
 local plate=rect(gui,"MM_CartoonPlate",UDim2.fromOffset(4,3),UDim2.new(1,-13,1,-15),scheme.main,2,0,21)
 border(plate,4,INK,0)
 local gradient=Instance.new("UIGradient")
 gradient.Color=ColorSequence.new{
  ColorSequenceKeypoint.new(0,scheme.soft),
  ColorSequenceKeypoint.new(.60,scheme.main),
  ColorSequenceKeypoint.new(1,scheme.accent)
 }
 gradient.Rotation=10
 gradient.Parent=plate

 -- Shine across top, plus a colored footer strip.
 rect(plate,"LightSheen",UDim2.fromOffset(9,7),UDim2.new(1,-18,0,12),Color3.new(1,1,1),3,.56,8)
 rect(plate,"FooterStripe",UDim2.new(0,65,1,-9),UDim2.new(1,-80,0,4),INK,3,.48,3)

 local medal=rect(plate,"StarMedallion",UDim2.fromOffset(10,13),UDim2.fromOffset(54,54),INK,4,0,16)
 border(medal,2,MILK,.12)
 local star=text(medal,"StarIcon","★",UDim2.fromOffset(3,0),UDim2.new(1,-6,1,-2),GOLD,Enum.Font.Cartoon,35,5)
 star.TextStrokeColor3=Color3.fromRGB(100,70,30)
 star.TextStrokeTransparency=.42
 -- Avoid font-dependent decorative glyphs: the central star medallion is the accent.

 -- The SAME TextLabel the game already updates with the owner's display name.
 title.Position=UDim2.fromOffset(73,10)
 title.Size=UDim2.new(1,-89,0,46)
 title.BackgroundTransparency=1
 title.Font=Enum.Font.Cartoon
 title.TextColor3=MILK
 title.TextStrokeColor3=INK
 title.TextStrokeTransparency=.08
 title.TextScaled=false
 title.TextSize=30
 title.TextWrapped=false
 title.TextTruncate=Enum.TextTruncate.AtEnd
 title.TextXAlignment=Enum.TextXAlignment.Center
 title.TextYAlignment=Enum.TextYAlignment.Center
 title.ZIndex=7
 local limit=title:FindFirstChild("MM_CartoonTextLimit") or Instance.new("UITextSizeConstraint")
 limit.Name="MM_CartoonTextLimit"
 limit.MinTextSize=12
 limit.MaxTextSize=38
 limit.Parent=title

 local tagline=text(gui,"MM_CartoonSubtitle","LABORATÓRIO MUTANTE",UDim2.fromOffset(77,58),UDim2.new(1,-98,0,18),INK,Enum.Font.GothamBold,12,7)
 tagline.TextTransparency=.04
 tagline.TextScaled=true
 local subtitleLimit=Instance.new("UITextSizeConstraint")
 subtitleLimit.MaxTextSize=13
 subtitleLimit.MinTextSize=9
 subtitleLimit.Parent=tagline
 gui:SetAttribute("MM_CartoonVersion",1)
 gui:SetAttribute("MM_StyleTheme",((id-1)%#PALETTES)+1)
 return true
end

function M.Apply()
 local w=workspace:FindFirstChild("MM_World")
 local plots=w and w:FindFirstChild("Plots")
 if not plots then return {status="waiting_for_plots",styled=0,scanned=0} end
 local scanned,styled=0,0
 for _,plot in ipairs(plots:GetChildren()) do
  if plot:IsA("Model") then
   scanned+=1
   if M.StylePlot(plot) then styled+=1 end
  end
 end
 return {status="ok",styled=styled,scanned=scanned}
end
return M
