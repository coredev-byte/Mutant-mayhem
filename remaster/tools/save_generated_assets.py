"""Save verified cloud outputs to the development branch, never main.
Uses only the runner's scoped GitHub token. No credentials are logged or persisted.
A concurrent branch update aborts the save instead of overwriting newer work.
"""
import os, json, pathlib, base64, urllib.request
REPO="coredev-byte/Mutant-mayhem"
BRANCH="feature/world-remaster"
assert os.environ["GITHUB_REPOSITORY"]==REPO
assert os.environ["GITHUB_REF"]=="refs/heads/"+BRANCH
SOURCE=os.environ["GITHUB_SHA"]
ROOT=pathlib.Path(__file__).resolve().parents[2]
OUT=ROOT/"remaster/build"
def api(path,method="GET",body=None):
 data=None if body is None else json.dumps(body).encode()
 req=urllib.request.Request("https://api.github.com/repos/"+REPO+"/"+path,data=data,method=method,
   headers={"Authorization":"Bearer "+os.environ["GH_TOKEN"],"Content-Type":"application/json","Accept":"application/vnd.github+json","X-GitHub-Api-Version":"2022-11-28"})
 with urllib.request.urlopen(req,timeout=90) as response: return json.load(response)
head=api("git/ref/heads/"+BRANCH)["object"]["sha"]
if head!=SOURCE: raise RuntimeError("Development branch advanced; run the build on the new head before saving assets")
base=api("git/commits/"+SOURCE)["tree"]["sha"]
elements=[]
for p in sorted(OUT.iterdir()):
 if not p.is_file() or p.suffix not in (".blend",".glb",".fbx",".png",".json"): continue
 blob=api("git/blobs","POST",{"encoding":"base64","content":base64.b64encode(p.read_bytes()).decode()})
 elements.append({"path":"remaster/generated/"+p.name,"mode":"100644","type":"blob","sha":blob["sha"]})
assert any(e["path"].endswith(".blend") for e in elements)
tree=api("git/trees","POST",{"base_tree":base,"tree":elements})["sha"]
commit=api("git/commits","POST",{"message":"Save verified cloud Blender assets from "+SOURCE[:12]+" [skip ci]","tree":tree,"parents":[SOURCE]})["sha"]
# Non-forced update rejects a concurrent diverging child commit.
api("git/refs/heads/"+BRANCH,"PATCH",{"sha":commit,"force":False})
print("SAVED_GENERATED_ASSETS",len(elements),"commit",commit)
