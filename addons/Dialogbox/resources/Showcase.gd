extends Node2D

func _ready():
	var dialog := ["Good morning, Sir.[wait] [/wait]I [rainbow freq=0.2 sat=10 val=20][wave amp=50=10][audio pitch=.8 ,]knew[/audio][/wave][/rainbow] you would come. I [rainbow freq=0.2 sat=10 val=20][tornado radius=5 freq=2]knew[/tornado][/rainbow] it",
	 "But something's [color=aqua]wrong[/color] isn't it?", "But that's ok.. [rainbow freq=0.2 sat=10 val=20][fade start=4 length=14]or is it?[/fade][/rainbow]", "Let's hope so!"]
	$Dialogbox.show_text(dialog, [1, 1, 0, 0])
