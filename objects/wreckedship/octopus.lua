local rand = math.random

return {
  on_spawn = function()
    self.life = 14
  end,

  on_damage = function()
    local life = self.life
    if life <= 0 then
      return
    end

    local explosion = pool.explosion()
    explosion.x = self.x + rand(-2, 2) * 30
    explosion.y = pool.player.y + rand(-2, 2) * 30 - 200
    explosion.z = self.z + 1
    explosion.action = "default"

    ticker.after(rand(1, 4), function()
      local jet = pool.jet()
      jet.action = "default"
      jet.x = 980
      jet.y = 812 + 20 * rand(-5, 5)
      jet.velocity = {x = -200 * rand(3, 6), y = 0}
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
    ticker.after(30, function()
      scenemanager:set("gameover")
    end)
  end
}
