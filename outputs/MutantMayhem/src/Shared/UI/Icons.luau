-- Semantic registry. Image remains empty until a licensed individual asset is uploaded.
-- Fallback glyphs are intentional; the reference sheet is never cropped into production UI.
local groups={
 Navigation={Home="⌂",Pets="✦",Mutation="◈",Inventory="▦",Laboratory="⚗",Achievements="★",Shop="◆",Daily="▣",Map="◎",Friends="♟",Settings="⚙"},
 Resources={Coins="●",Gems="◆",Tickets="▰",Energy="ϟ",Mutagen="◈",Essence="◇",VIP="♛",Luck="✤"},
 Actions={Play="▶",Upgrade="↑",Mutate="◈",Collect="+",Steal="◐",Protect="⬡",Lock="▣",Remove="−",Equip="✓",Inspect="⌕",Close="×"},
 Pets={Pet="✦",Rarity="✧",Favorite="♥",Evolve="⇈",Traits="◈",Sleep="Z",Happy="☺",Angry="!",Feed="◡",Skin="✿"},
 Lab={Expand="⊞",Decorate="✿",Machine="⚗",Security="⬡",Fence="▥",Portal="◎",Lighting="☼",Furniture="▤",Panels="▦"},
 Events={Gift="▣",Meteor="☄",Egg="◉",Boss="♜",Countdown="◷"},
 Extras={Clan="♟",Ranking="▥",Missions="★",Info="i",Trade="⇄",Boosts="ϟ"},
}
local I={Groups=groups}
for group,items in groups do for name,glyph in items do I[name]={Image="",Fallback=glyph,Group=group} end end
return I
