extends Button

signal clicked(slot)

var slot

#Callback Methods

func _on_pressed():
	emit_signal("clicked", slot)

#Public Methods

func set_text(new_text: String):
	text = new_text

