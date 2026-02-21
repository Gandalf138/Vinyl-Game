extends Node

var first_load
var albums: Array[AlbumData] = []

#Buy Stack Variables/functions
var buy_stack: Array = []

func add_to_buy_stack(record):
	buy_stack.append(record)

func get_currentt_record():
	if buy_stack.is_empty():
		return null
	return buy_stack.back()

#Pricing Variables
var sticker_exists
var sticker_position
var sticker_price
var max_sticker_z: int = 0

#Inventory Variables
var inventory: Array[AlbumData] = []
