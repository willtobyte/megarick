---@diagnostic disable: undefined-global, undefined-field, lowercase-global
_G.engine             = EngineFactory.new()
    :with_title("Mega Rick")
    :with_width(1920)
    :with_height(1080)
    :with_scale(1.0)
    :with_gravity(0)
    :with_fullscreen(false)
    :create()

local objectmanager   = engine:objectmanager()
local fontfactory     = engine:fontfactory()
local io              = Socket.new()
local overlay         = engine:overlay()
local postalservice   = PostalService.new()
local resourcemanager = engine:resourcemanager()
local scenemanager    = engine:scenemanager()
local soundmanager    = engine:soundmanager()
local statemanager    = engine:statemanager()
local timermanager    = engine:timermanager()

local candle1
local candle2
local healthbar
local octopus
local princess
local player
local online

local bullet_pool     = {}
local explosion_pool  = {}
local jet_pool        = {}
local segment_pool    = {}
local keystate        = {}
local timer           = false

math.randomseed(os.time())

local behaviors = {
  hit = function(self)
    if #explosion_pool > 0 then
      local explosion = table.remove(explosion_pool)
      local offset_x  = (math.random(-2, 2)) * 30
      local offset_y  = (math.random(-2, 2)) * 30
      explosion.placement:set(octopus.x + offset_x, player.y + offset_y - 200)
      explosion.action:set("default")
      timermanager:singleshot(math.random(100, 400), function()
        if #jet_pool > 0 then
          local jet   = table.remove(jet_pool)
          local x     = 980
          local base  = 812
          local range = 100
          local step  = 20
          local y = base + step * math.random(math.floor(-range / step), math.floor(range / step))
          jet.placement:set(x, y)
          jet.action:set("default")
          jet.velocity.x = -200 * math.random(3, 6)
        end
      end)
    end
    self.action:set("attack")
    self.kv:set("life", self.kv:get("life") - 1)
  end
}

