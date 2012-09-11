{_}            = require "UnderscoreKit"
{EventEmitter} = require "events"

exports = module.exports = () ->
  self = new EventEmitter()
  subscribers = {}
  counts      = {}
  _.bindAll _.extend self,
    get: (id, key, next) ->
      if not subscribers[key]? then subscribers[key] = {}
      if not counts[key]? then counts[key] = 0
      subscribers[key][id] = next
      ++counts[key]
    unget: (id, key) ->
      if subscribers[key][id]? then delete subscribers[key][id]
      if count[key]? and --count[key] is 0
        delete count[key]
        self.emit "unused", key
    deliver: (key, data) ->
      if subscribers[key]?
        _.each subscribers[key], (subscriber) -> subscriber key, data