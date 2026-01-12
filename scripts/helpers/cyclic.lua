return function(items)
  local index = 0
  local length = #items
  return function()
    index = index % length + 1
    return items[index]
  end
end
