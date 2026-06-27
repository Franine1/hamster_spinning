class_name GameData
extends Resource

static var main: GameData

var hamster_power: float = 0.0
var money: float = 0.0
var food: float = 0.0
var food_in_hand: float = 0.0

var hp_recordings: Dictionary[float,float] = {}
var money_recordings: Dictionary[float,float] = {}
var food_recordings: Dictionary[float,float] = {}

var current_blueprint: Structure = null
var current_tooltips: Array[tooltip]

var unlocks: Dictionary[int,int]
var extra_space: int = 0

var has_won: bool = false

class tooltip:
	var label: String
	var start_time: float
	var duration: float 
	var channel: String = ""
	
	func _init(_label: String, _duration: float = 0.5) -> void:
		rename(_label)
		refresh(_duration)
	
	func finished() -> bool:
		return Time.get_unix_time_from_system() >= (duration + start_time)
	
	func set_channel(input: String) -> void:
		if input.length() > 0:
			channel = input
		else:
			channel = ""
	
	func rename(input: String) -> void:
		label = input
	
	func refresh(_duration: float = 0.5) -> void:
		start_time = Time.get_unix_time_from_system()
		duration = _duration
		


signal blueprint_changed(blueprint: Structure)
signal victory()

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

func set_blueprint(input: Structure = null) -> void:
	current_blueprint = input
	blueprint_changed.emit(current_blueprint)

func get_blueprint() -> Structure:
	return current_blueprint

func set_tooltip(input: String = "", time: float = 0.5, channel: String = "") -> void:
	if time > 0.0:
		if channel.length() > 0:
			for item in current_tooltips:
				if item.channel == channel:
					item.rename(input)
					item.refresh(time)
					return
		
		var next: tooltip = tooltip.new(input,time)
		next.set_channel(channel)
		current_tooltips.append(next)

func get_tooltip() -> Array[String]:
	
	var ans: Array[String] = []
	
	var removed: Array[int] = []
	
	for i in current_tooltips.size():
		if current_tooltips[i].finished():
			removed.append(i)
		else:
			ans.append(current_tooltips[i].label)
	
	for i in range(removed.size()-1,-1,-1):
		current_tooltips.remove_at(removed[i])
	
	return ans


func add_unlocks(input: Structure) -> void:
	for i in input.upgrade_tree:
		
		if unlocks.has(i):
			unlocks[i] = max(input.tier+1,unlocks[i])
		else:
			unlocks[i] = input.tier+1


func is_unlocked(input: Structure) -> bool:
	
	var ans = input.upgrade_tree.size() == 0
	
	for i in input.upgrade_tree:
		if !unlocks.has(i):
			unlocks[i] = 0
		
		ans = (unlocks[i] >= input.tier)
		
		if ans:
			return ans
	
	return ans

func grab_food() -> void:
	food_in_hand = food
	food = 0.0

func release_food() -> void:
	food += food_in_hand
	food_in_hand = 0.0

func take_food(amount: float) -> float:
	var reduction = min(food_in_hand,amount)
	food_in_hand -= reduction
	record_food(-reduction,Time.get_unix_time_from_system())
	return reduction

func held_food() -> float:
	return food_in_hand

func add_space(input: int) -> void:
	if input < 0:
		return
	var ans = 1 << input
	
	extra_space = (extra_space & (~ans))
	extra_space += ans

func get_space() -> int:
	return extra_space

func declare_victory() -> void:
	has_won = true
	victory.emit()

func is_victory_achieved() -> bool:
	return has_won
