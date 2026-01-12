local SPEED = 360
local BULLET_VELOCITY = {x = 800, y = 0}

local rand = math.random
local player1 = gamepads[Player.one]
local fire_pressed = false

return {
  on_loop = function(delta)
    local left = keyboard.left or keyboard.a or player1:button(GamepadButton.left)
    local right = keyboard.right or keyboard.d or player1:button(GamepadButton.right)
    local moving = false

    if left then
      self.flip = Flip.horizontal
      self.x = self.x - SPEED * delta
      moving = true
    end

    if right then
      self.flip = Flip.none
      self.x = self.x + SPEED * delta
      moving = true
    end

    if moving and self.action ~= "run" then
      self.action = "run"
    elseif not moving and self.action ~= "idle" then
      self.action = "idle"
    end

    local fire = keyboard.space or player1:button(GamepadButton.a)
    if fire and not fire_pressed then
      fire_pressed = true
      if pool.octopus.life > 0 then
        pool["bomb" .. rand(1, 2)]:play()
        local bullet = pool.bullet()
        bullet.x = self.x + 100
        bullet.y = 740 + rand(-2, 2) * 30
        bullet.action = "default"
        bullet.velocity = BULLET_VELOCITY
      end
    elseif not fire then
      fire_pressed = false
    end
  end
}
