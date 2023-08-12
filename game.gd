extends Node2D

var score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var fuckyou = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func handle_bullet_collision(bullet_node, hit_node):
	var bullet_poly = bullet_node.polygon
	var hit_node_poly = hit_node.polygon
	for p in range(bullet_poly.size()):
		bullet_poly[p] = bullet_poly[p] + bullet_node.position
	
	for p in range(hit_node_poly.size()):
		hit_node_poly[p] = hit_node_poly[p] + hit_node.position
	
	var clipped_points = Geometry2D.clip_polygons(hit_node_poly, bullet_poly)
	if clipped_points.size() <= 0 or clipped_points.size() == 2 and Geometry2D.is_polygon_clockwise(clipped_points[1]):
		return
	for clip_index in range(clipped_points.size()):
		for point in range(clipped_points[clip_index].size()):
			clipped_points[clip_index][point] = clipped_points[clip_index][point] - hit_node.position
		
		
	var biggest_index = 0
	var biggest_area = 0
	for big_gon in range(clipped_points.size()):
		var current_area = get_area_of_poly(clipped_points[big_gon])
		if  current_area > biggest_area:
			biggest_index = big_gon
			biggest_area = current_area
	hit_node.update_polygon.call_deferred(clipped_points[biggest_index])
	hit_node.recalibrate.call_deferred()
	clipped_points.remove_at(biggest_index)
	bullet_node.queue_free.call_deferred()


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

func score_increase(score_value):
	score += score_value
	$Control/Label.text = "score: " + str(score)
