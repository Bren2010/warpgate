{_}            = require "UnderscoreKit"
async          = require "async"
{EventEmitter} = require "events"
levelup        = require "levelup"

class StorePersistentLeveldb extends EventEmitter
  options:
    createIfMissing: true
    errorIfExists:   false
    encoding:        "json"

  constructor: (@id) ->
    super()
    @_connect _.identity

  _connect: async.memoize (next) ->
    levelup "./db#{@id}", @options, next

  get: (key, next) ->
    @_connect _.pass((level) =>
      level.get key, _.pass((value) =>
        @emit "get:#{key}"
        @emit "get", key
        next false, value
      , next)
    , next)

  set: (key, value, next) ->
    @_connect _.pass((level) =>
      level.put key, value, _.pass(() =>
        @emit "set:#{key}", value
        @emit "set", key , value
        next false, true
      , next)
    , next)

  remove: (key, next) ->
    @_connect _.pass((level) =>
      level.del key, _.pass(() =>
        @emit "remove:#{key}"
        @emit "remove", key
        next false, true
      , next)
    , next)