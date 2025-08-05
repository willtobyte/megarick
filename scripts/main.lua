_G.engine = EngineFactory.new()
	:with_title("Mega Rick")
	:with_width(1920)
	:with_height(1080)
	:with_scale(1.0)
	:with_gravity(0)
	:with_fullscreen(false)
	:create()

function setup()
	local resourcemanager = engine:resourcemanager()

	local scenemanager = engine:scenemanager()

	resourcemanager:prefetch({
		"blobs/bomb1.ogg",
		"blobs/bomb2.ogg",
		"blobs/box.png",
		"blobs/bullet.png",
		"blobs/candle.png",
		"blobs/explosion.png",
		"blobs/healthbar.png",
		"blobs/jet.png",
		"blobs/octopus.png",
		"blobs/player.png",
		"blobs/princess.png",
		"blobs/segment.png",
	})

	scenemanager:register("ship")
	scenemanager:register("gameover")

	scenemanager:set("ship")
end

function loop() end
