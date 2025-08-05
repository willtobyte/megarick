local scene = {}

local pool = {}

local resourcemanager = engine:resourcemanager()

local scenemanager = engine:scenemanager()

function scene.on_enter()
	scenemanager:destroy("wreckedship")
end

function scene.on_loop() end

function scene.on_leave()
	for o in pairs(pool) do
		pool[o] = nil
	end
end

return scene
