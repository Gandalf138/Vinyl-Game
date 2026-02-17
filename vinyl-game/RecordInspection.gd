extends Control

@onready var record_sleeve = $RecordSleeve/Sprite2D
@onready var vinyl = $Vinyl
@onready var vinyl_sprite = $Vinyl/Sprite2D
@onready var back_button = $BackButton

var album = GameManager.current_record
var runout
var nmvalue
var record_pressed := false
var dragging_record := false
var drag_offset := 0.0

func _ready() -> void:
	if GameManager.vinyl_present:
		vinyl_sprite.texture = load("res://art/vinyl.png")
	create_back_button()
	create_record()

func _process(delta: float) -> void:
	if dragging_record:
		var center = vinyl.global_position
		var mouse_pos = get_global_mouse_position()
		var angle = center.angle_to_point(mouse_pos)
		vinyl.rotation = angle + drag_offset

func create_back_button():
	back_button.text = "Return to counter"
	back_button.add_theme_font_size_override("font_size", 36)
	
func create_record():
	record_sleeve.texture = album.cover_texture
	runout = album.runout
	nmvalue = album.nm_value
	GameManager.record_present = true
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			dragging_record = false

func _on_record_sleeve_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if GameManager.record_present == true:
				if record_pressed == false:
					GameManager.vinyl_present = true
					vinyl_sprite.texture = load("res://art/vinyl.png")
					#quality_label.text = "Quality: " + quality.pick_random()
					#quality_label.add_theme_font_size_override("font_size", 36)
					#runout_label.text = 'Runout Text: ' + runout
					#runout_label.add_theme_font_size_override("font_size", 36)
				
				record_pressed = true
				
func _on_vinyl_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var mouse_pos = get_global_mouse_position()
				var center_x = vinyl.global_position.x

				var clicked_right_side = mouse_pos.x > center_x

				if clicked_right_side:
					dragging_record = true
					
					var center = vinyl.global_position
					
					var click_angle = center.angle_to_point(mouse_pos)
					drag_offset = vinyl.rotation - click_angle

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")
