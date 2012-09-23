{_}            = require "UnderscoreKit"
{EventEmitter} = require "events"
upnode         = require "upnode"

load      = require "load"
Ephemeral = load "store/ephemeral/memory"
Connector = load "connectors/client"

class Warpgate extends EventEmitter
  remote:    null
  container: null

  constructor: () ->
    @container = new Ephemeral()
    @container.on "change", (key, data) ->
      console.log "Changed: #{key} => #{data}"
    _.bindAll this

  connect: _.once (upstream) ->
    @remote = new Connector _.reduce(upstream, (memo, target) ->
      [host, port] = target.split ":"
      memo[target] = upnode.connect port, host
      memo
    , {})
    @remote.on "got", (key, data) => @container.set key, data

  get: (key, next) ->
    if @container.has key
      [error, node] = @container.get key
      next error, node
    else
      @remote.get key, next

  set: (key, value, next) -> @remote.set key, value, next

  remove: (key, next) -> next()

  unref: (key) -> "unref locally"

module.exports = Warpgate