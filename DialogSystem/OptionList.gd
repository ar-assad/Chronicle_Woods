extends VBoxContainer

func get_button_focus():  # this function is called when the options are displayed
	var first_button = get_child(0)
	var last_button = get_child(get_child_count()-1)
	if first_button != null:
		first_button.grab_focus()
	if last_button != null:
		first_button.focus_neighbour_top = last_button.get_path()
		last_button.focus_neighbour_bottom = first_button.get_path()

