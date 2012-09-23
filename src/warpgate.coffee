{_}            = require "UnderscoreKit"
{EventEmitter} = require "events"
upnode         = require "upnode"

load      = require "load"
Ephemeral = load "store/ephemeral/memory"
Connector = load "connectors/client"
Item      = load "item"

class Warpgate extends EventEmitter
  remote:    null
  container: null

  constructor: () ->
    _.bindAll this
    @container = new Ephemeral()
    @container.on "set", (key, data) ->
      console.log "Set: #{key} => #{JSON.stringify(data)}"

  connect: _.once (upstream) ->
    @remote = new Connector _.reduce(upstream, (memo, target) ->
      [host, port] = target.split ":"
      memo[target] = upnode.connect port, host
      memo
    , {})
    @remote.on "got", (key, data) =>
      @emit "got", key, data
      @emit "got:#{key}", data
      @container.set key, data

  get: (key, next) ->
    if @container.has key
      [error, value] = @container.get key
      next error, new Item(this, key, value)
    else
      @remote.get key, _.pass((value) =>
        item = new Item(this, key, value)
        next false, item
      , next)

  set: (key, value, next) -> @remote.set key, value, next

  remove: (key, next) -> next()

  unref: (key) -> "unref locally"

module.exports = Warpgate