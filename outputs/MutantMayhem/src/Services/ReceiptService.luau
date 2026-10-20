local Players=game:GetService("Players")
local Market=game:GetService("MarketplaceService")
local D=require(script.Parent.PlayerDataService)
local A=require(script.Parent.AnalyticsService)
local C=require(game.ReplicatedStorage.MM.Shared.GameConfig)
local R={}
function R.Process(info)
	local player=Players:GetPlayerByUserId(info.PlayerId) local product=C.Products[info.ProductId]
	if not player or not product or type(info.PurchaseId)~="string" then return Enum.ProductPurchaseDecision.NotProcessedYet end
	local ok=D.CommitReceipt(player,info.PurchaseId,function(d)
		if product.Kind=="Coins" then assert(type(product.Amount)=="number" and product.Amount>0 and product.Amount<=10000) d.Coins+=product.Amount
		elseif product.Kind=="Cosmetic" then assert(type(product.Key)=="string") d.Cosmetics[product.Key]=true
		else error("Unknown product grant") end
	end)
	if not ok then return Enum.ProductPurchaseDecision.NotProcessedYet end
	A.Log("purchase_durable",player.UserId,{product=info.ProductId,purchase=info.PurchaseId})
	return Enum.ProductPurchaseDecision.PurchaseGranted
end
function R.Init() Market.ProcessReceipt=R.Process end
return R
