"""
To properly use the plugin consider reading the wiki(https://github.com/Schweini07/Dialogbox/wiki) 
or read the comments above the variables.

This plugin is still under development, so if you have any issues with this plugin or have an enhancment, 
consider opening an issue on the Github repo: 
https://github.com/Schweini07/Dialogbox

Also feel free to use the font, the sound and the textbox from the resources folder.

# sound and textbox
Those two resource are made by me and are under no liscense, you can use it for non- and commercial products.

# font
The font is the SuperLegendBody font 
('res://addons/Dialogbox/resources/SuperLegendBoy-4w8Y.ttf') -> Free for non-commercial use,
you have to buy a liscense for commercial use. Website: https://www.dafont.com/de/super-legend-boy.font

There is also a Showcase scene in the resource folder with which you can experiment with the plugin.

plugin = Dialogbox
author= Laurenz Reinthaler
version = "0.2"
"""


tool
class_name Dialogbox, "node_icon.png"
extends NinePatchRect

#Signals

# Is emitted when all the characters (letters) of a dialog are visible
signal dialog_finished
# Is emitted when the input input_trigger is triggered
signal input_triggered
# Is emitted when all dialogs were shown
signal finished

# Properties

# Bool Properties

# If set true, the characters (letters) show up with the speed determined trough the speed property
export (bool) var use_visible_characters = true setget set_visible_characters_usage, is_visible_characters_usage
# If set true, after the end of every dialog, the plugin waits for the input_trigger action
export (bool) var use_input_trigger = true
# If set true, the text can be sped up with the input_speedup action
export (bool) var use_speedup = true
# If set true, the sound will play after every character that showed up
export (bool) var play_sound = true

# Dialogs

# Works similar to show_text() but is used in the editor and can't use character frames
export (Array, String, MULTILINE) var text

# Input Properties

# The action which is used to confirm the next dialog (must be picked from the InputMap as a string)
export (String) var input_trigger
# The action that lets you speed up the text
export (String) var input_speedup

# Speed Properties

# Determines how fast the text can be sped up with input_speedup
export (float) var speedup_speed = 1
# Determines how fast the characters (letters) will show up.
export (float) var character_speed = 1

# Vector2 Properties

# Is used to determine the position of the textbox (textbox = the text)
export (Vector2) var text_margin = Vector2(35, 10)
# The size of the text (not the font size, but the size of the whole text)
export (Vector2) var textbox_size = Vector2(256, 64)

# Resource Properties

# Is only played when use_visible_characters and play_sound is true; Plays after after every character
export (AudioStream) var sound
# The font of the text
export (Font) var font

# Character Frame Properties

# A frame where you can see the characters expressions
export (bool) var use_character_frame = false
# If set true, the character frame will be located on the left side
export (bool) var change_frame_side = false
# Here you can set the textures of the character frame. For more information look up the wiki: https://github.com/Schweini07/Dialogbox/wiki
export (Array, Texture) var frame_textures

# misc

# Preloads

# the instance of the text when use_character_frame is set to false
var text_instance := preload("text.tscn").instance()
# the instance of the HSplitContainer when use_character_frame is set to true
var hsplit_instance := preload("HSplitContainer.tscn").instance()

# Referencess

# the RichTextLabel node which is used to show text
var text_node : RichTextLabel
# the TextureRect where character_frames are shown
var character_frame : TextureRect
# the AudioStreamPlayer which plays 'sound', an AudioStream
var audio : AudioStreamPlayer

# custom BBCode effects

# the richtexteffect 'richtextwait'
var richtextwait = RichTextWait.new()

# the richtexteffect 'richtextpitch'
var richtextpitch = RichTextPitch.new()

# the pitch of the AudioStreanPlayer 'audio'
var audio_pitch : float = 1.0 setget set_audio_pitch, get_audio_pitch

"""
Basic Functions
"""

