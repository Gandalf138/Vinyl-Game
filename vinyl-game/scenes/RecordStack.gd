extends Area2D

signal record_taken(album)

@onready var stack_sprite = $StackSprite
@onready var top_record_sprite = $TopRecordSprite
@onready var collision = $CollisionShape2D

var albums = []
var records_in_stack = []
var quality = ['NM', 'VG', 'F']

func setup(p_albums):
	albums = p_albums
	create_stack()

func create_stack():
	if records_in_stack.is_empty():
		var n = 10
		
		for i in range(n):
			records_in_stack.append(albums.pick_random().duplicate(true))
	
	get_quality()
	update_visuals()

func get_quality():
	for record in records_in_stack:
		if record.quality == null:
			record.quality = quality.pick_random()

func update_visuals():
	if records_in_stack.is_empty():
		stack_sprite.texture = null
		top_record_sprite.texture = null
		collision.disabled = true
	else:
		stack_sprite.texture = load("res://art/Assets/record_stack.png")
		top_record_sprite.texture = records_in_stack[0].cover_texture
		collision.disabled = false
		
func take_top_record():
	if records_in_stack.is_empty():
		return
	
	var album = records_in_stack.pop_front()
	update_visuals()
	emit_signal("record_taken", album)
	
func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			take_top_record()
