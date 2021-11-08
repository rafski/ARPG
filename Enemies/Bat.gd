extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")
var knockback = Vector2.ZERO
var velocity = Vector2.ZERO
export var FRICTION = 120
export var acceleration = 300
export var MAX_SPEED = 50

enum {
	IDLE,
	WANDER,
	CHASE
}

var state = IDLE

onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var sprite = $Sprite
onready var hurtbox = $Hurtbox

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
		WANDER:
			pass
			
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				var heading = (player.global_position - global_position).normalized()
				velocity = heading.move_toward(heading * MAX_SPEED, acceleration * delta)
			else:
				state = IDLE
			sprite.flip_h = velocity.x < 0		
				
	velocity = move_and_slide(velocity)
		
func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * FRICTION
	hurtbox.create_hit_effect()
	
func create_death_effect():
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
	
func _on_Stats_no_health():	
	create_death_effect()
	queue_free()
