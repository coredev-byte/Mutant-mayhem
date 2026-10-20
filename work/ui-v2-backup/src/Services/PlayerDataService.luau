local DSS=game:GetService("DataStoreService")
local Run=game:GetService("RunService")
local Http=game:GetService("HttpService")
local C=require(game.ReplicatedStorage.MM.Shared.GameConfig)
local A=require(script.Parent.AnalyticsService)
local S={Sessions={},Demo=Run:IsStudio() and C.StudioDemo and game.GameId==0}
local store
if not S.Demo then store=DSS:GetDataStore(C.DataStoreName) end
local token=game.JobId..":"..Http:GenerateGUID(false)
local function copy(t) local n={} for k,v in t do n[k]=type(v)=="table" and copy(v) or v end return n end
S.Copy=copy
function S.New()
	return {Schema=C.Schema,Revision=0,Research=0,Coins=C.StarterCoins,Stored=0,Tier=0,Prestige=0,Creatures={},Discovered={},
		Rolls=0,Misses=0,Tutorial=1,Daily=0,Visits=0,LastVisit=0,Receipts={},Cosmetics={},
		Stats={Collected=0,Mutated=0,Found=0,Raid=0},Quests={},Settings={Peaceful=true,ReducedMotion=false,LowGraphics=false},Weekly={}}
