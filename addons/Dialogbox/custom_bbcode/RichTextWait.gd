tool
extends RichTextEffect
class_name RichTextWait

#Syntax: [wait time=0 speed=0][/wait]

var bbcode := "wait"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var time : float = char_fx.env.get("time", 1.0)
	
	char_fx.visible = false
	if float(char_fx.elapsed_time) > ( (float(char_fx.absolute_index) / 16.0) + float(time) ):
		char_fx.visible = true
	return true
