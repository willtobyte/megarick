local ticker = {}
local counters = {}
local id = 0
local to_remove = {}
local to_remove_count = 0

function ticker.after(ticks, callback)
  id = id + 1
  counters[id] = { target = ticks, current = 0, callback = callback, once = true }
  return id
end

function ticker.every(ticks, callback)
  id = id + 1
  counters[id] = { target = ticks, current = 0, callback = callback, once = false }
  return id
end

function ticker.cancel(timer_id)
  counters[timer_id] = nil
end

function ticker.clear()
  for key in pairs(counters) do
    counters[key] = nil
  end
  id = 0
end

function ticker.tick()
  to_remove_count = 0
  for tid, counter in pairs(counters) do
    counter.current = counter.current + 1
    if counter.current >= counter.target then
      counter.callback()
      if counter.once then
        to_remove_count = to_remove_count + 1
        to_remove[to_remove_count] = tid
      else
        counter.current = 0
      end
    end
  end
  for index = 1, to_remove_count do
    counters[to_remove[index]] = nil
  end
end

function ticker.wrap(scene)
  local original_on_tick = scene.on_tick
  local original_on_leave = scene.on_leave

  scene.on_tick = function(tick)
    ticker.tick()
    if original_on_tick then
      original_on_tick(tick)
    end
  end

  scene.on_leave = function()
    if original_on_leave then
      original_on_leave()
    end
    ticker.clear()
  end

  return scene
end

return ticker
