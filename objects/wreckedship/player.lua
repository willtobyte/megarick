local player = gamepads[Player.one]
local fire_pressed = false

return {
  on_loop = function(delta)
    local left = keyboard.left or keyboard.a or player:button(GamepadButton.left)
    local right = keyboard.right or keyboard.d or player:button(GamepadButton.right)
    local moving = false

    if left then
      self.flip = Flip.horizontal
      self.x = self.x - constants.PLAYER_SPEED * delta
      moving = true
    end

    if right then
      self.flip = Flip.none
      self.x = self.x + constants.PLAYER_SPEED * delta
      moving = true
    end

    if moving and self.action ~= "run" then
      self.action = "run"
    elseif not moving and self.action ~= "idle" then
      self.action = "idle"
    end

    local fire = keyboard.space or player:button(GamepadButton.south)
    if fire and not fire_pressed then
      fire_pressed = true
      if pool.octopus.life > 0 then
        pool["bomb" .. rand(1, 2)]:play()
        local bullet = pool.bullet()
        bullet.x = self.x + constants.PLAYER_BULLET_OFFSET_X
        bullet.y = constants.BULLET_BASE_Y + rand(-2, 2) * constants.BULLET_Y_VARIANCE
        bullet.action = "default"
        bullet.velocity = {x = constants.BULLET_VELOCITY_X, y = 0}
      end
    elseif not fire then
      fire_pressed = false
    end
  end
}
