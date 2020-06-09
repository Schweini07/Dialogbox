tool
extends RichTextEffect
class_name RichTextWait

#Syntax: [wait time=0][/wait]

var bbcode := "wait"
var time : float

var wait := false


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	time = char_fx.env.get("time", 1.0)
	if char_fx.absolute_index < char_fx.relative_index:
		wait = true
	return true
