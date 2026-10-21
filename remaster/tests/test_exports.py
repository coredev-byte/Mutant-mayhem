import json,pathlib,struct,unittest,hashlib,math
OUT=pathlib.Path(__file__).resolve().parents[1]/"build"
M=json.loads((OUT/"manifest.json").read_text())
class Exports(unittest.TestCase):
 def test_source_and_renders(self):
  self.assertGreater((OUT/"MutantMayhem_Environment.blend").stat().st_size,10000)
  for i in range(1,6):
   self.assertTrue((OUT/f"LAB_Tier_{i}_entrance.png").read_bytes().startswith(b"\x89PNG"))
 def test_hashes(self):
  for f in M["files"]:
   self.assertEqual(hashlib.sha256((OUT/f["name"]).read_bytes()).hexdigest(),f["sha256"])
 def test_exports(self):
  self.assertEqual(len(M["assets"]),6)
  for asset in M["assets"]:
   self.assertTrue(all(v>0 and math.isfinite(v) for v in asset["boundsRoblox"]["size"]))
   data=(OUT/(asset["name"]+".glb")).read_bytes()
   magic,version,length=struct.unpack_from("<4sII",data)
   self.assertEqual((magic,version,length),(b"glTF",2,len(data)))
   size,kind=struct.unpack_from("<I4s",data,12);self.assertEqual(kind,b"JSON")
   gltf=json.loads(data[20:20+size])
   self.assertGreater(len(gltf["meshes"]),0)
   self.assertTrue(all(math.isfinite(v) for a in gltf["accessors"] for k in ("min","max") for v in a.get(k,[])))
   self.assertLess(asset["triangles"],100000 if asset["name"]=="WORLD_Overlay" else 30000)
   self.assertGreater((OUT/(asset["name"]+".fbx")).stat().st_size,1000)
  print("MEASURED_EXPORT_COUNTS",[(a["name"],a["objects"],a["triangles"]) for a in M["assets"]])
if __name__=="__main__":unittest.main()
