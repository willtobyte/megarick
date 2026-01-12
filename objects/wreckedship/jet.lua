return {
  on_loop = function(delta)
    if self.x <= constants.JET_DESPAWN_X then
      self.x = constants.FAR_DESPAWN_X
      self.y = constants.FAR_DESPAWN_Y
      self.velocity = zero_velocity
    end
  end
}
