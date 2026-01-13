local scene = {}

local bullets = {}
local jets = {}
local explosions = {}
local segments = {}

function scene.on_enter()
  pool.octopus.x = constants.OCTOPUS_X
  pool.octopus.y = constants.OCTOPUS_Y
  pool.octopus.action = "idle"

  pool.player.action = "idle"
  pool.player.x = constants.PLAYER_START_X
  pool.player.y = constants.PLAYER_Y

  pool.segment.threshold = 0

  for index = 1, constants.SEGMENT_COUNT do
    local segment = pool.segment:clone()
    segment.x = constants.SEGMENT_BASE_X
    segment.y = constants.SEGMENT_BASE_Y + (constants.SEGMENT_COUNT - index) * constants.SEGMENT_SPACING
    segment.z = 1000 + index
    segment.threshold = index
    segments[index] = segment
  end

  for index = 1, constants.BULLET_POOL_SIZE do
    local bullet = pool.bullet:clone()
    bullet.x = constants.DESPAWN_X
    bullet.y = constants.DESPAWN_Y
    bullets[index] = bullet
  end

  for index = 1, constants.JET_POOL_SIZE do
    local jet = pool.jet:clone()
    jet.x = constants.FAR_DESPAWN_X
    jet.y = constants.FAR_DESPAWN_Y
    jets[index] = jet
  end

  for index = 1, constants.EXPLOSION_POOL_SIZE do
    local explosion = pool.explosion:clone()
    explosion.x = constants.DESPAWN_X
    explosion.y = constants.DESPAWN_Y
    explosions[index] = explosion
  end

  pool.segments = segments
  pool.bullet = cyclic(bullets)
  pool.jet = cyclic(jets)
  pool.explosion = cyclic(explosions)
end

ticker.wrap(scene)
sentinel(scene, "wreckedship")

return scene
