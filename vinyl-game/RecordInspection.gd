extends Control

@onready var record_sleeve = $RecordSleeve/Sprite2D
@onready var back_button = $BackButton
@onready var sheen = $Sheen
@onready var sticker = $Sticker
@onready var sticker_sprite = $Sticker/Sprite2D
@onready var price = $Sticker/Label
@onready var pad_screen = $NumberPad/PadScreen
@onready var sticker_zone = $RecordSleeve/StickerZone

#Scenes
@onready var disc_scene = $Disc

var album
var runout
var nmvalue

func _ready() -> void:
	$NumberPad.print_pressed.connect(_on_print_pressed)
	create_back_button()
	
func _process(_delta: float) -> void:
	pass
	#if dragging_sticker:
		#var mouse_pos = get_global_mouse_position()
		#sticker.position = mouse_pos
		
func _enter_tree():
	if album != null:
		setup_record()

func _on_print_pressed(value):
	create_sticker(value)

func create_back_button():
	back_button.text = "Return to counter"
	back_button.add_theme_font_size_override("font_size", 36)
	
func load_record(record):
	album = record
	setup_record()
	setup_disc()
	
func setup_record():
	record_sleeve.texture = album.cover_texture
	
func setup_disc():
	print(album.quality)
	disc_scene.set_texture(get_disc_texture(album.quality))
	disc_scene.set_runout(album.runout)
	if album.disc_rotation != null:	
		disc_scene.rotation = album.disc_rotation
	else:
		disc_scene.rotation = 0.0

'''
func create_record():
	record_sleeve.texture = album.cover_texture
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
'''
func get_disc_texture(quality):
	match quality:
		"NM":
			return load("res://art/Assets/discs/disc.png")
		"VG":
			return load("res://art/Assets/discs/disc.png")
		"F":
			return load("res://art/Assets/discs/dusty_disc.png")

func _on_record_sleeve_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pass
			
func _on_sticker_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if GameManager.sticker_exists == true:
				#dragging_sticker = event.pressed
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
	album.disc_rotation = disc_scene.rotation
	queue_free()
	
				
func create_sticker(value):
	sticker.position.x = 1540
	sticker.position.y = 150
	sticker_sprite.texture = load("res://art/Assets/sticker.png")
	price.text = pad_screen.text
	pad_screen.text = ''
	GameManager.sticker_price = price.text
	GameManager.sticker_exists = true
