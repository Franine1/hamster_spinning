extends Control




func _process(_delta: float) -> void:
	
	var game: GameData = GameData.get_game()
	
	%HP_value.text = str(snapped(game.get_HP(),0.1))
	%money_value.text = str(snapped(game.get_money(),0.1))
	%food_value.text = str(snapped(game.get_food()+game.held_food(),0.1))
	%HP_rate.text = str(snapped(game.get_HP_rate(),0.1)) + " / s"
	%money_rate.text = str(snapped(game.get_money_rate(),0.1)) + " / s"
	%food_rate.text = str(snapped(game.get_food_rate(),0.1)) + " / s"

	if %FoodPillText:
		%FoodPillText.text = str(snapped(game.get_food()+game.held_food(),0.1))
