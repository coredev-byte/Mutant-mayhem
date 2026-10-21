"""Reproducible Blender 4.0+ cloud builder. Units are Roblox studs.
Generated exports contain visual overlays only, never gameplay markers/colliders.
"""
import bpy, json, math, pathlib, hashlib, base64, os
from mathutils import Vector, Matrix
ROOT=pathlib.Path(__file__).resolve().parents[2]
OUT=ROOT/"remaster/build"
OUT.mkdir(parents=True,exist_ok=True)
recipe=json.loads((ROOT/"remaster/design/environment.json").read_text())
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
B=Matrix(((1,0,0),(0,0,-1),(0,1,0)))
def vec(v): return B@Vector(v)
mats={}
for name,rgb in recipe["palette"].items():
    mat=bpy.data.materials.new(name); mat.use_nodes=True
    bsdf=mat.node_tree.nodes.get("Principled BSDF")
    color=tuple((c/255)**2.2 for c in rgb)+(1,)
    bsdf.inputs["Base Color"].default_value=color
    bsdf.inputs["Roughness"].default_value=.34 if name in ("shell","navy","metal") else .55
    bsdf.inputs["Metallic"].default_value=.45 if name=="metal" else .05
    if name in ("cyan","violet","pink","gold"):
        bsdf.inputs["Emission Color"].default_value=color
        bsdf.inputs["Emission Strength"].default_value=1.8
    if name=="glass":
        bsdf.inputs["Transmission Weight"].default_value=.7
        bsdf.inputs["Roughness"].default_value=.16
    mat.diffuse_color=color; mats[name]=mat
cache={}
def collection(name):
    c=bpy.data.collections.new(name); bpy.context.scene.collection.children.link(c); return c
def component(item,col):
    shape=item.get("shape","box"); sz=item["size"]; bevel=item.get("bevel",.12)
    key=(shape,*sz,bevel,item["material"])
    if key not in cache:
        if shape=="box": bpy.ops.mesh.primitive_cube_add(size=1)
        elif shape=="cylinder": bpy.ops.mesh.primitive_cylinder_add(vertices=32,radius=.5,depth=1)
        else: bpy.ops.mesh.primitive_uv_sphere_add(segments=20,ring_count=12,radius=.5)
        obj=bpy.context.object
        obj.dimensions=(sz[0],sz[2],sz[1])
        bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
        if shape!="sphere":
            mod=obj.modifiers.new("Controlled bevel","BEVEL")
            mod.width=min(bevel,min(sz)*.22); mod.segments=3
            bpy.ops.object.modifier_apply(modifier=mod.name)
        for poly in obj.data.polygons: poly.use_smooth=True
        obj.data.use_auto_smooth=True
        if shape!="sphere":
            norm=obj.modifiers.new("Weighted corner normals","WEIGHTED_NORMAL")
            norm.keep_sharp=True
            bpy.ops.object.modifier_apply(modifier=norm.name)
        obj.data.materials.append(mats[item["material"]])
        cache[key]=obj.data
        bpy.data.objects.remove(obj,do_unlink=True)
    obj=bpy.data.objects.new(item["name"],cache[key]); col.objects.link(obj)
    obj.location=vec(item["pos"])
    rx,ry,rz=[math.radians(x) for x in item.get("rot",[0,0,0])]
    rotation=Matrix.Rotation(rx,3,"X")@Matrix.Rotation(ry,3,"Y")@Matrix.Rotation(rz,3,"Z")
    obj.rotation_euler=(B@rotation@B.transposed()).to_euler()
    obj["roblox_name"]=item["name"]
    obj["min_visual_tier"]=item.get("minTier",1)
    obj["collision"]="none_visual_overlay"
    return obj
def select(objects):
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects: obj.select_set(True)
    if objects: bpy.context.view_layer.objects.active=objects[0]
def triangles(objects):
    return sum(sum(len(p.vertices)-2 for p in obj.data.polygons) for obj in objects)
def export(objects,name):
    root=bpy.data.objects.new(name+"_ROOT",None)
    bpy.context.scene.collection.objects.link(root)
    root["roblox_origin"]="existing Base.CFrame; world overlay uses identity"
    for obj in objects: obj.parent=root
    select([root,*objects])
    bpy.ops.export_scene.gltf(filepath=str(OUT/(name+".glb")),export_format="GLB",use_selection=True,export_yup=True,export_extras=True)
    bpy.ops.export_scene.fbx(filepath=str(OUT/(name+".fbx")),use_selection=True,object_types={"MESH","EMPTY"},axis_forward="-Z",axis_up="Y",add_leaf_bones=False)
    bpy.context.view_layer.update()
    corners=[B.transposed()@(obj.matrix_world@Vector(corner)) for obj in objects for corner in obj.bound_box]
    low=[min(v[i] for v in corners) for i in range(3)]
    high=[max(v[i] for v in corners) for i in range(3)]
    return {"name":name,"objects":len(objects),"triangles":triangles(objects),
            "boundsRoblox":{"min":low,"max":high,"size":[high[i]-low[i] for i in range(3)]},
            "pivot":[0,0,0],"scale":"1 unit = 1 Roblox stud; verify import bounds",
            "files":[name+".glb",name+".fbx"]}
