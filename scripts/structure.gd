class_name Structure
extends Resource

@export_category("Display")
@export var image: Texture2D
@export var animation_scene: PackedScene = null
@export var recolor: ShaderMaterial
@export var size: Vector2i
@export var do_physics: bool = true
@export var do_visibility: bool = true

@export_category("Audio")
@export var click_sound: AudioStream
@export var placement_sound: AudioStream
@export var error_sound: AudioStream
@export var eat_sound: AudioStream

@export_category("Input")
@export var HP_input: float = 0.0
@export var money_input: float = 0.0
@export var food_input: float = 0.0
@export var max_food_storage: float = 0.0

@export_category("Output")
@export var HP_output: float = 0.0
@export var money_output: float = 0.0
@export var food_output: float = 0.0
@export var clickable: bool = false
@export var expensive_click: bool = false
@export var indestructible: bool = false
@export var constant_output: bool = true
@export var partial_output: bool = true
@export var feature_copy_mode: mode = mode.REPLACE

@export_category("Shop")
@export var price: float = 0.0
@export var copy_cost: bool = false
@export var purchase_resource: material_type = material_type.MONEY
@export var description: String = ""
@export var tooltip_hint: String = ""
@export var tier: int = 0
@export var upgrade_tree: Array[int] = []
@export var purchase_hints: Array[String] = []


enum material_type {
	MONEY,
	HAMSTER_POWER,
	FOOD
}

enum mode {
	REPLACE,
	COPY,
	COMPARE_AND,
	COMPARE_OR
}

func tooltip() -> String:
	var ans: String = ""
	if (HP_output - HP_input):
		ans = "HP production: " + str(HP_output - HP_input) + "\n"
	if (money_output - money_input):
		ans = ans + "money production: " + str(money_output - money_input) + "\n"
	if (food_output - food_input):
		ans = ans + "food production: " + str(food_output - food_input) + "\n"
	if (price != 0.0):
		const names: Array[String] = ["$","Hamster Power","Food"]
		if purchase_resource == material_type.MONEY:
			ans = ans + "PRICE: $" + str(snapped(price,1)) + "\n"
		else:
			ans = ans + "PRICE: " + str(snapped(price,1)) + " " + names[purchase_resource] + "\n"
	ans = ans + tooltip_hint
	
	return ans

func cost() -> Vector3:
	var ans = Vector3(0.0,0.0,0.0)
	
	ans[purchase_resource] -= price
	
	return ans


static func affordable(input: Vector3) -> bool:
	var game: GameData = GameData.get_game()
	
	var compare: Vector3 = Vector3(game.get_money(),game.get_HP(),game.get_food())
	
	var both = compare + input
	
	for i in range(3):
		if both[i] < 0.0:
			return false
	
	return true



static func expend(input: Vector3) -> void:
	var game: GameData = GameData.get_game()
	
	var methods: Array[Callable] = [game.change_money,game.change_HP,game.change_food]
	
	for i in range(3):
		
		if input[i] != 0.0:
			methods[i].call(input[i])


func accepts(input: Structure) -> bool:
	var ans = false
	
	if input != null:
		for i in input.upgrade_tree:
			if upgrade_tree.has(i):
				return true
	
	return ans

func get_animation() -> PackedScene:
	return animation_scene
