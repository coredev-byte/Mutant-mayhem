local P={Assigned={}}
function P.Assign(player)
	for _,plot in workspace.MM_World.Plots:GetChildren() do
		if plot:GetAttribute("OwnerId")==0 then plot:SetAttribute("OwnerId",player.UserId) plot:SetAttribute("OwnerName",player.DisplayName) P.Assigned[player]=plot
			local sign=plot:FindFirstChild("Sign") if sign then sign.BillboardGui.TextLabel.Text=player.DisplayName.."'S LAB" end
			return plot
		end
	end
end
function P.Position(player) local p=P.Assigned[player] return p and p.Base.Position end
function P.Spawn(player)
	local plot=P.Assigned[player] if plot and player.Character then player.Character:PivotTo(plot.Base.CFrame*CFrame.new(0,5,-18)) end
end
function P.Release(player)
	local p=P.Assigned[player] if p then p:SetAttribute("OwnerId",0) p:SetAttribute("OwnerName",nil)
		local pets=p:FindFirstChild("Creatures") if pets then pets:Destroy() end
		local badge=p:FindFirstChild("WeeklyBadge") if badge then badge:Destroy() end
		p.Canopy.Color=Color3.fromRGB(241,143,122)
		p.Sign.BillboardGui.TextLabel.Text="LAB "..string.format("%02d",p:GetAttribute("PlotId")) end
	P.Assigned[player]=nil
end
return P
