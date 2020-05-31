tool
extends RichTextEffect
class_name RichTextPitch

#Syntax: [wait time=0 speed=0][/wait]

var bbcode := "audio"
var current_char := 0


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var pitch : float = char_fx.env.get("pitch", 1.0)
	
	return true
