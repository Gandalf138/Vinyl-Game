extends Control

@onready var record_stack_button = $CenterContainer/CounterContainer/RecordStackButton
@onready var counter_container = $CenterContainer/CounterContainer

var record_names = ['The Blue Album', 'The White Album', 'Meet the Beatles', 'Led Zeppelin I']

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_record_stack_button()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func create_record_stack_button():
	record_stack_button.text = 'Records'
	record_stack_button.add_theme_font_size_override("font_size", 50)
	record_stack_button.custom_minimum_size = Vector2(400, 400)

func _on_record_button_pressed() -> void:
	create_record_button()
	
func create_record_button():
	var record_button: Button = Button.new()
	record_button.text = record_names.pick_random()
	record_button.add_theme_font_size_override("font_size", 50)
	record_button.custom_minimum_size = Vector2(400, 400)
	counter_container.add_child(record_button)
