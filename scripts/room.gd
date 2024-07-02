@tool
class_name Room extends Node3D

const WALL_THICKNESS = 0.25

enum WallType {WALL, DOOR}

@onready var ceiling = $Ceiling
@onready var central_light = $CentralLight
@onready var north_wall = $NorthWall # -z
@onready var south_wall = $SouthWall # +z
@onready var east_wall = $EastWall # +x
@onready var west_wall = $WestWall # -x

@export var width: int = 10:
	set(value):
		width = value
		east_wall.position.x = (float(value) + WALL_THICKNESS) / 2
		west_wall.position.x = -(float(value) + WALL_THICKNESS) / 2
		
@export var height: int = 5:
	set(value):
		height = value
		ceiling.position.y = float(value) + WALL_THICKNESS / 2
		central_light.position.y = float(value) * 0.8
		north_wall.position.y = (float(value) + WALL_THICKNESS) / 2
		south_wall.position.y = (float(value) + WALL_THICKNESS) / 2
		east_wall.position.y = (float(value) + WALL_THICKNESS) / 2
		west_wall.position.y = (float(value) + WALL_THICKNESS) / 2
		
@export var length: int = 10:
	set(value):
		length = value
		north_wall.position.z = -(float(value) + WALL_THICKNESS) / 2
		south_wall.position.z = (float(value) + WALL_THICKNESS) / 2
		
@export var regenerate: bool = false:
	set(value):
		generate_walls()
		regenerate = false
		
@export_group("Sides")
@export var north: WallType = WallType.WALL
@export var east: WallType = WallType.WALL
@export var south: WallType = WallType.WALL
@export var west: WallType = WallType.WALL


func generate_walls():
	for child in north_wall.get_children():
		child.queue_free()
	generate_wall(north_wall, north, width)
	for child in east_wall.get_children():
		child.queue_free()
	generate_wall(east_wall, east, length)
	for child in south_wall.get_children():
		child.queue_free()
	generate_wall(south_wall, south, width)
	for child in west_wall.get_children():
		child.queue_free()
	generate_wall(west_wall, west, length)


func generate_wall(parent_node, wall_type, wall_width):
	match wall_type:
		WallType.WALL:
			generate_solid_wall(parent_node, wall_width)
		WallType.DOOR:
			generate_door(parent_node, wall_width)

func set_subtree_owner(node: Node):
	node.owner = self
	for child in node.get_children():
		set_subtree_owner(child)

func build_static_box_with_collider(size: Vector3 = Vector3(1,1,1), pos: Vector3 = Vector3(0,0,0)) -> StaticBody3D:
	var static_box = StaticBody3D.new()
	
	# Create collider
	var collider = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = size
	collider.shape = box
	collider.name = "collider"
	static_box.add_child(collider)
	
	# Create visuals
	var mesh_instance = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.name = "mesh"
	static_box.add_child(mesh_instance)
	
	static_box.position = pos
	
	return static_box


func generate_solid_wall(parent_node, wall_width):
	var wall_size = Vector3(wall_width + WALL_THICKNESS, height + WALL_THICKNESS, WALL_THICKNESS)
	var wall = build_static_box_with_collider(wall_size)
	wall.name = "wall"
	parent_node.add_child(wall)
	set_subtree_owner(wall)


func generate_door(parent_node, wall_width):
	var wall_size = Vector3(wall_width + WALL_THICKNESS, height + WALL_THICKNESS, WALL_THICKNESS)
	var door_width = 1.25
	var door_height = 3.0
	var box_side_size = Vector3((wall_width - door_width + WALL_THICKNESS) / 2, height + WALL_THICKNESS, WALL_THICKNESS)
	var box_top_size = Vector3(door_width, height - door_height + WALL_THICKNESS, WALL_THICKNESS)
	var box_left_pos = Vector3(-((door_width + WALL_THICKNESS) / 2 + wall_width / 4), 0, 0)
	var box_right_pos = Vector3((door_width + WALL_THICKNESS) / 2 + wall_width / 4, 0, 0)
	var box_top_pos = Vector3(0, door_height / 2, 0)
	
	var wall_left = build_static_box_with_collider(box_side_size, box_left_pos)
	var wall_right = build_static_box_with_collider(box_side_size, box_right_pos)
	var wall_top = build_static_box_with_collider(box_top_size, box_top_pos)
	
	wall_left.name = "wall_left"
	wall_right.name = "wall_right"
	wall_top.name = "wall_top"
	
	# Add it to the tree
	parent_node.add_child(wall_left)
	parent_node.add_child(wall_right)
	parent_node.add_child(wall_top)
	set_subtree_owner(wall_left)
	set_subtree_owner(wall_right)
	set_subtree_owner(wall_top)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
