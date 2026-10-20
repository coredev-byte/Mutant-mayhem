-- EDIT-mode fault injection. Uses cloned modules and a memory-only mock; no live DataStore writes.
local temp=Instance.new("Folder") temp.Name="MM_IsolatedPersistenceTest" temp.Parent=game.ServerStorage
local mock=Instance.new("ModuleScript") mock.Name="MockStore" mock.Source=[=[
local M={Records={},FailBefore=0,FailAfter=0,Writes=0}
local function copy(t) local r={} for k,v in t do r[k]=type(v)=="table" and copy(v) or v end return r end
function M:UpdateAsync(key,callback)
 if self.FailBefore>0 then self.FailBefore-=1 error("Injected pre-write failure") end
 local result=callback(self.Records[key] and copy(self.Records[key]))
 if result then self.Records[key]=copy(result) self.Writes+=1 end
 if self.FailAfter>0 then self.FailAfter-=1 error("Injected lost acknowledgment") end
 return result and copy(result)
end
return M
]=] mock.Parent=temp
local log=Instance.new("ModuleScript") log.Name="AnalyticsService" log.Source="return {Log=function() end}" log.Parent=temp
local source=game.ServerScriptService.MM.Services.PlayerDataService.Source
source=source:gsub('if not S.Demo then store=DSS:GetDataStore%(C.DataStoreName%) end','store=require(script.Parent.MockStore) S.Demo=false')
local clone=Instance.new("ModuleScript") clone.Name="PlayerDataService" clone.Source=source clone.Parent=temp
local function test()
	local D=require(clone) local store=require(mock) local p={UserId=987654321}
	local d=D.Load(p) assert(d and d.Coins==100)
	local grant=function(profile) profile.Coins+=500 end
	store.FailBefore=3
	assert(not D.CommitReceipt(p,"before",grant)) assert(not D.Editable(p)) assert(D.Get(p).Coins==100)
	assert(D.Save(p,false)) assert(D.Get(p).Coins==600 and D.Get(p).Receipts.before)
	assert(D.CommitReceipt(p,"before",grant)) assert(D.Get(p).Coins==600)
	store.FailAfter=3
	assert(not D.CommitReceipt(p,"after",grant)) assert(D.Get(p).Coins==600)
	assert(D.Save(p,false)) assert(D.Get(p).Coins==1100 and D.Get(p).Receipts.after)
	assert(D.CommitReceipt(p,"after",grant)) assert(D.Get(p).Coins==1100)
	local other=clone:Clone() other.Name="SecondSession" other.Parent=temp local D2=require(other)
	assert(D2.Load(p)==nil,"Second session acquired an active lock")
	assert(D.Save(p,true)) D.Sessions[p]=nil
	local restored=D2.Load(p) assert(restored and restored.Coins==1100 and restored.Receipts.after)
	local migrated=D2.Migrate({Schema=1,Coins=123,Creatures={}}) assert(migrated.Coins==123 and migrated.Schema==2 and migrated.Revision==0)
	local corrupt=pcall(D2.Migrate,{Schema=999}) assert(not corrupt)
	local invalidCases=0
	for _,change in {
		function(v) v.Coins=math.huge end,function(v) v.Coins=0/0 end,function(v) v.Tier=99 end,
		function(v) v.Settings=false end,function(v) v.Stats.Collected=-1 end,
		function(v) v.Creatures={{Id="duplicate",Archetype=1,Placed=true},{Id="duplicate",Archetype=2,Placed=false}} end,
		function(v) v.Creatures={{Id="bad",Archetype=13,Placed=false}} end,
		function(v) v.Creatures={{Id="bad",Archetype=1,Placed=false,Mutation={Version=99}}} end,
		function(v) v.Creatures={{Id="bad",Archetype=1,Placed=false,Favorite="true"}} end,
		function(v) v.Creatures={{Id="bad",Archetype=1,Placed=false,Locked=1}} end,
		function(v) v.Quests={Day=1,Start=false,Claimed={}} end,
	} do local bad=D2.New() change(bad) assert(not pcall(D2.Migrate,bad),"Invalid profile accepted") invalidCases+=1 end
	-- Leave during a backend outage retains the draft; a later autosave releases it.
	D2.Get(p).Coins=1234 store.FailBefore=3
	assert(not D2.Close(p,0)) assert(D2.Sessions[p] and D2.Sessions[p].Detached and not D2.Editable(p))
	D2.Autosave(p) assert(not D2.Sessions[p]) assert(store.Records["p:"..p.UserId].Coins==1234 and not store.Records["p:"..p.UserId].Lock)
	assert(D.Load(p).Coins==1234)
	-- A receipt can reach the backend without an acknowledgment, then lose its lease.
	store.FailAfter=3 assert(not D.CommitReceipt(p,"takeover",grant))
	local key="p:"..p.UserId store.Records[key].Lock.Expires=os.time()-1
	local newer=D2.Load(p) assert(newer and newer.Coins==1734)
	local writes=store.Writes
	assert(not D.Save(p,false) and D.Sessions[p].Lost and not D.Editable(p))
	assert(store.Writes==writes and D2.Get(p).Coins==1734,"Stale writer touched new lease")
	assert(not D.Close(p,0) and not D.Sessions[p])
	-- Snapshot recovery followed by release must perform both commits in order.
	store.FailBefore=3 assert(not D2.CommitReceipt(p,"release_pending",grant))
	assert(D2.Close(p,0)) assert(not store.Records[key].Lock)
	local final=D.Load(p) assert(final.Coins==2234 and final.Receipts.release_pending)
	local mutation=require(game.ReplicatedStorage.MM.Shared.MutationConfig).Roll(1234567,19)
	final.Creatures={{Id="exact-descriptor",Archetype=12,Placed=true,Mutation=mutation,Favorite=true,Locked=true}} final.Settings.ReducedMotion=true
	assert(D.Close(p,0)) local roundtrip=D2.Load(p)
	assert(roundtrip.Creatures[1].Id=="exact-descriptor" and roundtrip.Settings.ReducedMotion)
	assert(roundtrip.Creatures[1].Favorite==true and roundtrip.Creatures[1].Locked==true,"Pet flags lost on reload")
	for field,value in mutation do assert(roundtrip.Creatures[1].Mutation[field]==value,"Mutation changed on reload") end
	-- Cold process recovery is represented by a new module/token after lease expiry.
	store.Records[key].Lock.Expires=os.time()-1
	local cold=clone:Clone() cold.Name="ColdSession" cold.Parent=temp local D3=require(cold)
	assert(D3.Load(p).Coins==2234) assert(not D2.Save(p,false))
	-- Revisions are an independent guard even if a malformed record retains our token.
	store.Records[key].Revision+=1 assert(not D3.Save(p,false) and D3.Sessions[p].Lost=="revision_conflict")
	return {PreWriteFailureRetry=true,LostAcknowledgmentRetry=true,ReceiptReplayNoDoubleGrant=true,ConcurrentLockRejected=true,ReleaseAndReload=true,Migration=true,FutureSchemaRefused=true,CorruptProfilesRefused=invalidCases,DepartureRetainedAndRecovered=true,StaleAcknowledgmentAfterTakeoverRejected=true,PendingReceiptReleased=true,ExactDescriptorRoundTrip=true,ExpiredLeaseColdRecovery=true,RevisionConflictRejected=true,FinalCoins=roundtrip.Coins,MockWrites=store.Writes}
end
local ok,result=xpcall(test,debug.traceback) temp:Destroy() if not ok then error(result) end return result
