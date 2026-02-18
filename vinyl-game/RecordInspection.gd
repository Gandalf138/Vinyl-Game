extends Control

@onready var record_sleeve = $RecordSleeve/Sprite2D
@onready var disc = $Disc
@onready var disc_sprite = $Disc/Sprite2D
@onready var back_button = $BackButton
@onready var runout_label = $Disc/RunoutPivot/RunoutLabel
@onready var runout_pivot = $Disc/RunoutPivot
@onready var sheen = $Sheen

var rng = RandomNumberGenerator.new()
var album
var runout
var nmvalue
var dragging_record := false
var drag_offset := 0.0
var quality = ['NM', 'VG', 'F']

func _ready() -> void:
	album = GameManager.current_record
	if GameManager.disc_present:
		create_disc()
	create_back_button()
	create_record()

func _process(_delta: float) -> void:
	if dragging_record:
		var center = disc.global_position
		var mouse_pos = get_global_mouse_position()
		var angle = center.angle_to_point(mouse_pos)
		disc.rotation = angle + drag_offset

func create_back_button():
	back_button.text = "Return to counter"
	back_button.add_theme_font_size_override("font_size", 36)
	
func create_record():
	record_sleeve.texture = album.cover_texture
	runout = album.runout
	nmvalue = album.nm_value

func create_disc():
	if GameManager.disc_rotation != null:
		disc.rotation = GameManager.disc_rotation
	if GameManager.current_record_quality == null:
		GameManager.current_record_quality = quality.pick_random()
	if GameManager.current_record_quality == 'NM':
		disc_sprite.texture = load("res://art/Assets/discs/disc.png")
		sheen.texture = load("res://art/Assets/discs/sheen.png")
	elif GameManager.current_record_quality == 'VG':
		disc_sprite.texture = load("res://art/Assets/discs/disc.png")
	elif GameManager.current_record_quality == 'F':
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
		angle = GameManager.runout_angle
		
	GameManager.runout_angle = angle
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

func _on_back_button_pressed() -> void:
	GameManager.disc_rotation = disc.rotation
	get_tree().change_scene_to_file("res://game.tscn")