tiers=[]; manifest={"source_commit":os.environ.get("GITHUB_SHA","manual"),"blender":bpy.app.version_string,"source":"remaster/design/environment.json","assets":[]}
for tier in range(1,6):
    col=collection("LAB_Tier_"+str(tier))
    objs=[component(item,col) for item in recipe["lab"] if item["minTier"]<=tier]
    tiers.append(col)
    manifest["assets"].append(export(objs,"LAB_Tier_"+str(tier)))
world=collection("World_Visual_Overlay")
world_objs=[component(item,world) for item in recipe["world"]]
manifest["assets"].append(export(world_objs,"WORLD_Overlay"))
# Reference stage recreates preserved floor, pads and terminal for inspection only.
stage=collection("REFERENCE_existing_gameplay_do_not_import")
def ref(name,size,pos,mat="navy",shape="box"):
    return component(dict(name=name,size=size,pos=pos,material=mat,shape=shape),stage)
ref("Existing_Base",[32,1.4,28],[0,0,0])
ref("Existing_Floor",[30,.3,26],[0,.85,0],"shell")
ref("Existing_BackWall",[30,7,.8],[0,4,13],"shell")
ref("Existing_Terminal",[3,3,2],[-11,2.3,-10])
for i in range(12):
    ref("Existing_Pad_"+str(i+1),[5,.25,5],[((i%4)-1.5)*6.6,1.1,(i//4)*6.6-5],"violet","cylinder")
# Avatar clearance silhouette, labelled as reference rather than an exported character.
ref("Avatar_Clearance",[2,5,1.2],[0,3.5,-11],"metal")
scene=bpy.context.scene
scene.render.engine="CYCLES"; scene.cycles.device="CPU"; scene.cycles.samples=96
scene.cycles.use_denoising=False  # Ubuntu build lacks OpenImageDenoiser; CPU path tracing remains supported.
scene.render.resolution_x=800; scene.render.resolution_y=600; scene.render.resolution_percentage=100
scene.world.use_nodes=True
scene.world.node_tree.nodes["Background"].inputs[0].default_value=(.32,.47,.65,1)
scene.world.node_tree.nodes["Background"].inputs[1].default_value=.5
scene.view_settings.view_transform="AgX"
def light(name,loc,power,size):
    data=bpy.data.lights.new(name,"AREA"); data.energy=power; data.shape="DISK"; data.size=size
    obj=bpy.data.objects.new(name,data); scene.collection.objects.link(obj); obj.location=vec(loc)
    obj.rotation_euler=(Vector((0,0,4))-obj.location).to_track_quat("-Z","Y").to_euler()
light("Warm key",[-15,30,-15],9000,15)
light("Sky fill",[18,20,8],6000,12)
sun_data=bpy.data.lights.new("Sun","SUN"); sun_data.energy=1.5; sun_data.angle=.15
sun=bpy.data.objects.new("Sun",sun_data);scene.collection.objects.link(sun);sun.rotation_euler=(.45,-.35,-.5)
cam_data=bpy.data.cameras.new("ReviewCamera");cam=bpy.data.objects.new("ReviewCamera",cam_data)
scene.collection.objects.link(cam);scene.camera=cam
cam_data.lens=42
for col in [*tiers,world]: col.hide_render=True
for tier,col in enumerate(tiers,1):
    col.hide_render=False
    for view,location,target in [("entrance",[32,23,-39],[0,5,1]),("interior",[0,8,-19],[0,5,8])]:
        if view=="interior" and tier!=1: continue
        cam.location=vec(location); cam.rotation_euler=(vec(target)-cam.location).to_track_quat("-Z","Y").to_euler()
        scene.render.filepath=str(OUT/("LAB_Tier_"+str(tier)+"_"+view+".png"))
        bpy.ops.render.render(write_still=True)
    col.hide_render=True
tiers[0].hide_render=False
for col in tiers[1:]+[world]: col.hide_viewport=True
cam.location=vec([32,23,-39]);cam.rotation_euler=(vec([0,5,1])-cam.location).to_track_quat("-Z","Y").to_euler()
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/"MutantMayhem_Environment.blend"))
manifest["files"]=[]
for path in sorted(OUT.iterdir()):
    if path.is_file() and path.name!="manifest.json":
        manifest["files"].append({"name":path.name,"bytes":path.stat().st_size,"sha256":hashlib.sha256(path.read_bytes()).hexdigest()})
(OUT/"manifest.json").write_text(json.dumps(manifest,indent=2))
print("REMASTER_MANIFEST:"+json.dumps(manifest))
# Emit a small real rendered preview for MCP inspection without local downloads.
preview=bpy.data.images.load(str(OUT/"LAB_Tier_1_entrance.png"),check_existing=False)
preview.scale(640,480);preview.filepath_raw=str(OUT/"review-preview.png");preview.file_format="PNG";preview.save()
print("REMASTER_PREVIEW_BASE64:"+base64.b64encode((OUT/"review-preview.png").read_bytes()).decode())
