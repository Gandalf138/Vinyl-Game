extends Node2D

signal record_clicked(record)

@onready var record_display = $RecordDisplay
@onready var click_area = $ClickArea

func _ready():
	update_display()
	click_area.input_event.connect(_on_input_event)
	
func update_display():
	var stack = GameManager.buy_stack
	
	if stack.size() > 0:
		var top_record = stack[-1]
		record_display.texture = top_record.cover_texture
		record_display.visible = true
	else:
		record_display.visible = false
		
func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		var stack = GameManager.buy_stack
		if stack.size() > 0:
			emit_signal("record_clicked", stack[-1])
