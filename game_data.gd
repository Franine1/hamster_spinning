class_name GameData
extends Resource

static var main: GameData

var hamster_power: float = 0.0
var money: float = 0.0
var food: float = 0.0


static func _static_init() -> void:
	if (main == null) or !(main is GameData):
		var temp: GameData = GameData.new()
		main = temp

static func get_game() -> GameData:
	
	if (main == null) or !(main is GameData):
		var temp: GameData = GameData.new()
		main = temp
	
	return main

func get_HP() -> float:
	return hamster_power

func get_money() -> float:
	return money

func get_food() -> float:
	return food

func set_HP(input: float) -> void:
	hamster_power = input

func set_money(input: float) -> void:
	money = input

func set_food(input: float) -> void:
	food = input

func change_HP(input: float) -> void:
	hamster_power += input

func change_money(input: float) -> void:
	money += input

func change_food(input: float) -> void:
	food += input
