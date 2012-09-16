hashring = require "hashring"
{_}      = require "UnderscoreKit"

module.exports = (streams) ->
  ring = new hashring _.reduce(_.keys(streams), (memo, n) ->
    memo[n] = 2
    memo
  , {})
  _.bindAll _.extend ring,
    route: (method, key, args...) ->
      streams[@getNode(key)] (remote) ->
        remote[method].apply this, [key].concat(args)