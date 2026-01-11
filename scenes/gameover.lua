local scene = {}

function scene.on_enter()
  scenemanager:destroy("wreckedship")
end

function scene.on_loop() end

sentinel(scene, "gameover")

return scene
