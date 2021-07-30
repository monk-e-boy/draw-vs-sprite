extends Node2D

# Icons made by <a href="https://www.flaticon.com/authors/pixel-perfect" title="Pixel perfect">Pixel perfect</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a>

var DRAW_CIRCLES	= 1
var DRAW_FLAKES		= DRAW_CIRCLES	+ 1
var DRAW_SQUARES	= DRAW_FLAKES	+ 1
var SPRITES			= DRAW_SQUARES	+ 1
var mode			= DRAW_CIRCLES

#
# PLAY WITH THIS NUMBER:
#
var max_flakes = 6400
#
#
#

var positions = PoolVector2Array()
var speeds = PoolVector2Array()
var smiles = []
var rng = RandomNumberGenerator.new()

# GODOT signals are the greatest thing ever
signal mode_changed(mode)

func rand_pos_vec():
	# RANDOM x position
	var x = rng.randi_range(10, OS.get_window_size().x - 20)
	return Vector2(x, -10)


func rand_speed_vec():
	# RANDOM speed between 7 and 13, more likely to around 10
	var minimum = 0.9
	var maximum = 4.123
	var y = \
		rng.randf_range(minimum, maximum) + \
		rng.randf_range(minimum, maximum) + \
		rng.randf_range(minimum, maximum) / \
		3.0
		# ^ weird syntax soz
	
	return Vector2(0.0, y)


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	for i in range(max_flakes):
		positions.append(rand_pos_vec())
		speeds.append(rand_speed_vec())
		
	# Duplicate our sprite and give it a random rotation
	for i in range(max_flakes):
		var f = $Sprite.duplicate()
		#f.position = Vector2(10 + i*2, 10)
		f.rot = rng.randf_range(-0.05, 0.05)
		self.add_child(f)


func _process(delta):
	OS.set_window_title("FPS: " + str(Engine.get_frames_per_second()))
	update()


func draw_flake(index):
	var pos = positions[index]
	if mode == DRAW_CIRCLES:
		draw_circle( pos, 10, Color(1,1,1))
		
	elif mode == DRAW_SQUARES:
		draw_rect(Rect2(pos-Vector2(5,5), Vector2(10,10)), Color(1,1,1))
		
	elif mode == DRAW_FLAKES:
		var tmp = Vector2(0,10)
		draw_line(pos - tmp, pos + tmp, Color(1,1,1))
		tmp = tmp.rotated(deg2rad(360.0/3.0))
		draw_line(pos - tmp, pos + tmp, Color(1,1,1))
		tmp = tmp.rotated(deg2rad(360.0/3.0))
		draw_line(pos - tmp, pos + tmp, Color(1,1,1))
		
	elif mode == SPRITES:
		var c = self.get_child(index+1)
		c.visible = true
		c.position = pos


func _draw():
	for i in len(positions):
		draw_flake(i)
		positions[i] += speeds[i]
		if positions[i].y > OS.get_window_size().y + 10:
			positions[i] = rand_pos_vec()


func _on_Button_pressed():
	mode += 1
	if mode == SPRITES+1:
		mode = DRAW_CIRCLES
		
	for i in len(positions):
		var c = self.get_child(i+1)
		c.visible = mode == SPRITES
	
	if mode == SPRITES:
		emit_signal("mode_changed", "Sprites")
		
	if mode == DRAW_CIRCLES:
		emit_signal("mode_changed", "Circles")
		
	if mode == DRAW_FLAKES:
		emit_signal("mode_changed", "Flakes")
		
	if mode == DRAW_SQUARES:
		emit_signal("mode_changed", "Squares")
