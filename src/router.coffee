HashRing = require "hashring"
{_}      = require "UnderscoreKit"

class Router extends HashRing
  constructor: (@streams) ->
    _.bindAll this
    super _.reduce(_.keys(@streams), (memo, n) ->
      memo[n] = 3
      memo
    , {})

  route: (method, key, args...) ->
    @streams[@getNode key] (remote) =>
      remote[method].apply this, [key].concat(args)

module.exports = Router