extends Control

@onready var record_sleeve = $RecordSleeve/Sprite2D
@onready var disc = $Disc
@onready var disc_sprite = $Disc/Sprite2D
@onready var back_button = $BackButton
@onready var runout_label = $Disc/RunoutLabel

var album
var runout
var nmvalue
var dragging_record := false
var drag_offset := 0.0

func _ready() -> void:
	album = GameManager.current_record
	if GameManager.disc_present:
		create_disc()
	create_back_button()
	create_record()

func _process(delta: float) -> void:
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
	disc_sprite.texture = load("res://art/Assets/disc.png")
	runout_label.text = album.runout
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			dragging_record = false

func _on_record_sleeve_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if GameManager.record_present == true:
				GameManager.disc_present = true
				create_disc()

				
func _on_vinyl_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
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
	get_tree().change_scene_to_file("res://game.tscn")
