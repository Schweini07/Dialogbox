extends Node2D

func _ready():
	yield(get_tree(), "idle_frame")
	var dialog := ["Good morning, Sir. I knew you would come. I knew it", "Surprised aren't you?"]
	$Dialogbox.show_text(dialog)
