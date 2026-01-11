return {
  on_loop = function(delta)
    if self.x <= -300 then
      self.x = 3000
      self.y = 3000
      self.velocity = {x = 0, y = 0}
    end
  end
}
