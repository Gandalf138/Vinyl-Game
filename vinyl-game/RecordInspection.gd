extends Control

@onready var record_sleeve = $RecordSleeve/Sprite2D
@onready var disc = $Disc
@onready var disc_sprite = $Disc/Sprite2D
@onready var back_button = $BackButton
@onready var runout_label = $Disc/RunoutPivot/RunoutLabel
@onready var runout_pivot = $Disc/RunoutPivot
@onready var sheen = $Sheen
@onready var sticker = $Sticker
@onready var sticker_sprite = $Sticker/Sprite2D
@onready var price = $Sticker/Label
@onready var pad_screen = $NumberPad/PadScreen
@onready var sticker_zone = $RecordSleeve/StickerZone

var rng = RandomNumberGenerator.new()
var album
var runout
var nmvalue
var dragging_record := false
var dragging_sticker:= false
var drag_offset := 0.0

func _ready() -> void:
	album = GameManager.current_record
	if GameManager.disc_present:
		create_disc()
	if GameManager.sticker_exists:
			sticker.position = GameManager.sticker_position
			sticker_sprite.texture = load("res://art/Assets/sticker.png")
			price.text = GameManager.sticker_price
	create_back_button()
	create_record()

func _process(_delta: float) -> void:
	if dragging_record:
		var center = disc.global_position
		var mouse_pos = get_global_mouse_position()
		var angle = center.angle_to_point(mouse_pos)
		disc.rotation = angle + drag_offset
	
	if dragging_sticker:
		var mouse_pos = get_global_mouse_position()
		sticker.position = mouse_pos

func create_back_button():
	back_button.text = "Return to counter"
	back_button.add_theme_font_size_override("font_size", 36)
	
func create_record():
	record_sleeve.texture = album.cover_texture
	runout = album.runout
	nmvalue = album.nm_value
	GameManager.max_sticker_z = 0
	for sticker_data in album.stickers:
		var sticker_copy = sticker.duplicate(true)
		sticker_copy.get_node("CollisionShape2D").disabled = true
		sticker_copy.position = sticker_data.position
		sticker_copy.get_node("Label").text = sticker_data.text
		sticker_copy.get_node("Sprite2D").texture = load("res://art/Assets/sticker.png")
		sticker_copy.z_index = GameManager.max_sticker_z
		print('sticker copy z index: ' + str(sticker_copy.z_index))
		record_sleeve.add_child(sticker_copy)
		GameManager.max_sticker_z+=1

func create_disc():
	if GameManager.current_record.disc_rotation != null:
		disc.rotation = GameManager.current_record.disc_rotation
	if GameManager.current_record.quality == 'NM':
		disc_sprite.texture = load("res://art/Assets/discs/disc.png")
		sheen.texture = load("res://art/Assets/discs/sheen.png")
	elif GameManager.current_record.quality == 'VG':
		disc_sprite.texture = load("res://art/Assets/discs/disc.png")
	elif GameManager.current_record.quality == 'F':
		disc_sprite.texture = load("res://art/Assets/discs/dusty_disc.png")
	create_runout()
	GameManager.disc_present = true
	
func create_runout():
	var angle
	var radius = 160
	runout_label.text = album.runout
	runout_label.position.x = -(runout_label.get_minimum_size().x / 2)
	runout_label.position.y = -(runout_label.get_minimum_size().y / 2)
	
	if GameManager.disc_present == false:
		angle = rng.randf_range(0.0, TAU)
	else:
		angle = GameManager.current_record.runout_angle
		
	GameManager.current_record.runout_angle = angle
	var x = cos(angle)*radius
	var y = sin(angle)*radius
	
	runout_pivot.position = Vector2(x, y)
	runout_pivot.rotation = angle + PI/2
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			dragging_record = false

func _on_record_sleeve_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if GameManager.record_present == true:
				if GameManager.disc_present == false:
					create_disc()
				
func _on_disc_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var mouse_pos = get_global_mouse_position()
				var center_x = disc.global_position.x

				var clicked_right_side = mouse_pos.x > center_x

				if clicked_right_side:
					dragging_record = true
					
					var center = disc.global_position
					
					var click_angle = center.angle_to_point(mouse_pos)
					drag_offset = disc.rotation - click_angle

func _on_sticker_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if GameManager.sticker_exists == true:
				dragging_sticker = event.pressed
				if event.pressed:
					GameManager.max_sticker_z += 3
					sticker.z_index = GameManager.max_sticker_z
					if sticker.get_parent() != record_sleeve:
						record_sleeve.add_child(sticker)
					else:
						record_sleeve.move_child(sticker, record_sleeve.get_child_count() - 1)
				else:
					if sticker.get_overlapping_areas().has(sticker_zone):
						var zone_right = get_right_edge(sticker_zone)
						var zone_top = get_top_edge(sticker_zone)
						var sticker_right = get_right_edge(sticker)
						var sticker_top = get_top_edge(sticker)
						
						if sticker_right < zone_right and sticker_top > zone_top:
							var local_pos = record_sleeve.to_local(sticker.global_position)
							var sticker_data = {
								"position": local_pos, 
								"text": price.text,
								}
							GameManager.current_record.stickers.append(sticker_data)
							
							GameManager.current_record.price = int(price.text)
							var sticker_copy = sticker.duplicate(true)
							var old_global_pos = sticker.global_position
							sticker_copy.get_node("CollisionShape2D").disabled = true
							sticker_copy.z_index = sticker.z_index
							record_sleeve.add_child(sticker_copy)
							sticker_copy.global_position = old_global_pos
							
							sticker_sprite.texture = null
							GameManager.sticker_exists = false

func get_right_edge(area: Area2D) -> float:
	var shape = area.get_node("CollisionShape2D").shape
	var half_width = shape.size.x / 2.0
	return area.global_position.x + half_width
	
func get_top_edge(area: Area2D) -> float:
	var shape = area.get_node("CollisionShape2D").shape
	var half_width = shape.size.y / 2.0
	return area.global_position.y - half_width

func _on_back_button_pressed() -> void:
	GameManager.current_record.disc_rotation = disc.rotation
	GameManager.sticker_position = sticker.position
	get_tree().change_scene_to_file("res://game.tscn")
	
#Printer Code
func _on_pad_0_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				pad_screen.text += str('0')
	
func _on_pad_1_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				pad_screen.text += str('1')

func _on_pad_2_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				pad_screen.text += str('2')
				
func _on_pad_3_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				pad_screen.text += str('3')
				
func _on_pad_4_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				pad_screen.text += str('4')
				
func _on_pad_5_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				pad_screen.text += str('5')
				
func _on_pad_6_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				pad_screen.text += str('6')
				
func _on_pad_7_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				pad_screen.text += str('7')
				
func _on_pad_8_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				pad_screen.text += str('8')
				
func _on_pad_9_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				pad_screen.text += str('9')

func _on_pad_clear_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				pad_screen.text = ''

func _on_pad_print_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				create_sticker()
				
func create_sticker():
	sticker.position.x = 1540
	sticker.position.y = 150
	sticker_sprite.texture = load("res://art/Assets/sticker.png")
	price.text = pad_screen.text
	pad_screen.text = ''
	GameManager.sticker_price = price.text
	GameManager.sticker_exists = true
