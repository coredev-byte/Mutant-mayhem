local D=require(script.Parent.PlayerDataService)
local A=require(script.Parent.AnalyticsService)
local Q={}
function Q.Prepare(d,now)
	local day=math.floor((now or os.time())/86400)
	if d.Quests.Day~=day then d.Quests={Day=day,Start=D.Copy(d.Stats),Claimed={}} end
	local rotate=day%3
	return {{Key="Collected",Goal=300+rotate*100,Reward=120,Name="Collect lab income"},{Key="Mutated",Goal=2,Reward=150,Name="Make two mutations"},{Key="Found",Goal=2,Reward=100,Name="Discover two friends"}}
end
function Q.List(d)
	local rows=Q.Prepare(d) for _,r in rows do r.Progress=math.max(0,d.Stats[r.Key]-(d.Quests.Start[r.Key] or 0)) r.Claimed=d.Quests.Claimed[r.Key] or false end return rows
end
function Q.Claim(player)
	local d=D.Get(player) local amount=0
	for _,r in Q.List(d) do if not r.Claimed and r.Progress>=r.Goal then d.Quests.Claimed[r.Key]=true amount+=r.Reward end end
	local count=0 for _ in d.Discovered do count+=1 end
	for _,goal in {3,6,9,12} do local k="discovery"..goal if count>=goal and not d.Cosmetics[k] then d.Cosmetics[k]=true amount+=goal*40 end end
	if amount==0 then return false,"Keep exploring. No completed goals yet." end
	d.Coins+=amount A.Log("economy_source",player.UserId,{kind="missions",amount=amount}) return true,"Goals claimed: +"..amount.." coins!"
end
function Q.Daily(player)
	local d=D.Get(player) local day=math.floor(os.time()/86400)
	if d.Daily>=day then return false,"Today's gift is claimed. Come back tomorrow." end
	local catchup=d.Daily>0 and math.min(3,math.max(0,day-d.Daily-1))*50 or 0
	d.Daily=day d.Coins+=200+catchup
	local week=math.floor(day/7) if d.Weekly.Week~=week then d.Weekly={Week=week,Count=0} end
	d.Weekly.Count+=1 if d.Weekly.Count>=4 then d.Cosmetics.WeeklyGlow=true end
	A.Log("daily_reward",player.UserId,{amount=200+catchup}) return true,"Daily gift: +"..(200+catchup).." coins! No streak to lose."
end
return Q
