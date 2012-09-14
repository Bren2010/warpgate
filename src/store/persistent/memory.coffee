{_}            = require "UnderscoreKit"
{EventEmitter} = require "events"

exports = module.exports = () ->
  self = new EventEmitter()
  data = {}

  _.bindAll _.extend self,
    get: (key, next) ->
      if not data[key]?
        next "undefined key", false
      else
        self.emit "get:#{key}"
        self.emit "get", key
        next false, data[key]

    set: (key, value, next) ->
      data[key] = value
      self.emit "set:#{key}", value
      self.emit "set", key, value
      next false, true

    remove: (key, next) ->
      if not data[key]?
        next "undefined key", false
      else
        delete data[key]
        self.emit "remove:#{key}"
        self.emit "remove", key
        next false, true