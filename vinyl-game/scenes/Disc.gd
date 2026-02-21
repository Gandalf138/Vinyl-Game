extends Node2D

@onready var disc_sprite = $DiscSprite
@onready var sheen = $Sheen
@onready var runout_label = $RunoutPivot/RunoutLabel
@onready var runout_pivot = $RunoutPivot
@onready var area = $Area2D

var rng = RandomNumberGenerator.new()
var dragging_sticker:= false
var runout_angle := 0.0
var drag_offset := 0.0
var dragging = false

func _process(delta: float) -> void:
	if dragging:
		var center = global_position
		var mouse_pos = get_global_mouse_position()
		rotation = center.angle_to_point(mouse_pos) + drag_offset

func set_texture(texture):
	disc_sprite.texture = texture

func set_sheen(texture):
	sheen.texture = texture
	
func set_runout(text: String) -> void:
	runout_label.text = text
	randomize_runout()
	_update_runout_position()
	
func randomize_runout(radius := 160.0) -> void:
	runout_angle = rng.randf_range(0, TAU)
	_update_runout_position(radius)
	
func _update_runout_position(radius := 160.0) -> void:
	var x = cos(runout_angle) * radius
	var y = sin(runout_angle) * radius
	runout_pivot.position = Vector2(x, y)
	runout_pivot.rotation = runout_angle + PI/2
	
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var local_click = to_local(get_global_mouse_position())
				
				if local_click.x > 0:
					dragging = true
					var center = global_position
					var click_angle = center.angle_to_point(get_global_mouse_position())
					drag_offset = rotation - click_angle
				else:
					dragging = false
				
func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			dragging = false
