hashring = require "hashring"
{_}      = require "UnderscoreKit"

module.exports = (streams) ->
  ring = new hashring _.keys streams
  _.bindAll _.extend
    route: (method, key, args...) ->
      streams[ring.getNode(key)] (remote) ->
        remote[method].apply this, [key].concat(args)