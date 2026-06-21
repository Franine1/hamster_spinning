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
		ans = ans + "food production: " + str(HP_output - HP_input) + "\n"
	ans = ans + tooltip_hint
	
	return ans
