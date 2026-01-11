local rand = math.random

return {
  on_collision = function(other_id, other_kind)
    if other_kind ~= "octopus" then
      return
    end

    pool.octopus:damage()
    pool["bomb" .. rand(1, 2)]:play()

    self.action = nil
    self.x = -128
    self.y = -128
    self.velocity = zero_velocity
  end
}
