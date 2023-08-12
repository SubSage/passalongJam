extends Polygon2D

@onready var GAME: Node = get_tree().root.find_child("GAME", true, false)
@onready var PLAYER: Node = get_tree().root.find_child("PLAYER", true, false)
var speed = 100.0
var area = 0.0
var speed_area_threshold = 60000.0
var speed_area_max_bonus = 3.0
var last_speed = 0.0
var centroid = Vector2.ZERO
var area_minimum_kill_threshold = 3000.0
signal score

func _ready():
	recalibrate()
	score.connect(GAME.score_increase)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Label.text = str(area)
	$Label.position = centroid
	var direction = position.direction_to(PLAYER.position)
	var gross_displacement = direction * speed * delta * lerp(1.0, speed_area_max_bonus, min(area/speed_area_threshold, 1.0))
	var limited_displacement = gross_displacement.limit_length(position.distance_to(PLAYER.position))
	last_speed = limited_displacement.length()
	position += limited_displacement
#	if centroid.length() > 100:
#		for p in polygon.size():
#			polygon[p] = lerp(polygon[p], polygon[p] - centroid, delta)
#		recalibrate()
		


func update_polygon(poly):
	var old_area = get_area_of_poly(polygon)
	var new_area = get_area_of_poly(poly)
	if new_area < area_minimum_kill_threshold:
		emit_signal("score", abs(old_area))
		queue_free()
		return
	else:
		var score_value = old_area - new_area
		emit_signal("score", abs(score_value))
		polygon = poly

func recalibrate():
	var i = 0
	var points = polygon
	for j in range(1, points.size()):
		if points[j - 1] != points[j]:
			points[i] = points[j]
			i += 1
	points.resize(i)
	$Area2D/CollisionPolygon2D.polygon = points
	area = get_area_of_poly(polygon)
	centroid = get_centroid_of_poly(polygon)
#	for p in polygon.size():
#		polygon[p] = polygon[p] - centroid


#https://www.mathopenref.com/coordpolygonarea.html
#https://en.wikipedia.org/wiki/Shoelace_formula
func get_area_of_poly(poly):
	if not poly or poly.size() < 3:
		return -1
	var area = 0
	poly.append(poly[0])
	for c in range(poly.size() - 1):
		area += poly[c].x * poly[c+1].y
		area -= poly[c].y * poly[c+1].x
	area = abs(area/2.0)
	return area

#https://en.wikipedia.org/wiki/Centroid
func get_centroid_of_poly(poly):
	if not poly or poly.size() < 3:
		return -1
	var area = 0
	poly.append(poly[0])
	var x = 0
	var y = 0
	var signed_area = 0
	for c in range(poly.size() - 1):
		area = poly[c].x * poly[c+1].y - poly[c].y * poly[c+1].x
		signed_area += area
		x += (poly[c].x + poly[c+1].x) * area
		y += (poly[c].y + poly[c+1].y) * area
	area = abs(area/2.0)
	signed_area = abs(signed_area/2.0)
	x = x / (6.0 * signed_area)
	y = y / (6.0 * signed_area)
	return Vector2(x,y)

func array_rotated(arr, turn_rad):
	var new_arr = []
	new_arr.resize(arr.size())
	for count in range(arr.size()):
		new_arr[count] = arr[count].rotated(turn_rad)
	return new_arr


func _on_area_2d_area_entered(area_node):
	if is_queued_for_deletion():
		return
		
	var other_poly = area_node.get_parent().polygon
	var self_poly = polygon
	for p in range(self_poly.size()):
		self_poly[p] = self_poly[p] + position
	
	for p in range(other_poly.size()):
		other_poly[p] = other_poly[p] + area_node.get_parent().position
	
	var merged_points = Geometry2D.merge_polygons(self_poly, other_poly)
	if merged_points.size()<=0:
		return
		
	for merged_index in range(merged_points.size()):
		for point in range(merged_points[merged_index].size()):
			merged_points[merged_index][point] = merged_points[merged_index][point] - position
	polygon = merged_points[0]
	recalibrate.call_deferred()
	area_node.get_parent().queue_free()
