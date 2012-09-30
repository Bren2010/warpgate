{_}            = require "UnderscoreKit"
async          = require "async"
{EventEmitter} = require "events"
levelup        = require "levelup"

options =
  createIfMissing: true
  errorIfExists:   false
  encoding:        "json"

class StorePersistentLeveldb extends EventEmitter
  constructor: (@id) ->
    super()
    @_connect @id, _.identity

  _connect: async.memoize (id, next) =>
    levelup "./db#{id}", options, next

  get: (key, next) ->
    @_connect @id, _.pass((level) =>
      level.get key, _.pass((value) =>
        @emit "get:#{key}"
        @emit "get", key
        next false, value
      , next)
    , next)

  set: (key, value, next) ->
    console.log "in set"
    @_connect @id, _.pass((level) =>
      console.log "got leveldb"
      level.put key, value, _.pass(() =>
        console.log "put successful"
        @emit "set:#{key}", value
        @emit "set", key , value
        next false, true
      , next)
    , next)

  remove: (key, next) ->
    @_connect @id, _.pass((level) =>
      level.del key, _.pass(() =>
        @emit "remove:#{key}"
        @emit "remove", key
        next false, true
      , next)
    , next)

module.exports = StorePersistentLeveldb