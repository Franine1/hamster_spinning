class_name GameData
extends Resource

static var main: GameData

var hamster_power: float = 0.0
var money: float = 0.0
var food: float = 0.0

var hp_recordings: Dictionary[float,float] = {}
var money_recordings: Dictionary[float,float] = {}
var food_recordings: Dictionary[float,float] = {}

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
	change_HP(input - hamster_power)

func set_money(input: float) -> void:
	change_money(input - money)

func set_food(input: float) -> void:
	change_food(input - food)

func change_HP(input: float) -> void:
	record_HP(input,Time.get_unix_time_from_system())
	hamster_power += input

func change_money(input: float) -> void:
	record_money(input,Time.get_unix_time_from_system())
	money += input

func change_food(input: float) -> void:
	record_food(input,Time.get_unix_time_from_system())
	food += input

func record_HP(input: float, time: float) -> void:
	if hp_recordings.has(time):
		hp_recordings[time] += input
	else:
		hp_recordings[time] = input
		

func record_money(input: float, time: float) -> void:
	if money_recordings.has(time):
		money_recordings[time] += input
	else:
		money_recordings[time] = input
		

func record_food(input: float, time: float) -> void:
	if food_recordings.has(time):
		food_recordings[time] += input
	else:
		food_recordings[time] = input
		

func get_HP_rate(time_dist: float = 1.0) -> float:
	hp_recordings = clear_old_recordings(hp_recordings,time_dist)
	
	return accrue_additions(hp_recordings)

func get_money_rate(time_dist: float = 1.0) -> float:
	money_recordings = clear_old_recordings(money_recordings,time_dist)
	
	return accrue_additions(money_recordings)

func get_food_rate(time_dist: float = 1.0) -> float:
	food_recordings = clear_old_recordings(food_recordings,time_dist)
	
	return accrue_additions(food_recordings)

func clear_old_recordings(input: Dictionary[float,float], time_dist: float = 1.0) -> Dictionary[float,float]:
	var ans = input.duplicate()
	var time = Time.get_unix_time_from_system()
	for key in ans.keys():
		if (key + time_dist < time):
			ans.erase(key)
	
	return ans

func accrue_additions(input: Dictionary[float,float]) -> float:
	var time = Time.get_unix_time_from_system()
	
	var lowest_time: float = time
	
	var ans = 0.0
	
	for key in input.keys():
		if key < lowest_time:
			lowest_time = key
		ans += input[key]
	
	var divisor: float = max(time - lowest_time,1.0)
	
	ans /= divisor
	
	return ans
