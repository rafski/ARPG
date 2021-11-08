extends AnimatedSprite

func _ready():
	connect("animation_finished", self, "_on_animation_finished")
	frame = 0
	play("die")

func _on_animation_finished():
	queue_free()
