_G.engine = EngineFactory.new()
  :with_title("Mega Rick")
  :with_width(1920)
  :with_height(1080)
  :with_scale(1.0)
  :with_gravity(0)
  :with_fullscreen(true)
  :create()

local scenemanager = engine:scenemanager()

function setup()
  scenemanager:register("wreckedship")
  scenemanager:register("gameover")

  scenemanager:set("wreckedship")
end

function loop() end