end
function S.Migrate(old)
	if old==nil then return S.New() end
	assert(type(old)=="table" and type(old.Schema)=="number" and old.Schema>=1 and old.Schema%1==0 and old.Schema<=C.Schema,"Unsupported or corrupt data; refusing overwrite")
	old=copy(old) -- Never mutate the value supplied by UpdateAsync while validating it.
	local defaults=S.New()
	for k,v in defaults do if old[k]==nil then old[k]=copy({v})[1] end end
	for _,key in {"Settings","Stats","Creatures","Discovered","Receipts","Cosmetics","Quests","Weekly"} do assert(type(old[key])=="table","Corrupt profile: "..key) end
	for k,v in defaults.Settings do if old.Settings[k]==nil then old.Settings[k]=v end end
	for k,v in defaults.Stats do if old.Stats[k]==nil then old.Stats[k]=v end end
	local function number(value,lo,hi,integer)
		assert(type(value)=="number" and value==value and value>=lo and value<=hi and (not integer or value%1==0),"Corrupt numeric profile field")
	end
	for _,key in {"Coins","Stored","Revision","Research","Rolls","Daily","Visits","LastVisit"} do number(old[key],0,1e15,key~="Stored") end
	number(old.Tier,0,6,true) number(old.Prestige,0,10,true) number(old.Tutorial,1,5,true) number(old.Misses,0,19,true)
	for key in defaults.Settings do assert(type(old.Settings[key])=="boolean","Corrupt settings") end
	for key in defaults.Stats do number(old.Stats[key],0,1e15,true) end
	local seen,count={},0
	for index,creature in old.Creatures do
		count+=1 number(index,1,C.InventoryLimit,true)
		assert(type(creature)=="table" and type(creature.Id)=="string" and #creature.Id>0 and #creature.Id<=100 and not seen[creature.Id],"Invalid or duplicated creature ID")
		seen[creature.Id]=true number(creature.Archetype,1,12,true) assert(type(creature.Placed)=="boolean","Invalid placement")
		local m=creature.Mutation
		if m then
			assert(type(m)=="table" and m.Version==1,"Unsupported mutation descriptor")
			number(m.Seed,1,2147483646,true) number(m.Rarity,1,6,true) number(m.Palette,1,6,true)
			number(m.Horns,0,2,true) number(m.Eyes,2,3,true) number(m.Wings,0,1,true) number(m.Tail,0,1,true)
			number(m.Scale,.9,1.15,false) number(m.Material,1,3,true)
			assert(type(m.Sparkles)=="boolean" and type(m.Pity)=="boolean","Invalid mutation flags")
		end
	end
	assert(count==#old.Creatures,"Sparse creature inventory")
	for key,value in old.Receipts do assert(type(key)=="string" and #key<=200,"Invalid receipt key") number(value,0,1e15,true) end
	for key,value in old.Cosmetics do assert(type(key)=="string" and type(value)=="boolean","Invalid cosmetic") end
	for key,value in old.Discovered do assert(type(key)=="string" and tonumber(key) and value==true,"Invalid discovery") number(tonumber(key),1,12,true) end
	if old.ExtraCapacity~=nil then number(old.ExtraCapacity,0,2,true) end
	if old.VIP~=nil then assert(type(old.VIP)=="boolean","Invalid VIP entitlement") end
	if old.Style~=nil then assert(old.Style=="Classic" or old.Style=="Aurora","Invalid lab style") end
	if old.Weekly.Count~=nil then number(old.Weekly.Count,0,7,true) number(old.Weekly.Week,0,1e15,true) end
	if old.Quests.Day~=nil then
		number(old.Quests.Day,0,1e15,true) assert(type(old.Quests.Start)=="table" and type(old.Quests.Claimed)=="table","Invalid quest state")
		for key in defaults.Stats do number(old.Quests.Start[key],0,1e15,true) end
		for _,value in old.Quests.Claimed do assert(type(value)=="boolean","Invalid quest claim") end
	end
	old.Schema=C.Schema return old
end
local function attempt(fn)
	local err for i=1,3 do local ok,res=pcall(fn) if ok then return true,res end err=res if i<3 then task.wait(i*1.5) end end
	return false,tostring(err)
end
function S.Load(player)
	if S.Sessions[player] then return nil,"A profile session is already active." end
	local data
	if S.Demo then data=S.New() else
		local ok,res=attempt(function() return store:UpdateAsync("p:"..player.UserId,function(old)
			local now=os.time()
			if old and old.Lock and old.Lock.Token~=token and old.Lock.Expires>now then return nil end
			local d=S.Migrate(old) d.Lock={Token=token,Expires=now+C.LeaseSeconds} return d
		end) end)
		if not ok or not res then A.Log("load_failed",player.UserId,{error=tostring(res)}) return nil,"Data is busy or unavailable. Please reconnect shortly." end
		data=res
	end
	data.Visits+=1 data.LastVisit=os.time()
	S.Sessions[player]={Data=data,Busy=false,LastSave=os.time(),Joined=os.clock(),Closing=false}
	A.Log("session_start",player.UserId,{visit=data.Visits,mode=S.Demo and "demo" or "durable"})
	return data
end
function S.Get(player) local s=S.Sessions[player] return s and s.Data end
function S.Editable(player)
	local s=S.Sessions[player]
	return s and not s.Busy and not s.Pending and not s.Closing and not s.Lost and (S.Demo or os.time()-s.LastSave<C.LeaseSeconds-40)
end
function S.Write(player,draft,release)
	local s=S.Sessions[player] if not s or s.Lost then return false end
	if S.Demo then s.LastSave=os.time() return true end
	-- An ambiguous network result must be retried with the SAME commit and snapshot.
	-- Gameplay freezes while pending so a later autosave cannot erase a durable receipt.
	local pending=s.Pending or {Draft=copy(draft),Release=release,CommitId=Http:GenerateGUID(false)}
	s.Pending=pending
	local rejection
	local ok,res=attempt(function() return store:UpdateAsync("p:"..player.UserId,function(old)
		rejection=nil
		if old and old.CommitId==pending.CommitId then
			if (pending.Release and not old.Lock) or (old.Lock and old.Lock.Token==token) then return old end
			rejection="lease_taken" return nil -- Never resume stale gameplay after takeover.
		end
		if not old or not old.Lock or old.Lock.Token~=token then rejection="lease_taken" return nil end
		if (old.Revision or 0)~=(pending.Draft.Revision or 0) then rejection="revision_conflict" return nil end
		local nextData=copy(pending.Draft)
		nextData.Revision=(old.Revision or 0)+1 nextData.CommitId=pending.CommitId
		nextData.Lock=not pending.Release and {Token=token,Expires=os.time()+C.LeaseSeconds} or nil
		return nextData
	end) end)
	if ok and res then
		s.Data=res s.Pending=nil s.LastSave=os.time()
		if release and not pending.Release then return S.Write(player,s.Data,true) end
		return true
	end
	if ok and rejection then s.Lost=rejection A.Log("session_lost",player.UserId,{reason=rejection}) end
	A.Log("save_failed",player.UserId,{error=tostring(res),release=release or false}) return false
end
function S.Save(player,release)
	local s=S.Sessions[player] if not s then return false end
	if release then s.Closing=true end
	if s.Busy then return false end s.Busy=true
	local ok=S.Write(player,s.Data,release) s.Busy=false return ok
end
-- Failed departure saves remain attached to the server and are retried by autosave.
-- A lost lease is terminal: never overwrite the new server's authoritative record.
function S.Close(player,seconds)
	local deadline=os.clock()+(seconds or 20)
	local s=S.Sessions[player] if not s then return true end
	s.Closing=true s.Detached=true
	repeat
		if S.Save(player,true) then S.Sessions[player]=nil return true end
		if s.Lost then A.Log("departure_conflict",player.UserId,{reason=s.Lost}) S.Sessions[player]=nil return false end
		if S.Sessions[player]~=s then return true end
		if os.clock()>=deadline then break end task.wait(.25)
	until false
	A.Log("departure_pending",player.UserId,{retry=true}) return false
end
function S.Autosave(player)
	local s=S.Sessions[player] if not s then return end
	if s.Detached then S.Close(player,0) else S.Save(player,false) end
end
function S.CommitReceipt(player,purchaseId,grant)
	local s=S.Sessions[player]
	if S.Demo or not S.Editable(player) then return false end
	if s.Data.Receipts[purchaseId] then return true end
	s.Busy=true local draft=copy(s.Data)
	local applied,err=pcall(grant,draft)
	if not applied then s.Busy=false A.Log("receipt_grant_error",player.UserId,{error=tostring(err)}) return false end
	draft.Receipts[purchaseId]=os.time()
	local ok=S.Write(player,draft,false)
	s.Busy=false return ok
end
return S
