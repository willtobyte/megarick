local ticker = {}
local counters = {}
local count = 0

function ticker.after(ticks, callback)
  count = count + 1
  counters[count] = { target = ticks, current = 0, callback = callback, once = true }
  return count
end

function ticker.every(ticks, callback)
  count = count + 1
  counters[count] = { target = ticks, current = 0, callback = callback, once = false }
  return count
end

function ticker.cancel(timer_id)
  counters[timer_id] = nil
end

function ticker.clear()
  counters = {}
  count = 0
end

function ticker.tick()
  local index = 1
  while index <= count do
    local counter = counters[index]
    if counter then
      counter.current = counter.current + 1
      if counter.current >= counter.target then
        counter.callback()
        if counter.once then
          counters[index] = counters[count]
          counters[count] = nil
          count = count - 1
        else
          counter.current = 0
          index = index + 1
        end
      else
        index = index + 1
      end
    else
      counters[index] = counters[count]
      counters[count] = nil
      count = count - 1
    end
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
