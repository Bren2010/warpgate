{_}            = require "UnderscoreKit"
{EventEmitter} = require "events"
upnode         = require "upnode"

load      = require "load"
ephemeral = load "store/ephemeral/memory"
connector = load "connectors/client"

exports = module.exports = () ->
  remote    = null
  container = ephemeral()
  container.on "change", (key, data) ->
    console.log "Changed: #{key} => #{data}"

  _.bindAll _.extend new EventEmitter(),
    connect: (upstream) ->
      remote = connector _.reduce(upstream, (memo, target) ->
        [host, port] = target.split ":"
        memo[target] = upnode.connect port, host
        memo
      , {})
      remote.on "got", (key, data) -> container.set key, data

    create: (key, data, next) -> remote.create key, data, next

    set: (key, data, next) -> remote.set key, data, next

    get: (key, next) ->
      if container.has key
        [error, node] = container.get key
        next error, node
      else
        remote.get key, next

    remove: (key, next) -> next()

    unref: (key) -> "unref locally"