{_}            = require "UnderscoreKit"
{EventEmitter} = require "events"

exports = module.exports = () ->
  self = new EventEmitter()
  subscribers = {}
  _.bindAll _.extend self,
    get: (id, key, next) ->
      if not subscribers[key]? then subscribers[key] = {}
      subscribers[key][id] = next
      _.size subscribers[key]
    unget: (id, key) ->
      if subscribers[key][id]? then delete subscribers[key][id]
      if _.size(subscribers[key]) is 0
        delete subscribers[key]
        self.emit "unused", key
    deliver: (key, data) ->
      if subscribers[key]?
        _.each subscribers[key], (subscriber) -> subscriber key, data