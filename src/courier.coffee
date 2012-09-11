{_}            = require "UnderscoreKit"
{EventEmitter} = require "events"

exports = module.exports = () ->
  _self = new EventEmitter()
  _subscribers = {}
  _counts      = {}
  _.bindAll _.extend _self,
    get: (id, key, next) ->
      if not _subscribers[key]? then _subscribers[key] = {}
      if not _counts[key]? then _counts[key] = 0
      _subscribers[key][id] = next
      ++_counts[key]
    unget: (id, key) ->
      if _subscribers[key][id]? then delete _subscribers[key][id]
      if _count[key]? and --_count[key] is 0
        delete _count[key]
        _self.emit "unused", key
    deliver: (key, data) ->
      if _subscribers[key]?
        _.each _subscribers[key], (subscriber) -> subscriber key, data