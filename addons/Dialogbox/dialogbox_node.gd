tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("Dialogbox", "NinePatchRect", preload("Dialogbox.gd"), preload("node_icon.png"))

func _exit_tree():
	remove_custom_type("Dialogbox")
