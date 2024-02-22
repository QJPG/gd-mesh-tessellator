class_name MeshTessellatorClass extends Object

static func GetVector3ArrayFrom(array : Array, offset = Vector3.ZERO) -> PackedVector3Array:
	var values = []
	
	for i in range(0, array.size(), 3):
		var v = Vector3(0, 0, 0) - offset
		v.x = array[i]
		v.y = array[i + 1]
		v.z = array[i + 2]
		
		values.append(v)
	
	return PackedVector3Array(values)

static func GetVector2ArrayFrom(array : Array, offset = Vector2.ZERO) -> PackedVector2Array:
	var values = []
	
	for i in range(0, array.size(), 2):
		var v = Vector2(0, 0) - offset
		v.x = array[i]
		v.y = array[i + 1]
		
		values.append(v)
	
	return PackedVector2Array(values)

static func GetFromCustom(custom_array : Array, index : int, key_name : String, default = null):
	if not index < custom_array.size():
		return default
	
	if not custom_array[index].has(key_name):
		return default
	
	return custom_array[index][key_name]

static func BuildFromModel(filename : String, position : Vector3, custom := []) -> ArrayMesh:
	var mesh : ArrayMesh = ArrayMesh.new()
	
	var fl = FileAccess.open(filename, FileAccess.READ)
	var js = JSON.new()
	var res = js.parse_string(fl.get_as_text())
	
	if res is Dictionary:
		mesh.resource_name = res.name
		var mesh_offset = Vector3(res.offset[0], res.offset[1], res.offset[2])
		
		for i in range(res.surfaces.size()):
			var surface : Array
			surface.resize(ArrayMesh.ARRAY_MAX)
			surface[ArrayMesh.ARRAY_VERTEX] = GetVector3ArrayFrom(res.surfaces[i].vertices, position - mesh_offset)
			surface[ArrayMesh.ARRAY_NORMAL] = GetVector3ArrayFrom(res.surfaces[i].normals)
			surface[ArrayMesh.ARRAY_INDEX] = PackedInt32Array(res.surfaces[i].indices)
			surface[ArrayMesh.ARRAY_TEX_UV] = GetVector2ArrayFrom(res.surfaces[i].uvs)
			
			var mat = StandardMaterial3D.new()
			mat.albedo_texture = load(GetFromCustom(custom, i, "texture", res.materials[res.surfaces[i].material].texture))
			mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
			
			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface)
			mesh.surface_set_material(i, mat)
			mesh.surface_set_name(i, res.surfaces[i].name)
			
			print(res.surfaces[i].name)
	
	return mesh
