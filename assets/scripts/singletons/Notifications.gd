extends CanvasLayer

var warning_texture := preload("res://assets/scripts/singletons/notifs/warninghd.pmg.png")
var notif_fade : PackedScene = preload("res://assets/scripts/singletons/notifs/notif_fade.tscn")
var notif_warn : PackedScene = preload("res://assets/scripts/singletons/notifs/notif_warn.tscn")
var notif_click : PackedScene = preload("res://assets/scripts/singletons/notifs/notif_click.tscn")
@onready var hud_positions = [$Notifications/Margins/topleft_notifs, $Notifications/Margins/topcenter_notifs, $Notifications/Margins/topright_notifs, $Notifications/Margins/bottomleft_notifs, $Notifications/Margins/bottomcenter_notifs, $Notifications/Margins/bottomright_notifs]
