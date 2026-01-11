local rand = math.random

return {
  on_spawn = function()
    self.life = 14
  end,

  on_damage = function()
    if self.life <= 0 then
      return
    end

    local explosion = pool.explosions()
    explosion.x = self.x + rand(-2, 2) * 30
    explosion.y = pool.player.y + rand(-2, 2) * 30 - 200
    explosion.action = "default"

    ticker.after(rand(1, 4), function()
      local jet = pool.jets()
      jet.action = "default"
      jet.x = 980
      jet.y = 812 + 20 * rand(-5, 5)
      jet.velocity = {x = -200 * rand(3, 6), y = 0}
    end)

    self.action = "attack"
    self.life = self.life - 1

    local segment = pool.segments[self.life + 1]
    if segment then
      segment.visible = false
    end

    if self.life > 0 then
      return
    end

    self.action = "dead"
    ticker.after(30, function()
      scenemanager:set("gameover")
    end)
  end
}
