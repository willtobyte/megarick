local scene = {}

local pool = {}

function scene.on_enter() end

function scene.on_loop() end

function scene.on_leave()
	for o in pairs(pool) do
		pool[o] = nil
	end
end

return scene
