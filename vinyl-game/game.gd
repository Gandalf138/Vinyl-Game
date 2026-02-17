extends Control

@onready var record_container = $CenterContainer/RecordContainer
@onready var right_counter_container = $RightCenterContainer/RightCounterContainer
@onready var searchbar = $RightCenterContainer/RightCounterContainer/SearchBar
@onready var search_label = $RightCenterContainer/RightCounterContainer/SearchLabel
@onready var runout_label = $CenterBottomContainer/CenterCounterContainer/RunoutLabel
@onready var quality_label = $CenterBottomContainer/CenterCounterContainer/QualityLabel
@onready var NMvalue_label = $RightBottomContainer/ValuesContainer/NMValueLabel
@onready var VGvalue_label = $RightBottomContainer/ValuesContainer/VGValueLabel
@onready var Fvalue_label = $RightBottomContainer/ValuesContainer/FValueLabel
@onready var record_stack = $RecordStack
@onready var record = $Record
@onready var album_cover = $Record/Sprite2D
@onready var vinyl = $Vinyl
@onready var vinyl_sprite = $Vinyl/Sprite2D


var rng = RandomNumberGenerator.new()
var record_names = ['The Blue Album', 'The White Album', 'Meet the Beatles', 'Led Zeppelin I']
var quality = ['NM', 'G', 'F']
var characters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 
'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '0',
 '1', '2', '3', '4', '5', '6', '7', '8', '9']
var runout = ''
var record_pressed = true
var record_present = false
var album_cover_paths = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_album_covers()
	create_searchbar()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func load_album_covers():
	var dir = DirAccess.open("res://art/album covers")
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			if file.ends_with(".png"):
				album_cover_paths.append("res://art/album covers/" + file)
			file = dir.get_next()
	
func create_searchbar():
	search_label.text = "Enter nunout text: "
	search_label.add_theme_font_size_override("font_size", 48)
	searchbar.add_theme_font_size_override("font_size", 36)
	searchbar.custom_minimum_size = Vector2(400, 100)
	
func create_record_button():
	for child in record_container.get_children():
		if child is Button:
			child.queue_free()
		
	var record_button: Button = Button.new()
	record_button.text = record_names.pick_random()
	record_button.add_theme_font_size_override("font_size", 48)
	record_button.custom_minimum_size = Vector2(400, 400)
	record_button.pressed.connect(_on_record_button_pressed.bind())
	record_container.add_child(record_button)

func _on_record_button_pressed():
	if record_pressed == false:
		runout = get_runout()
		quality_label.text = "Quality: " + quality.pick_random()
		quality_label.add_theme_font_size_override("font_size", 48)
		runout_label.text = 'Runout Text: ' + runout
		runout_label.add_theme_font_size_override("font_size", 48)
	
	record_pressed = true
	
func get_runout():
	var text  = ''
	for i in range(5):
		text += characters.pick_random()
	return text

func _on_search_bar_text_submitted(new_text: String) -> void:
	var nmvalue = int(rng.randi_range(70, 100))
	var vgvalue = int(floor(nmvalue * .7))
	var fvalue = int(floor(nmvalue * .2))

	if new_text == runout:
		NMvalue_label.text = 'NM: $' + str(nmvalue)
		NMvalue_label.add_theme_font_size_override("font_size", 48)
		VGvalue_label.text = 'VG: $' + str(vgvalue)
		VGvalue_label.add_theme_font_size_override("font_size", 48)
		Fvalue_label.text = 'F: $' + str(fvalue)
		Fvalue_label.add_theme_font_size_override("font_size", 48)

func _on_record_stack_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			record_pressed = false
			record_present = true
			create_record()
			
func create_record():
	var random_path = album_cover_paths.pick_random()
	var texture = load(random_path)
	album_cover.texture = texture

func _on_record_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if record_present == true:
				if record_pressed == false:
					var vinyl = load("res://art/vinyl.png")
					vinyl_sprite.texture = vinyl
					#runout = get_runout()
					#quality_label.text = "Quality: " + quality.pick_random()
					#quality_label.add_theme_font_size_override("font_size", 48)
					#runout_label.text = 'Runout Text: ' + runout
					#runout_label.add_theme_font_size_override("font_size", 48)
				
				record_pressed = true
