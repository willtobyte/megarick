return {
  on_spawn = function()
    pool.octopus:subscribe("life", function(life)
      self.visible = life >= self.threshold
    end)
  end
}
