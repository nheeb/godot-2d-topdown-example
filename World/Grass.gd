extends Node2D

# Wenn wir ein Objekt mit dem Skript erstellen wollen, dann müssen wir es vorher auf eine Konstante laden
const GrassEffect = preload("res://Effects/GrassEffect.tscn")

func die():
	# Grass Effekt erstellen
	var grassEffect = GrassEffect.instantiate()
	
	# Der Welt als neues Objekt (child) geben
	var world := get_tree().current_scene
	world.add_child(grassEffect)
	
	# Position des Effekts auf die eigene Position setzen
	grassEffect.global_position = self.global_position
	
	# Grass Büschel löschen
	queue_free()

# Die Funktion wird hier mit dem Signal verbunden
func _on_hurtbox_area_entered():
	die()
