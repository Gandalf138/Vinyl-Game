extends Control

@onready var right_counter_container = $RightCenterContainer/RightCounterContainer
@onready var searchbar = $RightCenterContainer/RightCounterContainer/SearchBar
@onready var search_label = $RightCenterContainer/RightCounterContainer/SearchLabel
@onready var NMvalue_label = $RightBottomContainer/ValuesContainer/NMValueLabel
@onready var VGvalue_label = $RightBottomContainer/ValuesContainer/VGValueLabel
@onready var Fvalue_label = $RightBottomContainer/ValuesContainer/FValueLabel
@onready var record_stack = $RecordStack
@onready var record_stack_sprite = $RecordStack/RecordStack
@onready var top_record_sprite = $RecordStack/TopRecord
@onready var record = $Record
@onready var disc = $Disc
@onready var sheen = $Sheen
@onready var album_cover = $Record/Sprite2D
@onready var disc_sprite = $Disc/Sprite2D
@onready var buy_label = $BuyStackLabel

var rng = RandomNumberGenerator.new()
var albums: Array[AlbumData] = []
var album_cover_paths = []
var nmvalue = 0
var dragging_record := false
var drag_offset := 0.0
var quality = ['NM', 'VG', 'F']
var buy_value = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_albums()
	create_searchbar()
	create_record_stack()
	if GameManager.record_present:
		create_record(GameManager.current_record)
	if GameManager.disc_present:
		create_disc()
	create_value_label()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if dragging_record:
		var center = disc.global_position
		var mouse_pos = get_global_mouse_position()
		var angle = center.angle_to_point(mouse_pos)
		disc.rotation = angle + drag_offset
	
func load_albums():
	var dir = DirAccess.open("res://albums")
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			if file.ends_with(".tres"):
				albums.append(load("res://albums/" + file))
			file = dir.get_next()
	
func create_searchbar():
	search_label.text = "Enter runout text: "
	search_label.add_theme_font_size_override("font_size", 36)
	search_label.add_theme_color_override("font_color", Color.BLACK)
	searchbar.add_theme_font_size_override("font_size", 30)
	searchbar.custom_minimum_size = Vector2(200, 50)
	
func create_record(album):
	if GameManager.record_present == false or GameManager.record_present == null:
		GameManager.current_record = album.duplicate(true)
	album_cover.texture = album.cover_texture
	if GameManager.current_record.quality == null:
		GameManager.current_record.quality = quality.pick_random()
	GameManager.record_present = true
	
func get_top_record():
	if GameManager.records_in_stack != []:
		GameManager.top_of_stack = GameManager.records_in_stack[0]
	
func create_value_label():
	var crp
	if GameManager.current_record == null or GameManager.current_record.price == null:
		crp = 0
	else:
		crp = GameManager.current_record.price
	var value = int(get_buy_stack_value()) + crp
	buy_label.text = 'Stack Value: ' + str(value)
	
func get_buy_stack_value() -> int:
	var total = 0
	for record in GameManager.buy_stack:
		if record.price != null:
			total += record.price
	return total
			
func create_record_stack():
	record_stack_sprite.texture = load("res://art/Assets/record_stack.png")
	if GameManager.records_in_stack == [] and GameManager.buy_stack == []:
		# How many records are in the stack
		var n = rng.randi_range(1, 10)
		var r = 0
		while r < n:
			GameManager.records_in_stack.append(albums.pick_random())
			r += 1
	elif GameManager.records_in_stack == [] and GameManager.buy_stack != []:
		record_stack_sprite.texture = null
		top_record_sprite.texture = null
		record_stack.get_node("CollisionShape2D").disabled = true
		return
	get_top_record()
	top_record_sprite.texture = GameManager.top_of_stack.cover_texture
	
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
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			dragging_record = false
			
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
				record_stack_sprite.texture = null
				top_record_sprite.texture = null
				record_stack.get_node("CollisionShape2D").disabled = true
			else:
				create_record_stack()
			
func _on_record_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if GameManager.record_present == true:
				GameManager.current_record.disc_rotation = disc.rotation
				get_tree().change_scene_to_file("res://RecordInspection.tscn")

func _on_search_bar_text_submitted(new_text: String) -> void:
	nmvalue = GameManager.current_record.nm_value
	var vgvalue = int(floor(nmvalue * .7))
	var fvalue = int(floor(nmvalue * .2))

	if new_text == GameManager.current_record.runout and GameManager.record_present:
		NMvalue_label.text = 'NM: $' + str(nmvalue)
		NMvalue_label.add_theme_font_size_override("font_size", 24)
		NMvalue_label.add_theme_color_override("font_color", Color.BLACK)
		VGvalue_label.text = 'VG: $' + str(vgvalue)
		VGvalue_label.add_theme_font_size_override("font_size", 24)
		VGvalue_label.add_theme_color_override("font_color", Color.BLACK)
		Fvalue_label.text = 'F: $' + str(fvalue)
		Fvalue_label.add_theme_font_size_override("font_size", 24)
		Fvalue_label.add_theme_color_override("font_color", Color.BLACK)
	else:
		NMvalue_label.text = ''
		VGvalue_label.text = ''
		Fvalue_label.text = ''

func _on_vinyl_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
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
