randInt = (low, high) ->
  span = high - low
  Math.round(Math.random() * span) + low

randElem = (xs) ->
  idx = randInt 0, xs.length - 1
  xs[idx]

module.exports = {randInt, randElem}
