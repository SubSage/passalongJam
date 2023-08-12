extends Node2D

var shoot_cooldown = 0.0
@export var shoot_timer = 0.5
var speed = 600.0
@onready var BULLET_CLASS = preload("res://bullet.tscn")
@onready var BULLETS: Node = get_tree().root.find_child("BULLETS", true, false)
func _ready():
	pass # Replace with function body.


func _process(delta):
	shoot_cooldown = max(shoot_cooldown - delta, -1.0)
	
	if Input.is_action_pressed("move_left"):
		position += Vector2(-1.0, 0.0) * speed * delta
	if Input.is_action_pressed("move_right"):
		position += Vector2(1.0, 0.0) * speed * delta
	if Input.is_action_pressed("move_up"):
		position += Vector2(0.0, -1.0) * speed * delta
	if Input.is_action_pressed("move_down"):
		position += Vector2(0.0, 1.0) * speed * delta
	var shoot_direction = Input.get_vector("shoot_left", "shoot_right", "shoot_up", "shoot_down", .1)

	if shoot_direction.length() >= .1 and shoot_cooldown <= 0.0:
		shoot_cooldown = shoot_timer
		var bullet = BULLET_CLASS.instantiate()
		bullet.direction = shoot_direction.normalized()
		bullet.position = position
		BULLETS.add_child(bullet)
		
		
