local visual=require("../../outputs/MutantMayhem/src/Services/VisualTier")
for backend,expected in {1,2,2,3,4,4,5} do assert(visual(backend-1)==expected) end
assert(visual(-9)==1) assert(visual(100)==5) assert(visual(2.9)==2)
assert(visual("3")==1) assert(visual(0/0)==1)
print("Visual tier tests passed: existing backend 0..6 preserved")
