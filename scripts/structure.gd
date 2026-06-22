class_name Structure
extends Resource

@export_category("Display")
@export var image: Texture2D
@export var size: Vector2i

@export_category("Input")
@export var HP_input: float = 0.0
@export var money_input: float = 0.0
@export var food_input: float = 0.0

@export_category("Output")
@export var HP_output: float = 0.0
@export var money_output: float = 0.0
@export var food_output: float = 0.0
@export var clickable: bool = false
@export var indestructible: bool = false

@export_category("Shop")
@export var price: float = 0.0
@export var purchase_resource: material_type = material_type.MONEY
@export var description: String = ""
@export var tooltip_hint: String = ""
@export var tier: int = 0
@export var upgrade_tree: Array[int] = []


enum material_type {
	MONEY,
	HAMSTER_POWER,
	FOOD
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
