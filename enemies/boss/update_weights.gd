extends Action
class_name UpdateWeights


@onready var anti_air_punish = %"anti air punish"
@onready var fast_attack = %"fast ground attack"
@onready var dash_from_moon = %"jump moon attack cooldown"
@onready var laser = %"laser from moon"


func run(delta: float) -> Status:

	if not is_active():
		return Status.FAILURE
	var is_updated = update_weights()
	print("update weights")
	if is_updated:
		return Status.SUCCESS
	else:
		return Status.FAILURE

func interrupt():
	return Status.INTERRUPTED

func count_recent(actions: Array, action_name: String, max_check := 10) -> int:
	var count := 0
	var start: int = max(0, actions.size() - max_check)

	for i in range(start, actions.size()):
		if actions[i] == action_name:
			count += 1

	return count

func update_weights():
	var history: Array = blackboard.get_value("player_actions", [])
	
	anti_air_punish.weight = 1.0
	fast_attack.weight = 1.0
	dash_from_moon.weight = 1.0
	laser.weight = 1.0


	var jump_count = count_recent(history, "JUMP", 8)
	var attack_count = count_recent(history, "ATTACK", 8)
	var slide_count = count_recent(history, "SLIDE", 8)
	var heal_count = count_recent(history, "HEAL", 8)

	if jump_count >= 4:
		anti_air_punish.weight = 8.0

	if attack_count >= 4:
		fast_attack.weight = 6.0

	if slide_count >= 3:
		dash_from_moon.weight = 5.0

	if heal_count >= 1:
		laser.weight = 10.0
	
	print(history)
	print("anti_air_punish.weight ", anti_air_punish.weight)
	print("fast_attack.weight ", fast_attack.weight)
	print("dash_from_moon.weight ", dash_from_moon.weight)
	
	return true
