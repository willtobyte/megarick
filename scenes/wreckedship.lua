local scene = {}

local PLAYER_Y = 834
local rand = math.random

local fire_pressed = false
local bullet_velocity = {x = 800, y = 0}
local zero_velocity = {x = 0, y = 0}

local player1 = gamepads[Player.one]

local function cyclic(list)
  local index = 0
  return setmetatable(list, {
    __call = function(self)
      index = index % #self + 1
      return self[index]
    end
  })
end

local bullets = cyclic({})
local jets = cyclic({})
local explosions = cyclic({})
local segments = {}

function scene.on_enter()
  pool.octopus.x = 1200
  pool.octopus.y = 732
  pool.octopus.action = "idle"

  pool.player.action = "idle"
  pool.player.x = 30
  pool.player.y = PLAYER_Y

  for index = 1, 14 do
    local segment = pool.segment:clone()
    segment.x = 1786 + 16
    segment.y = 220 + 16 + (14 - index) * 14
    segment.z = 1000 + index
    segments[index] = segment
  end

  for index = 1, 3 do
    local bullet = pool.bullet:clone()
    bullet.x = -128
    bullet.y = -128
    bullets[index] = bullet
  end

  for index = 1, 9 do
    local jet = pool.jet:clone()
    jet.x = 3000
    jet.y = 3000
    jets[index] = jet
  end

  for index = 1, 6 do
    local explosion = pool.explosion:clone()
    explosion.x = -128
    explosion.y = -128
    explosions[index] = explosion
  end

  pool.jets = jets
  pool.explosions = explosions
  pool.segments = segments
end

function scene.on_loop(delta)
  player1:open()

  local left = keyboard.left or keyboard.a or player1:button(GamepadButton.left)
  local right = keyboard.right or keyboard.d or player1:button(GamepadButton.right)
  local moving = false

  if left then
    pool.player.flip = Flip.horizontal
    pool.player.x = pool.player.x - 360 * delta
    moving = true
  end

  if right then
    pool.player.flip = Flip.none
    pool.player.x = pool.player.x + 360 * delta
    moving = true
  end

  if moving and pool.player.action ~= "run" then
    pool.player.action = "run"
  elseif not moving and pool.player.action ~= "idle" then
    pool.player.action = "idle"
  end

  local fire = keyboard.space or player1:button(GamepadButton.a)
  if fire and not fire_pressed then
    fire_pressed = true
    if pool.octopus.life > 0 then
      local bullet = bullets()
      bullet.x = pool.player.x + 100
      bullet.y = 740 + rand(-2, 2) * 30
      bullet.action = "default"
      bullet.velocity = bullet_velocity
    end
  elseif not fire then
    fire_pressed = false
  end
end

function scene.on_leave()
  fire_pressed = false
end

ticker.wrap(scene)
sentinel(scene, "wreckedship")

return scene
