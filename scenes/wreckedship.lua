local scene = {}

local pool = {}

local fontfactory = engine:fontfactory()
-- local io = Socket.new()
local objectmanager = engine:objectmanager()
local overlay = engine:overlay()
local postalservice = PostalService.new()
local resourcemanager = engine:resourcemanager()
local scenemanager = engine:scenemanager()
local soundmanager = engine:soundmanager()
local statemanager = engine:statemanager()
local timermanager = engine:timermanager()

local bullet_pool = {}
local explosion_pool = {}
local jet_pool = {}
local segment_pool = {}
local keystate = {}
local timer = false

local behaviors = {
	hit = function(self)
		if #explosion_pool > 0 then
			local explosion = table.remove(explosion_pool)
			local offset_x = (math.random(-2, 2)) * 30
			local offset_y = (math.random(-2, 2)) * 30
			explosion.placement = { x = pool.octopus.x + offset_x, y = pool.player.y + offset_y - 200 }
			explosion.action = "default"
			timermanager:singleshot(math.random(100, 400), function()
				if #jet_pool > 0 then
					local jet = table.remove(jet_pool)
					local x = 980
					local base = 812
					local range = 100
					local step = 20
					local y = base + step * math.random(math.floor(-range / step), math.floor(range / step))
					jet.placement = { x, y }
					jet.action = "default"
					jet.velocity.x = -200 * math.random(3, 6)
				end
			end)
		end
		self.action = "attack"
		self.kv:set("life", self.kv:get("life") - 1)
	end,
}

function scene.on_enter()
	pool.online = overlay:create(WidgetType.label)
	pool.online.font = fontfactory:get("fixedsys")
	pool.online:set(1600, 15)

	pool.octopus = scene:get("octopus", SceneType.object)
	pool.octopus.kv:set("life", 16)
	pool.octopus.placement = { x = 1200, y = 732 }
	pool.octopus.action = "idle"
	pool.octopus:on_mail(function(self, message)
		local behavior = behaviors[message]
		if behavior then
			behavior(self)
		end
	end)
	pool.octopus.kv:subscribe("life", function(value)
		if next(segment_pool) then
			local segment = table.remove(segment_pool, 1)
			objectmanager:destroy(segment)
		end
		if value <= 0 then
			pool.octopus.action = "dead"
			if not timer then
				timermanager:singleshot(3000, function()
					scenemanager:set("gameover")
				end)
				timer = true
			end
		end
	end)
	pool.octopus:on_animationfinished(function(self)
		self.action = "idle"
	end)

	pool.player = scene:get("player", SceneType.object)
	pool.player.action = "idle"
	pool.player.placement = { x = 30, y = 834 }

	local segment_matrix = scene:get("segment", SceneType.object)
	for i = 1, 16 do
		local segment = objectmanager:clone(segment_matrix)
		segment.action = "default"
		segment.placement = { x = 1814, y = (i * 12) + 306 }
		table.insert(segment_pool, segment)
	end

	local bullet_matrix = scene:get("bullet", SceneType.object)
	for i = 1, 3 do
		local bullet = objectmanager:clone(bullet_matrix)
		bullet.placement = { x = -128, y = -128 }

		bullet:on_update(function(self)
			if self.x > pool.octopus.x + 256 then
				self.action = nil
				self.placement = { x = -128, y = -128 }
				local inpool = false
				for j = 1, #bullet_pool do
					if bullet_pool[j] == self then
						inpool = true
						break
					end
				end
				if not inpool then
					table.insert(bullet_pool, self)
				end
			end
		end)

		bullet:on_collision("octopus", function(self, other)
			self.action = nil
			self.placement = { x = -128, y = -128 }
			postalservice:post(Mail.new(pool.octopus, self, "hit"))

			local inpool = false
			for j = 1, #bullet_pool do
				if bullet_pool[j] == self then
					inpool = true
					break
				end
			end
			if not inpool then
				table.insert(bullet_pool, self)
			end
		end)
		table.insert(bullet_pool, bullet)
	end

	for i = 1, 9 do
		local explosion = scene:get("explosion", SceneType.object)
		explosion.placement = { x = -128, y = -128 }
		explosion:on_animationfinished(function(self)
			self.action = nil
			self.placement = { x = -128, y = -128 }
			table.insert(explosion_pool, self)
		end)
		table.insert(explosion_pool, explosion)
	end

	for i = 1, 9 do
		local jet = scene:get("jet", SceneType.object)
		jet.placement = { x = 3000, y = 3000 }
		jet:on_collision("player", function(self)
			self.action = nil
			self.placement = { x = 3000, y = 3000 }
			table.insert(jet_pool, self)
		end)
		jet:on_update(function(self)
			if self.x <= -300 then
				self.action = nil
				self.placement = { x = 3000, y = 3000 }
				table.insert(jet_pool, self)
			end
		end)
		table.insert(jet_pool, jet)
	end

	-- io:on("online", function(data)
	-- 	pool.online:set("Online " .. data.clients)
	-- end)
	-- io:connect()
end

function scene.on_loop()
	if statemanager:player(Player.one):on(Controller.left) then
		pool.player.reflection = Reflection.horizontal
		pool.player.velocity.x = -360
	elseif statemanager:player(Player.one):on(Controller.right) then
		pool.player.reflection = Reflection.none
		pool.player.velocity.x = 360
	else
		pool.player.velocity.x = 0
	end

	local action = "run"
	if pool.player.velocity.x == 0 then
		action = "idle"
	end
	pool.player.action = action

	local pressed = statemanager:player(Player.one):on(Controller.south)

	if pressed and not keystate[Controller.south] then
		keystate[Controller.south] = true

		if pool.octopus.kv:get("life") <= 0 then
			return
		end
		if #bullet_pool == 0 then
			return
		end

		local bullet = table.remove(bullet_pool)
		local x = 10 -- pool.player.x -- + pool.player.size.width + 100
		local y = 600 --pool.player.y + 10 + math.random(-2, 2) * 30

		bullet.placement = { x = x, y = y }
		bullet.action = "default"
		bullet.velocity.x = 800

		local sound = "bomb" .. math.random(1, 2)
		local bomb = scene:get(sound, SceneType.effect)
		bomb:play()
	end

	if not pressed then
		keystate[Controller.south] = false
	end
end

function scene.on_leave()
	-- for o in pairs(pool) do
	-- 	pool[o] = nil
	-- end
end

return scene
