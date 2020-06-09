tool
extends RichTextEffect
class_name RichTextPitch

#Syntax: [wait time=0 speed=0][/wait]

var bbcode := "audio"
var pitch : float

var into_block := false

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	pitch = char_fx.env.get("pitch", 1.0)
	
	if char_fx.elapsed_time > 0:
		into_block = true
	
	return true
