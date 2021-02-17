extends Node2D

onready var _Body_Tween = find_node("BodyTween")
onready var _Body_LBL = find_node("BodyLabel")
onready var _Registry = find_node("SimulatedRegistry")
onready var _Dialog_Box = find_node("DialogBox")
onready var _Speaker_LBL = find_node("SpeakerLabel")
onready var _Next_Icon = find_node("NextIconPatch")
onready var _Option_List = find_node("OptionList")
onready var _Select_Choice_Icon = find_node("SelectChoicePatch")
onready var _Option_Button_Scene = load("res://DialogSystem/OptionButton.tscn")
onready var _Character_Texture = find_node("CharacterTexture")

var _did = 0
var _nid = 0
var _final_nid = 0
var _Story_Reader
var _texture_library: Dictionary = {}
var text_speed = 0.8 #the less this value, the more the speed

export(String, FILE) var _story: = ""
export(String) var _dialog: = ""

# Virtual Methods

func _ready():
	_Dialog_Box.visible = false
	_Next_Icon.visible = false
	_Select_Choice_Icon.visible = false
	_Option_List.visible = false

func _start() -> void:
	
	var StoryReader = load("res://addons/EXP-System-Dialog/Reference_StoryReader/EXP_StoryReader.gd")
	_Story_Reader = StoryReader.new()
	
	var story = load(_story)
	_Story_Reader.read(story)
	
	_load_textures()
	_clear_options()
	
	if not _is_playing():
		play_dialog(_dialog)

func _unhandled_input(_event) -> void:
	if Input.is_action_just_pressed("accept"):
		_Body_Tween.playback_speed = 20
		_on_Dialog_Player_pressed_next()
	if Input.is_action_just_pressed("back") and _is_playing():
		_Body_Tween.playback_speed = 800
# Callback Methods

func _on_BodyTween_tween_all_completed() -> void:
	if _Option_List.get_child_count() == 0:
		_Next_Icon.visible = true
	else:
		_Select_Choice_Icon.visible = true
		_Option_List.visible = true
		_Option_List.get_button_focus()

func _on_Dialog_Player_pressed_next():
	if _is_waiting():
		_Next_Icon.visible = false
		_Character_Texture.visible = false
		_get_next_node()
		if _is_playing():
			_play_node()

func _on_Option_clicked(slot):
	_Select_Choice_Icon.visible = false
	_Option_List.visible = false
	_Character_Texture.visible = false
	_get_next_node(slot)
	_clear_options()
	if _is_playing():
		_play_node()

# Public Methods

func play_dialog(record_name : String):
	_did = _Story_Reader.get_did_via_record_name(record_name)
	_nid = _Story_Reader.get_nid_via_exact_text(_did, "<start>")
	_final_nid = _Story_Reader.get_nid_via_exact_text(_did, "<end>")
	_get_next_node()
	_play_node()
	_Dialog_Box.visible = true
	get_tree().paused = true
# Private Methods

func _display_image(key: String):
	_Character_Texture.texture = _texture_library[key]
	_Character_Texture.visible = true

func _load_textures():
	var did = _Story_Reader.get_did_via_record_name("TextureLibrary")
	var json_text = _Story_Reader.get_text(did, 1)
	var raw_texture_library: Dictionary = parse_json(json_text)

	for key in raw_texture_library:
		var texture_path = raw_texture_library[key]
		var loaded_texture = load(texture_path)
		_texture_library[key] = loaded_texture

func _clear_options():
	var children = _Option_List.get_children()
	for child in children:
		_Option_List.remove_child(child)
		child.queue_free()

func _is_playing() -> bool:
	return _Dialog_Box.visible
	
func _is_waiting() -> bool:
	return _Next_Icon.visible

func _inject_variables(text: String) -> String:
	var var_count = text.count("<var>")
	for _i in range(var_count):
		var variable_name = _get_tagged_text("var", text)
		var variable_value = _Registry.lookup(variable_name)
		var start_index = text.find("<var>")
		var end_index = text.find("</var>") + "</var>".length()
		var substr_length = end_index - start_index
		text.erase(start_index, substr_length)
		text = text.insert(start_index, str(variable_value))
	return text

func _get_next_node(slot: int = 0):
	_nid = _Story_Reader.get_nid_from_slot(_did, _nid, slot)
	
	if _nid == _final_nid:
		_Dialog_Box.visible = false
		get_tree().paused = false

func _get_tagged_text(tag : String, text : String) -> String:
	var start_tag = "<" + tag + ">"
	var end_tag = "</" + tag + ">"
	var start_index = text.find(start_tag) + start_tag.length()
	var end_index = text.find(end_tag)
	var substr_length = end_index - start_index
	return text.substr(start_index, substr_length)
	
func _play_node():
	var text = _Story_Reader.get_text(_did, _nid)
	text = _inject_variables(text)
	var speaker = _get_tagged_text("speaker", text)
	var dialog = _get_tagged_text("dialog", text)
	_Body_LBL.bbcode_text = dialog
	_Speaker_LBL.bbcode_text = "[center]" + speaker + "[/center]"
	call_deferred('_get_text_tween')
	if "<choiceJSON>" in text:
		var options = _get_tagged_text("choiceJSON", text)
		_populate_choices(options)
	if "<image>" in text:
		var library_key = _get_tagged_text("image", text)
		_display_image(library_key)

func _populate_choices(JSONtext: String):
	var choices: Dictionary = parse_json(JSONtext)
	for text in choices:
		var slot = choices[text]
		var new_option_button = _Option_Button_Scene.instance()
		_Option_List.add_child(new_option_button)
		new_option_button.slot = slot
		new_option_button.set_text(text)
		new_option_button.connect("clicked", self, "_on_Option_clicked")

func _get_text_tween():
	var seconds = text_speed * _Body_LBL.get_total_character_count()
	_Body_Tween.interpolate_property(_Body_LBL, 'percent_visible', 0, 1, seconds, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_Body_Tween.start()
	print(_Body_Tween.get_runtime())
