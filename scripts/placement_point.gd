class_name PlacementPoint
extends Node2D

@export var accepted_structures: Array[int] = []
@export var unlock_bit: int = -1

func accepts(input: Structure) -> bool:
	var ans = false
	
	var game: GameData = GameData.get_game()
	
	if !unlocked(game.get_space()):
		return false
	
	if input != null:
		for i in input.upgrade_tree:
			if accepted_structures.has(i):
				return true
	
	return ans

func unlocked(input: int) -> bool:
	if unlock_bit < 0:
		return true
	else:
		var ans = 1 << unlock_bit
		
		return (ans & input)
