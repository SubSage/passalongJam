extends Polygon2D

signal bullet_contact
var speed = 600.0
var direction = Vector2(1, 0)
var turn_speed_degrees = deg_to_rad(15.0)

@onready var GAME: Node = get_tree().root.find_child("GAME", true, false)

func _ready():
	turn_speed_degrees = deg_to_rad(randf_range(-65.0, 45.0))
	polygon = array_rotated(polygon, turn_speed_degrees)
	
	$Area2D/CollisionPolygon2D.polygon = polygon
	bullet_contact.connect(GAME.handle_bullet_collision)

func _process(delta):
	position += direction * speed * delta
	polygon = array_rotated(polygon, turn_speed_degrees * delta)
	


func _on_area_2d_area_entered(area):
	position += direction * speed * get_process_delta_time() * 2
	emit_signal("bullet_contact", self, area.get_parent())


func array_rotated(arr, turn_rad):
	var new_arr = []
	new_arr.resize(arr.size())
	for count in range(arr.size()):
		new_arr[count] = arr[count].rotated(turn_rad)
	return new_arr


func _on_timer_timeout():
	$Area2D/CollisionPolygon2D.polygon = polygon
