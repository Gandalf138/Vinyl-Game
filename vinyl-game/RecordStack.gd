extends Area2D

signal record_taken(album)

@onready var stack_sprite = $StackSprite
@onready var top_record_sprite = $TopRecordSprite
@onready var collision = $CollisionShape2D

var albums = []
var records_in_stack = []

func setup(p_albums):
	albums = p_albums
	create_stack()

func create_stack():
	if records_in_stack.is_empty():
		var n = 5
		
		for i in range(n):
			records_in_stack.append(albums.pick_random())
	
	update_visuals()
	
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







"""

func get_top_record():
	if GameManager.records_in_stack != []:
		GameManager.top_of_stack = GameManager.records_in_stack[0]
		
func create_record_stack():
	stack_sprite.texture = load("res://art/Assets/record_stack.png")
	if GameManager.records_in_stack == [] and GameManager.buy_stack == []:
		# How many records are in the stack
		var n = rng.randi_range(2, 10)
		var r = 0
		while r < n:
			GameManager.records_in_stack.append(GameManager.albums.pick_random())
			r += 1
	elif GameManager.records_in_stack == [] and GameManager.buy_stack != []:
		stack_sprite.texture = null
		top_record_sprite.texture = null
		stack.get_node("CollisionShape2D").disabled = true
		return
	get_top_record()
	top_record_sprite.texture = GameManager.top_of_stack.cover_texture
	
func _on_record_stack_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if GameManager.record_present:
				GameManager.buy_stack.append(GameManager.current_record)
			disc_sprite.texture = null
			if GameManager.disc_present == true:
				disc.rotation = 0
			GameManager.disc_present = false
			sheen.texture = null
			GameManager.record_present = false
			create_record(GameManager.top_of_stack)
			buy_label.text = 'Stack Value: ' + str(get_buy_stack_value())
			GameManager.records_in_stack.remove_at(0)
			if GameManager.records_in_stack == []:
				stack_sprite.texture = null
				top_record_sprite.texture = null
				stack.get_node("CollisionShape2D").disabled = true
			else:
				create_record_stack()
"""
