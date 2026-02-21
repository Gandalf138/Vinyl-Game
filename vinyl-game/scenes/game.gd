extends Control

@onready var right_counter_container = $RightCenterContainer/RightCounterContainer
@onready var searchbar = $RightCenterContainer/RightCounterContainer/SearchBar
@onready var search_label = $RightCenterContainer/RightCounterContainer/SearchLabel
@onready var NMvalue_label = $RightBottomContainer/ValuesContainer/NMValueLabel
@onready var VGvalue_label = $RightBottomContainer/ValuesContainer/VGValueLabel
@onready var Fvalue_label = $RightBottomContainer/ValuesContainer/FValueLabel

@onready var disc = $Disc
@onready var sheen = $Sheen
@onready var disc_sprite = $Disc/Sprite2D
@onready var buy_label = $BuyStackLabel

#Scenes
@onready var record_stack = $RecordStack
@onready var buy_stack = $BuyStack

var rng = RandomNumberGenerator.new()
var nmvalue = 0
var buy_value = 0

func _ready() -> void:
	if GameManager.first_load == null:
		load_albums()
		get_runouts()
		
	record_stack.setup(GameManager.albums)
	record_stack.record_taken.connect(_on_record_taken)
	
	buy_stack.record_clicked.connect(_on_record_clicked)
	
	create_searchbar()
		
	create_value_label()
	
func _process(_delta: float) -> void:
	pass
	
func load_albums():
	var dir = DirAccess.open("res://albums")
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			if file.ends_with(".tres"):
				GameManager.albums.append(load("res://albums/" + file))
			file = dir.get_next()
	GameManager.first_load = false
	
func get_runouts():
	var characters = [
	'A','B','C','D','E','F','G','H','I','J','K','L','M',
	'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
	'0','1','2','3','4','5','6','7','8','9'
	]
	for record in GameManager.albums:
		var n = 0
		while n < 5:
			record.runout += characters.pick_random()
			n+=1
			
func _on_record_taken(album):
	GameManager.add_to_buy_stack(album)
	buy_stack.update_display()
	create_value_label()
	
func _on_record_clicked(record):
	for i in get_children():
		if has_node("RecordInspection"):
			return
		else:
			open_inspection(record)

func open_inspection(record):
	var inspection_scene = preload("res://scenes/RecordInspection.tscn").instantiate()
	add_child(inspection_scene)
	inspection_scene.load_record(record)
	
func get_buy_stack_value() -> int: 
	var total = 0 
	for record in GameManager.buy_stack: 
		if record.price != null: 
			total += record.price 
	return total
	
	
	
func create_searchbar():
	search_label.text = "Enter runout text: "
	search_label.add_theme_font_size_override("font_size", 36)
	search_label.add_theme_color_override("font_color", Color.BLACK)
	searchbar.add_theme_font_size_override("font_size", 30)
	searchbar.custom_minimum_size = Vector2(200, 50)

func create_value_label():
	var total = get_buy_stack_value()
	buy_label.text = "Stack Value: $" + str(total)





func _on_search_bar_text_submitted(new_text: String) -> void:
	for record in GameManager.albums:
		if new_text == record.runout:
			nmvalue = record.nm_value
			var vgvalue = int(floor(nmvalue * .7))
			var fvalue = int(floor(nmvalue * .2))
			
			NMvalue_label.text = 'NM: $' + str(nmvalue)
			NMvalue_label.add_theme_font_size_override("font_size", 24)
			NMvalue_label.add_theme_color_override("font_color", Color.BLACK)
			VGvalue_label.text = 'VG: $' + str(vgvalue)
			VGvalue_label.add_theme_font_size_override("font_size", 24)
			VGvalue_label.add_theme_color_override("font_color", Color.BLACK)
			Fvalue_label.text = 'F: $' + str(fvalue)
			Fvalue_label.add_theme_font_size_override("font_size", 24)
			Fvalue_label.add_theme_color_override("font_color", Color.BLACK)
			return
		else:
			NMvalue_label.text = ''
			VGvalue_label.text = ''
			Fvalue_label.text = ''