function setup()
  resourcemanager:prefetch({
    "blobs/bomb1.ogg",
    "blobs/bomb2.ogg",
    "blobs/box.png",
    "blobs/bullet.png",
    "blobs/candle.png",
    "blobs/explosion.png",
    "blobs/gameover.png",
    "blobs/healthbar.png",
    "blobs/jet.png",
    "blobs/octopus.png",
    "blobs/player.png",
    "blobs/princess.png",
    "blobs/segment.png",
    "blobs/ship.png"
  })

  online = overlay:create(WidgetType.label)
  online.font = fontfactory:get("fixedsys")
  online:set("", 1600, 15)

  candle1 = objectmanager:create("candle")
  candle1.placement:set(60, 100)
  candle1.action:set("default")

  candle2 = objectmanager:create("candle")
  candle2.placement:set(1800, 100)
  candle2.action:set("default")

  octopus = objectmanager:create("octopus")
  octopus.kv:set("life", 16)
  octopus.placement:set(1200, 622)
  octopus.action:set("idle")
  octopus:on_mail(function(self, message)
    local behavior = behaviors[message]
    if behavior then
      behavior(self)
    end
  end)
  octopus.kv:subscribe("life", function(value)
    if next(segment_pool) then
      local segment = table.remove(segment_pool, 1)
      objectmanager:destroy(segment)
    end
    if value <= 0 then
      octopus.action:set("dead")
      if not timer then
        timermanager:singleshot(3000, function()
          local function destroy_pool(pool)
            while #pool > 0 do
              local o = table.remove(pool)
              if o then
                objectmanager:destroy(o)
              end
            end
          end

          destroy_pool(bullet_pool)
          destroy_pool(explosion_pool)
          destroy_pool(jet_pool)
          destroy_pool(segment_pool)

          objectmanager:destroy(octopus)
          octopus = nil

          objectmanager:destroy(healthbar)
          healthbar = nil

          objectmanager:destroy(player)
          player = nil

          objectmanager:destroy(princess)
          princess = nil

          objectmanager:destroy(candle1)
          candle1 = nil

          objectmanager:destroy(candle2)
          candle2 = nil

          overlay:destroy(online)
          online = nil

          scenemanager:set("gameover")

          collectgarbage("collect")

          resourcemanager:flush()
        end)
        timer = true
      end
    end
  end)
  octopus:on_animationfinished(function(self)
    self.action:set("idle")
  end)

  princess = objectmanager:create("princess")
  princess.action:set("default")
  princess.placement:set(1600, 806)

  player = objectmanager:create("player")
  player.action:set("idle")
  player.placement:set(30, 794)

  healthbar = objectmanager:create("healthbar")
  healthbar.action:set("default")
  healthbar.placement:set(1798, 300)

  for i = 1, 16 do
    local segment = objectmanager:create("segment")
    segment.action:set("default")
    segment.placement:set(1814, (i * 12) + 306)
    table.insert(segment_pool, segment)
  end

  for i = 1, 3 do
    local bullet = objectmanager:create("bullet")
    bullet.placement:set(-128, -128)

    bullet:on_update(function(self)
      if self.x > octopus.x + 256 then
        self.action:unset()
        self.placement:set(-128, -128)
        local inpool = false
        for j = 1, #bullet_pool do
          if bullet_pool[j] == self then
            inpool = true
            break
          end
        end
        if not inpool then
          table.insert(bullet_pool, self)
        end
      end
    end)

    bullet:on_collision("octopus", function(self, other)
      self.action:unset()
      self.placement:set(-128, -128)
      postalservice:post(Mail.new(octopus, self, "hit"))

      local inpool = false
      for j = 1, #bullet_pool do
        if bullet_pool[j] == self then
          inpool = true
          break
        end
      end
      if not inpool then
        table.insert(bullet_pool, self)
      end
    end)
    table.insert(bullet_pool, bullet)
  end

  for i = 1, 9 do
    local explosion = objectmanager:create("explosion")
    explosion.placement:set(-128, -128)
    explosion:on_animationfinished(function(self)
      self.action:unset()
      self.placement:set(-128, -128)
      table.insert(explosion_pool, self)
    end)
    table.insert(explosion_pool, explosion)
  end

  for i = 1, 9 do
    local jet = objectmanager:create("jet")
    jet.placement:set(3000, 3000)
    jet:on_collision("player", function(self)
      self.action:unset()
      self.placement:set(3000, 3000)
      table.insert(jet_pool, self)
    end)
    jet:on_update(function(self)
      if self.x <= -300 then
        self.action:unset()
        self.placement:set(3000, 3000)
        table.insert(jet_pool, self)
      end
    end)
    table.insert(jet_pool, jet)
  end

  io:on("online", function(data)
    online:set("Online " .. data.clients)
  end)
  io:connect()

  scenemanager:set("ship")
end

function loop()
  if not player then
    return
  end

  player.velocity.x = 0

  if statemanager:player(Player.one):on(Controller.left) then
    player.reflection:set(Reflection.horizontal)
    player.velocity.x = -360
  elseif statemanager:player(Player.one):on(Controller.right) then
    player.reflection:unset()
    player.velocity.x = 360
  end

  player.action:set(player.velocity.x ~= 0 and "run" or "idle")

  if statemanager:player(Player.one):on(Controller.cross) then
    if not keystate[Controller.cross] then
      keystate[Controller.cross] = true
      if octopus.kv:get("life") <= 0 then
        return
      end
      if #bullet_pool > 0 then
        local bullet = table.remove(bullet_pool)
        local x = (player.x + player.size.width) + 100
        local y = player.y + 10
        local offset_y = (math.random(-2, 2)) * 30
        bullet.placement:set(x, y + offset_y)
        bullet.action:set("default")
        bullet.velocity.x = 800
        local sound = "bomb" .. math.random(1, 2)
        soundmanager:play(sound)
      end
    end
  else
    keystate[Controller.cross] = false
  end
end

function run()
  engine:run()
end
