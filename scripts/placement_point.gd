class_name PlacementPoint
extends Node2D

@export var accepted_structures: Array[int] = []

func accepts(input: Structure) -> bool:
	var ans = false
	
	if input != null:
		for i in input.upgrade_tree:
			if accepted_structures.has(i):
				return true
	
	return ans
