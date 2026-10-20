local Http=game:GetService("HttpService")
local A={Recent={}}
function A.Log(event,userId,fields)
	local row={event=event,userId=userId or 0,time=os.time(),fields=fields or {}}
	table.insert(A.Recent,row) if #A.Recent>200 then table.remove(A.Recent,1) end
	print("[MM] "..Http:JSONEncode(row))
end
return A
