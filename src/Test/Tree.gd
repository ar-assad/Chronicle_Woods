extends StaticBody2D

export(String) var _dialog: = ""

func interact():
	var main = get_tree().current_scene
	var dialogPlayer = main.find_node("DialogPlayer")
	dialogPlayer._dialog = self._dialog
	dialogPlayer._start()
