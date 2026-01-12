local scene = {}

function scene.on_enter()
  scenemanager:destroy("wreckedship")
end

sentinel(scene, "gameover")

return scene
