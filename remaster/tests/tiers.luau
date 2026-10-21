local visual=require("../../outputs/MutantMayhem/src/Services/VisualTier")
for backend,expected in {1,2,2,3,4,4,5} do assert(visual(backend-1)==expected) end
assert(visual(-9)==1) assert(visual(100)==5) assert(visual(2.9)==2)
assert(visual("3")==1) assert(visual(0/0)==1)
print("Visual tier tests passed: existing backend 0..6 preserved")

local recipe=require("../../outputs/MutantMayhem/src/Services/RemasterRecipe")
local names={}
for _,part in recipe.lab do
 assert(not names[part.name],part.name) names[part.name]=true
 assert(part.minTier>=1 and part.minTier<=5)
end
for backend=0,6 do assert(visual(backend)==recipe.visualTierByBackend[backend+1]) end
assert(#recipe.lab==97 and #recipe.world==299)
print("Runtime recipe loaded and tier mapping matches exported design")
