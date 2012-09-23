{_}            = require "UnderscoreKit"
{EventEmitter} = require "events"

class StoreEphemeralMemory extends EventEmitter
  refs:
    used:   {}
    unused: {}

  constructor: () ->
    _.bindAll this

  has:       (key) -> @hasUsed(key) or @hasUnused(key)
  hasUsed:   (key) -> @refs.used[key]?
  hasUnused: (key) -> @refs.unused[key]?

  get: (key) ->
    @emit "get", key
    if @has key
      if @hasUnused key
        @refs.used[key] = @refs.unused[key]
        delete @refs.unused[key]
      [false, @refs.used[key]]
    else
      ["Attempting to get a node we don't have locally", false]

  set: (key, value) ->
    @emit "set", key, value
    if @hasUsed key
      @refs.used[key] = value
    else
      @refs.unused[key] = value

  unref: (key) ->
    if not @hasUsed key
      false
    else
      @refs.unused[key] = @refs.used[key]
      delete @refs.used[key]
      true

module.exports = StoreEphemeralMemory