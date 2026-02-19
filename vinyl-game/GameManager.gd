extends Node

#Record Inspection Variables
var current_record
var top_of_stack
var record_present
var disc_present

#Pricing Variables
var sticker_exists
var sticker_position
var sticker_price
var max_sticker_z: int = 0

#Selling Variables
var buy_stack: Array[AlbumData] = []

#Inventory Variables
var inventory: Array[AlbumData] = []
