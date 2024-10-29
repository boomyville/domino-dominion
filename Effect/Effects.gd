extends Resource

class_name Effects

var name: String = ""  # Name of the effect
var description: String = ""  # Description of what the effect does
var duration: int = -1  # Duration of the effect (-1 for indefinite)
var triggers: int = -1  # Number of times the effect triggers (-1 for indefinite)
var type: String = "buff"  # Type of effect (e.g., "buff", "debuff", "neutral")
var image: Texture = null  # Image to display for the effect
var event_type: String = ""  # Event that triggers the effect
var attached_user;  # User that the effect is attached to

# Optional constructor to set duration and triggers
func _init(new_duration: int = -1, new_triggers: int = -1):
    duration = new_duration
    triggers = new_triggers

func get_duration() -> int:
    return duration

func get_triggers() -> int:
    return triggers

func set_attached_user(user):
    attached_user = user

# Method to reduce the effect's duration by 1
func update_duration(target):
    if duration > 0:
        duration -= 1
        print("Duration for ", name, ": ", duration)
        if duration == 0:
            target.effects.erase(self)
            print("Effect removed: ", name)
    target.update()

# Method to reduce the effect's trigger count by 1
func update_trigger(target):
    if triggers > 0:
        triggers -= 1
        if triggers == 0:
            target.effects.erase(self)
            print("Effect removed: ", name)
    target.update()

# Method to extend the effect's duration
func extend_duration(extra_duration: int):
    duration += extra_duration

# Method to extend the effect's trigger count
func extend_triggers(extra_triggers: int):
    triggers += extra_triggers

# Override this method to handle specific events, like "damage" or "block"
func on_event(event_type: String, data: Dictionary) -> void:
  attached_user.update()

# Function to apply an effect to a target
func apply_effect(effect_instance: Effects, target):
    target.effects.append(effect_instance)

# Damage modification methods
func modify_damage(original_damage: int) -> int:
    return original_damage

func magnify_damage(original_damage: int) -> int:
    return original_damage

# Shield modification methods
func modify_shields(original_shields: int) -> int:
    return original_shields

func magnify_shields(original_shields: int) -> int:
    return original_shields

# Healing modification methods
func modify_heal(original_heal: int) -> int:
    return original_heal

func magnify_heal(original_heal: int) -> int:
    return original_heal

# Other trigger methods (override as needed)
func full_block(damage_blocked: int, attacker, defender):
    pass

func on_parry(damage_blocked: int, attacker, defender):
    pass

func on_attack(battler, target):
    pass

func on_damaged(battler, target):
    pass

func on_heal(battler, target):
    pass

func on_shields(battler, target):
    pass