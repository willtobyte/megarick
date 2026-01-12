return {
  on_spawn = function()
    self.life = constants.OCTOPUS_LIFE
  end,

  on_damage = function()
    local life = self.life
    if life <= 0 then
      return
    end

    local explosion = pool.explosion()
    explosion.x = self.x + rand(-2, 2) * constants.EXPLOSION_OFFSET_VARIANCE
    explosion.y = pool.player.y - constants.EXPLOSION_Y_OFFSET + rand(-2, 2) * constants.EXPLOSION_OFFSET_VARIANCE
    explosion.z = self.z + 1
    explosion.action = "default"

    ticker.after(rand(1, 4), function()
      local jet = pool.jet()
      jet.action = "default"
      jet.x = constants.JET_START_X
      jet.y = constants.JET_BASE_Y + rand(-5, 5) * 20
      jet.velocity = {x = -rand(constants.JET_VELOCITY_MIN, constants.JET_VELOCITY_MAX), y = 0}
    end)

    self.action = "attack"
    local new_life = life - 1
    self.life = new_life

    for _, segment in ipairs(pool.segments) do
      segment.life = new_life
    end

    if new_life > 0 then
      return
    end

    self.action = "dead"
    ticker.after(constants.GAMEOVER_DELAY, function()
      scenemanager:set("gameover")
    end)
  end
}
