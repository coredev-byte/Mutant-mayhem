local Market=game:GetService("MarketplaceService")
local D=require(script.Parent.PlayerDataService)
local C=require(game.ReplicatedStorage.MM.Shared.GameConfig)
local A=require(script.Parent.AnalyticsService)
local S={}
function S.Refresh(player)
	local owned={}
	for id,def in C.Passes do local ok,yes=pcall(Market.UserOwnsGamePassAsync,Market,player.UserId,id) if ok and yes then table.insert(owned,def) end end
	if not D.Editable(player) then return end
	local d=D.Get(player) d.ExtraCapacity=0 d.VIP=false
	for _,def in owned do if def.Kind=="Capacity" then d.ExtraCapacity=math.min(2,d.ExtraCapacity+(def.Amount or 1)) elseif def.Kind=="VIP" then d.VIP=true end end
end
function S.Prompt(player,kind,id)
	if D.Demo then return false,"Robux purchases are disabled in this unpublished demo." end
	if type(id)~="number" or id%1~=0 or id<=0 then return false,"Invalid product." end
	if kind=="Product" and C.Products[id] then Market:PromptProductPurchase(player,id)
	elseif kind=="Pass" and C.Passes[id] then Market:PromptGamePassPurchase(player,id)
	else return false,"This product is not configured." end
	return true,"Review the official Roblox purchase dialog."
end
function S.Style(player)
	local d=D.Get(player) if not d.Cosmetics.Aurora then
		if d.Coins<500 then return false,"Aurora lab trim costs 500 earned coins." end
		d.Coins-=500 d.Cosmetics.Aurora=true A.Log("economy_sink",player.UserId,{kind="cosmetic",amount=500}) end
	d.Style=d.Style=="Aurora" and "Classic" or "Aurora" return true,"Lab style: "..d.Style
end
function S.Init()
	Market.PromptGamePassPurchaseFinished:Connect(function(player,_,purchased) if purchased then task.spawn(S.Refresh,player) end end)
end
return S
