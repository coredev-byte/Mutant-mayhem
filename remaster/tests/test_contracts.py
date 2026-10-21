import json, pathlib, math, unittest
ROOT=pathlib.Path(__file__).resolve().parents[2]
R=json.loads((ROOT/"remaster/design/environment.json").read_text())
class Contracts(unittest.TestCase):
 def test_unique_names_and_valid_geometry(self):
  for group in ("lab","world"):
   self.assertEqual(len(R[group]),len({x["name"] for x in R[group]}))
   for p in R[group]:
    self.assertIn(p["material"],R["palette"])
    self.assertTrue(all(math.isfinite(v) and v>0 for v in p["size"]))
    self.assertTrue(all(math.isfinite(v) for v in p["pos"]+p["rot"]))
 def test_progression_adds_architecture(self):
  counts=[sum(p["minTier"]<=tier for p in R["lab"]) for tier in range(1,6)]
  self.assertEqual(counts,sorted(set(counts)))
  self.assertEqual(R["visualTierByBackend"],[1,2,2,3,4,4,5])
 def test_pad_and_entrance_clearances(self):
  # Conservative axis bounds for low geometry; all rotated lab components are above avatar height.
  protected=[([((i%4)-1.5)*6.6,4.1,(i//4)*6.6-5],[5,5.8,5]) for i in range(12)]
  protected.append(([0,4,-15],[8,6,8]))
  for p in R["lab"]:
   if p["pos"][1]-p["size"][1]/2>7.1: continue
   self.assertEqual(p["rot"],[0,0,0])
   for center,size in protected:
    overlap=all(abs(p["pos"][k]-center[k])<(p["size"][k]+size[k])/2-.01 for k in range(3))
    self.assertFalse(overlap,p["name"]+" intersects a reserved pet/entrance volume")
 def test_no_runtime_gameplay_mutations(self):
  src=(ROOT/"outputs/MutantMayhem/src/Services/WorldRemaster.luau").read_text()
  self.assertIn("p.CanCollide=false p.CanTouch=false p.CanQuery=false",src)
  self.assertNotIn("FireServer",src);self.assertNotIn("DataStore",src)
  self.assertNotIn("MapBuilder",src)
  self.assertIn('p.Transparency=original',src)
 def test_boundaries(self):
  for p in R["lab"]:
   self.assertLess(abs(p["pos"][0])+p["size"][0]/2,22)
   self.assertLess(abs(p["pos"][2])+p["size"][2]/2,17)
  self.assertLess(len(R["lab"])*12+len(R["world"]),1500)
if __name__=="__main__":unittest.main()
