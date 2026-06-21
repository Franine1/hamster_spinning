class_name Structure
extends Resource

@export_category("Display")
@export var image: Texture2D
@export var size: Vector2i

@export_category("Output")
@export var HP_output: float = 0.0
@export var money_output: float = 0.0
@export var food_output: float = 0.0

@export_category("Shop")
@export var price: float = 0.0
@export var description: String = ""
@export var tier: int = 0
@export var upgrade_tree: Array[int] = []
