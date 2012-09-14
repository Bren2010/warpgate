{_}            = require "UnderscoreKit"
{EventEmitter} = require "events"

load      = require "load"
ephemeral = load "store/ephemeral/memory"
connector = load "connectors/client"

exports = module.exports = () ->
  self      = new EventEmitter()
  remote    = null
  container = ephemeral()
  container.on "change", (key, data) ->
    console.log "Changed: #{key} => #{data}"

  _.bindAll _.extend _self,
    connect: (upstream, next) ->
      connector upstream, _.pass((remote) ->
        remote = remote
        remote.on "got", (key, data) ->
          container.set key, data
        next false, true
      , next)

    create: (key, data, next) ->
      remote.create key, data, next

    set: (key, data, next) ->
      remote.set key, data, next

    get: (key, next) ->
      if _container.has key
        [error, node] = _container.get key
        next error, node
      else
        remote.get key, next

    remove: (key, next) ->
      next()

    unref: (key) ->
      "unref locally"
