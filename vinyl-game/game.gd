extends Control

@onready var record_button = $CenterContainer/RecordButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_record_button()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func create_record_button():
	record_button.text = 'Records'
