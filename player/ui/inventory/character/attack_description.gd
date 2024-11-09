extends ColorRect


func render(attack: Dictionary):
	$title.text = attack['name']
	$description.text = attack['description']
	$type.text = 'Type: ' + Player.type_to_string(attack['type'])
	$cool_down.text = 'Cool Down: ' + str(attack['cool_down'])
	$mana_cost.text = 'Mana Cost: ' + str(attack['mana_cost'])
