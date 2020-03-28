"""
Thank you, for using this plugin in you project, this really means much to me.

To properly use the plugin consider reading the readme.md or just read the explanation
next to the variables under this text.

This plugin is still under development and right now only the basics of a dialogbox are implemented,
so if you have any issues with this plugin or have an idea, consider opening an issue on the Github repo: 
https://github.com/Schweini07/Dialogbox

Also feel free to use the font, the sound and the textbox from the resources folder.

#sound and textbox
Those two resource are made by me and are under no liscense, you can use it for non- and commercial products.

#font
The font is the SuperLegendBody font 
('res://addons/Dialogbox/resources/SuperLegendBoy-4w8Y.ttf') -> Free for non-commercial use,
you have to buy a liscense for commercial use. Website: https://www.dafont.com/de/super-legend-boy.font

There is also a Showcase scene in the resource folder with which you can experiment with the plugin.

plugin = Dialogbox
author= Laurenz 'Schweini' Reinthaler
version = "0.1"
"""


tool
extends NinePatchRect

#properties
export (bool) var use_visible_characters = true #If set true, the characters (letters) show up with the speed determined trough the speed property
export (float) var character_speed = 1 #Determines how fast the characters (letters) will show up. The smaller the number the faster the text will be.
export (bool) var play_sound = true #If set true, the sound will play after every character that showed up
export (bool) var use_input_trigger = true #If set true, after the end of every dialog, the plugin waits for the input_trigger
export (Array) var text #An Array. Can be used in the editor but is not recommended, it works better with code: show_text(["Hi", "how", "are", "you?"])
export (String) var input_trigger #The action which is used to confirm the next dialog (must be picked from the InputMap)
export (float) var vertical_margin = 35 #Is used to determine the vertical position of the textbox (textbox = the text)
export (float) var horizontal_margin = 10 #Is used to determine the vertical position of the textbox (textbox = the text)
export (Vector2) var textbox_size = Vector2(256, 64) #The size of the text (not the font size, but the size of the whole text)
export (AudioStream) var sound #Is only played when use_visible_characters and play_sound is true; Plays after after every character
export (Font) var font #The font of the text

#misc
var text_instance := preload("text.tscn").instance()
var audio : AudioStreamPlayer
signal input_triggered

func _enter_tree():
	#container for the text
	var container = Container.new()
	container.margin_left = vertical_margin
	container.margin_top = horizontal_margin
	container.margin_right = -vertical_margin
	container.margin_bottom = -horizontal_margin
	container.name = "Container"
	add_child(container)
	#instance the text
	container.add_child(text_instance)
	$Container/text.rect_size = textbox_size
	#set the text font
	if font != null:
		$Container/text.add_font_override("normal_font", font)
	#initalize the sound
	audio = AudioStreamPlayer.new()
	if sound != null:
		audio.set_stream(sound)
	add_child(audio)


func show_text(textarray : Array):
	show()
	var textarray_size = textarray.size()
	for text in textarray:
		$Container/text.set_visible_characters(0)
		$Container/text.set_text(text)
		if use_visible_characters:
			for i in text.length():
				$Container/text.visible_characters += 1
				if sound != null && play_sound:
					audio.play()
				yield(get_tree().create_timer(character_speed/10), "timeout")
		else:
			$Container/text.set_visible_characters(-1)
		if use_input_trigger:
			yield(self, "input_triggered")
	hide()

func _input(event):
	if Input.is_action_just_pressed(input_trigger):
		emit_signal("input_triggered")
