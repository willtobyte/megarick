local scene = {}

local pool, bullets, bullet_pool, explosion_pool, jet_pool, segment_pool, keystate = {}, {}, {}, {}, {}, {}, {}
local timer = false

local OFF_BULLET   = { x = -128,  y = -128  }
local OFF_JET      = { x = 3000,  y = 3000  }
local JET_OFF_X    = -300
local PLAYER_Y     = 834
local FIRE_Y_BASE  = 740
local FIRE_Y_STEP  = 30
local rand         = math.random

local active_bullets, active_jets = {}, {}

local function remove_from(list, item)
  for i = #list, 1, -1 do
    if list[i] == item then
      table.remove(list, i)
      return true
    end
  end
end

local function push_unique(list, item)
  for i = 1, #list do
    if list[i] == item then return end
  end
  list[#list + 1] = item
end

local function deactivate(obj, off)
  obj.action = nil
  obj.placement = off
  if obj.velocity and obj.velocity.x then obj.velocity.x = 0 end
end

local behaviors = {
  hit = function(self)
    if #explosion_pool > 0 then
      local explosion = table.remove(explosion_pool)
      local offset_x = rand(-2, 2) * 30
      local offset_y = rand(-2, 2) * 30
      explosion.placement = { x = pool.octopus.x + offset_x, y = pool.player.y + offset_y - 200 }
      explosion.action = "default"

      timermanager:singleshot(rand(100, 400), function()
        if #jet_pool == 0 then return end
        local jet = table.remove(jet_pool)
        local x = 980
        local base = 812
        local range = 100
        local step = 20
        local y = base + step * rand(math.floor(-range / step), math.floor(range / step))
        jet.action = "default"
        jet.placement = { x, y }
        jet.velocity = { x = -200 * rand(3, 6) }
        push_unique(active_jets, jet)
      end)
    end

    self.action = "attack"
    self.life = self.life.value - 1
  end,
}

function scene.on_enter()
  pool.octopus = scene:get("octopus", SceneType.object)
  pool.octopus.life = 14
  pool.octopus.placement = { x = 1200, y = 732 }
  pool.octopus.action = "idle"
  pool.octopus:on_mail(function(self, message)
    local behavior = behaviors[message]
    if behavior then behavior(self) end
  end)

  pool.octopus.life:subscribe(function(value)
    if next(segment_pool) then
      local segment = table.remove(segment_pool, 1)
      objectmanager:remove(segment)
    end
    if value > 0 then return end
    pool.octopus.action = "dead"
    if timer then return end
    timermanager:singleshot(3000, function()
      scenemanager:set("gameover")
    end)
    timer = true
  end)

  pool.player = scene:get("player", SceneType.object)
  pool.player.action = "idle"
  pool.player.placement = { x = 30, y = PLAYER_Y }

  local segment_matrix = scene:get("segment", SceneType.object)
  for i = 1, 14 do
    local segment = objectmanager:clone(segment_matrix)
    segment.action = "default"
    segment.placement = { x = 1802, y = (i * 14) + 222 }
    segment_pool[#segment_pool + 1] = segment
  end

  local bullet_matrix = scene:get("bullet", SceneType.object)
  for i = 1, 3 do
    local b = objectmanager:clone(bullet_matrix)
    b.placement = OFF_BULLET

    b:on_collision("octopus", function(self)
      deactivate(self, OFF_BULLET)
      postalservice:post(Mail.new(pool.octopus, self, "hit"))
      remove_from(active_bullets, self)
      push_unique(bullet_pool, self)
    end)

    bullet_pool[#bullet_pool + 1] = b
    bullets[#bullets + 1] = b
  end

  for i = 1, 9 do
    local explosion = scene:get("explosion", SceneType.object)
    explosion.placement = OFF_BULLET
    explosion:on_end(function(self)
      deactivate(self, OFF_BULLET)
      explosion_pool[#explosion_pool + 1] = self
    end)
    explosion_pool[#explosion_pool + 1] = explosion
  end

  for i = 1, 9 do
    local jet = scene:get("jet", SceneType.object)
    jet.placement = OFF_JET
    jet:on_collision("player", function(self)
      deactivate(self, OFF_JET)
      remove_from(active_jets, self)
      jet_pool[#jet_pool + 1] = self
    end)
    jet_pool[#jet_pool + 1] = jet
  end
end

function scene.on_loop()
  if statemanager:player(Player.one):on(Controller.left) then
    pool.player.reflection = Reflection.horizontal
    pool.player.velocity = { x = -360 }
  end
  if statemanager:player(Player.one):on(Controller.right) then
    pool.player.reflection = Reflection.none
    pool.player.velocity = { x = 360 }
  end
  if not (statemanager:player(Player.one):on(Controller.left) or statemanager:player(Player.one):on(Controller.right)) then
    pool.player.velocity = { x = 0 }
  end

  pool.player.action = (pool.player.velocity.x == 0) and "idle" or "run"

  local pressed = statemanager:player(Player.one):on(Controller.south)
  if pressed and not keystate[Controller.south] then
    keystate[Controller.south] = true
    if pool.octopus.life.value <= 0 then return end
    if #bullet_pool == 0 then return end

    local bullet = table.remove(bullet_pool)
    local x = pool.player.x + 100
    local y = FIRE_Y_BASE + rand(-2, 2) * FIRE_Y_STEP
    bullet.placement = { x = x, y = y }
    bullet.action = "default"
    bullet.velocity = { x = 800 }
    push_unique(active_bullets, bullet)

    local sound = "bomb" .. rand(1, 2)
    local sfx = scene:get(sound, SceneType.effect)
    sfx:play()
  end
  if not pressed then keystate[Controller.south] = false end

  for i = #active_bullets, 1, -1 do
    local b = active_bullets[i]
    if b.x > pool.octopus.x + 256 then
      deactivate(b, OFF_BULLET)
      table.remove(active_bullets, i)
      push_unique(bullet_pool, b)
    end
  end

  for i = #active_jets, 1, -1 do
    local j = active_jets[i]
    if j.x <= JET_OFF_X then
      deactivate(j, OFF_JET)
      table.remove(active_jets, i)
      jet_pool[#jet_pool + 1] = j
    end
  end
end

function scene.on_leave()
  timer = nil

  local function clear(t)
    for i = #t, 1, -1 do t[i] = nil end
  end

  clear(active_bullets)
  clear(active_jets)
  clear(bullets)
  clear(bullet_pool)
  clear(explosion_pool)
  clear(jet_pool)
  clear(segment_pool)

  for key in next, keystate do
    keystate[key] = nil
  end
  for key in next, pool do
    pool[key] = nil
  end
end

sentinel(scene, "wreckedship")

return scene
