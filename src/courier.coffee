{_}            = require "UnderscoreKit"
{EventEmitter} = require "events"

exports = module.exports = () ->
  subscribers = {}
  _.bindAll _.extend new EventEmitter(),
    get: (id, key, next) ->
      if not subscribers[key]? then subscribers[key] = {}
      subscribers[key][id] = next
      _.size subscribers[key]
    unget: (id, key) ->
      if subscribers[key]?[id]?
        delete subscribers[key][id]
        if _.size(subscribers[key]) is 0
          delete subscribers[key]
          @emit "unused", key
        true
      else
        false
    deliver: (key, data) ->
      if subscribers[key]?
        _.each subscribers[key], (subscriber) -> subscriber key, data
        _.size subscribers[key]
      else
        0
