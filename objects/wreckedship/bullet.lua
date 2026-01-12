return {
  on_collision = function(other_id, other_kind)
    if other_kind ~= "octopus" then
      return
    end

    pool.octopus:damage()

    self.action = nil
    self.x = constants.DESPAWN_X
    self.y = constants.DESPAWN_Y
    self.velocity = zero_velocity
  end
}