func _enter_tree() -> void: # create dialogbox
	# set variable descriptions
	#speedup_speed.set_meta("editor_description", "Dt")
	
	# container for the text
	var container = Container.new()
	# set the layout to full_rect
	container.anchor_right = 1
	container.anchor_bottom = 1
	
	# set the margin exactly how the user wants it to
	container.margin_right = -text_margin.x
	container.margin_bottom = -text_margin.y
	container.margin_left = text_margin.x
	container.margin_top = text_margin.y
	
	# name the container as if not, its default name would be something like: @@1
	container.name = "Container"
	# add the container to the scene tree
	add_child(container)
	
	# check if the user wants to use the character frame
	if use_character_frame:
		# if he wants to use it this scene is instanced. 
		# this was neccessary as I couldn't get it to work just with creating objects
		container.add_child(hsplit_instance)
		
		# here we're referencing two important nodes
		text_node = $Container/HSplitContainer/text
		character_frame = $Container/HSplitContainer/frame
		
		# if the user want's to have the frame on the left side
		# for this the frame node is moved up in the scene tree
		if change_frame_side:
			$Container/HSplitContainer.move_child(character_frame, 0)
	# if the user doesn't want to use the character frame
	else:
		# instance the text
		container.add_child(text_instance)
		
		# reference the text node
		text_node = $Container/text
		# this is necessary as there is no HSplitContainer setting the size of
		# the text like we see in HSplitContainer.tscn
		text_node.rect_size = textbox_size
	
	# set custom effects
	text_node.install_effect(richtextwait)
	text_node.install_effect(richtextpitch)
	
	# set the text font
	if font != null:
		text_node.add_font_override("normal_font", font)
		
	# initalize the sound
	audio = AudioStreamPlayer.new()
	
	# check if the user set a sound
	if sound != null:
		audio.set_stream(sound)
	
	# name the audiostreamplayer
	audio.name = "sound"
	# and add it to the scene tree
	add_child(audio)
	
	# make the text which was set in the inspector visible when the game started
	if text.size() > 0 && !Engine.editor_hint:
		show_text(text)
	else:
		# make the text which was set in the inspector, visible in the editor
		if text.size() <= 0:
			return
		text_node.set_bbcode(text[0])
		
		# make the character frame which was set in the inspector, visible in the editor
		if use_character_frame:
			character_frame.texture = frame_textures[0]

func show_text(textarray : Array, framearray : Array = [0]) -> void: # the show_text function
	# make the box visible
	show()
	
	# variables for the character frame to function
	var frame_array_count := -1
	var frame_count : int
	
	# the loop for showing the text
	for text in textarray:
		# set the text
		text_node.set_bbcode(text)
		
		# check if the character frame is used and then set the texture
		if use_character_frame:
			frame_array_count += 1
			frame_count = framearray[frame_array_count]
			character_frame.texture = frame_textures[frame_count]
		
		
		# check if use_visible_characters is true, then make the text show up
		if use_visible_characters:
			# yield a frame, as when not done, get_total_character_count() won't work
			yield(get_tree(), "idle_frame")
			
			# set the visible characters to 0, so no characters (letters) are shown
			text_node.set_visible_characters(0)
			
			for i in text_node.get_total_character_count():
				if richtextwait.wait:
					yield(get_tree().create_timer(richtextwait.time), "timeout")
					richtextwait.wait = false
				
				# set visible_character += 1, so a character (letter) shows up
				text_node.visible_characters += 1
				
				# check if there's a sound assigned and if it should play
				if play_sound:
					if richtextpitch.into_block:
						audio.pitch_scale = richtextpitch.pitch
					audio.play()
				
				# check if the user wants to speed the dialog up, then speed it up with speedup_speed
				if Input.is_action_pressed(input_speedup) and use_speedup:
					yield(get_tree().create_timer(speedup_speed/50), "timeout")
				# if not, speed it up with the character_speed speed
				else:
					yield(get_tree().create_timer(character_speed/10), "timeout")
				
				audio.pitch_scale = 1
		
			# stop the audio for the sound
			audio.stop()
		
		# the dialog is finshed ow, emit the signal
		emit_signal("dialog_finished")
		
		# if use input_trigger is set true, wait until it's triggered
		if use_input_trigger:
			yield(self, "input_triggered")
		#if not wait a sceond and proceed
		else:
			# change the numer in create_timer(), if you don't want it to be 1 second
			yield(get_tree().create_timer(1), "timeout")
	
	
	# hide the Box
	hide()
	
	# and finally, emit the signal that we're finished
	emit_signal("finished")

func _input(event) -> void: # input function to know, when the user wants to see the next dialog
	if Input.is_action_just_pressed(input_trigger):
		emit_signal("input_triggered")

func _exit_tree() -> void: # remove the childs of the dialogbox
	$Container.queue_free()

"""
Setters and Getters
"""

func set_visible_characters_usage(value : bool) -> void:
	use_visible_characters = value

func is_visible_characters_usage() -> bool:
	return use_visible_characters

func set_audio_pitch(value : float) -> void:
	audio.pitch_scale = value

func get_audio_pitch() -> float:
	return audio.pitch_scale
