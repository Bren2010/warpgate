{_}            = require "UnderscoreKit"
{EventEmitter} = require "events"

class StorePersistentMemory extends EventEmitter
  data: {}

  constructor: () ->
    _.bindAll this

  get: (key, next) ->
    if not @data[key]?
      next "undefined key", false
    else
      @emit "get:#{key}"
      @emit "get", key
      next false, @data[key]

  set: (key, value, next) ->
    @data[key] = value
    @emit "set:#{key}", value
    @emit "set", key, value
    next false, true

  remove: (key, next) ->
    if not @data[key]?
      next "undefined key", false
    else
      delete @data[key]
      @emit "remove:#{key}"
      @emit "remove", key
      next false, true

module.exports = StorePersistentMemory