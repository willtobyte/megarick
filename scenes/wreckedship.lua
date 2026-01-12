local scene = {}

local PLAYER_Y = 834

local bullets = {}
local jets = {}
local explosions = {}
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

  pool.bullets = bullets
  pool.jets = jets
  pool.explosions = explosions
  pool.segments = segments
end

ticker.wrap(scene)
sentinel(scene, "wreckedship")

return scene
