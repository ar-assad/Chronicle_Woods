extends KinematicBody2D

onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var ray = $Ray

export(int) var MAX_SPEED = 100
export(int) var ACCELARATION = 500
export(int) var FRICTION = 900

var velocity = Vector2.ZERO

func _ready() -> void:
	animationTree.active = true

func _physics_process(delta: float) -> void:
	var direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up"))
	direction = direction.normalized()
	
	if direction != Vector2.ZERO:
		animationTree.set("parameters/Idle/blend_position", direction)
		animationTree.set("parameters/Walk/blend_position", direction)
		animationState.travel("Walk")
		velocity = velocity.move_toward(direction * MAX_SPEED, ACCELARATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
# warning-ignore:return_value_discarded
	move_and_slide(velocity)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("accept") and ray.is_colliding():
		var object = ray.get_collider()
		if object.is_in_group("Interactables"):
			object.interact()
