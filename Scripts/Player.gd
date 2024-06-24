extends CharacterBody2D

@export var speed = 200

@onready var animated_sprite = $AnimatedSprite2D
@onready var interact_ui = $InteractUI
@onready var inventory_ui = $InventoryUI
@onready var inventory_hotbar = $InventoryHotbar

func _ready():
	Global.set_player_reference(self)

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _physics_process(_delta):
	get_input()
	move_and_slide()
	update_animations()

func update_animations():
	if velocity == Vector2.ZERO:
		animated_sprite.play("idle")
	else:
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x > 0:
				animated_sprite.play("walk_right")
			else:
				animated_sprite.play("walk_left")
		else:
			if velocity.y > 0:
				animated_sprite.play("walk_down")
			else:
				animated_sprite.play("walk_up")

func _input(event):
	if event.is_action_pressed("ui_inventory"):
		inventory_ui.visible = !inventory_ui.visible
		get_tree().paused = !get_tree().paused
		inventory_hotbar.visible = !inventory_hotbar.visible

func apply_item_effect(item):
	match item["effect"]:
		"Speed":
			speed += 50
			print("Speed increased to ", speed)
		_:
			print("There is no effect for this item")

func use_hotbar_item(slot_index):
	if slot_index < Global.hotbar_inventory.size():
		var item = Global.hotbar_inventory[slot_index]
		if item != null:
			apply_item_effect(item)
			item["quantity"] -= 1
			if item["quantity"] <= 0:
				Global.hotbar_inventory[slot_index] = null
				Global.remove_item(item["type"], item["effect"])
			Global.inventory_updated.emit()

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		for i in range(Global.hotbar_size):
			if Input.is_action_just_pressed("hotbar_" + str(i+1)):
				use_hotbar_item(i)
				break
