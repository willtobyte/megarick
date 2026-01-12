return {
  on_spawn = function()
    self:subscribe("life", function(life)
      self.visible = life >= self.threshold
    end)
  end
}
