{_}            = require "UnderscoreKit"
{EventEmitter} = require "events"

load      = require "load"
ephemeral = load "store/ephemeral/memory"
connector = load "connectors/client"

exports = module.exports = () ->
  _self      = new EventEmitter()
  _remote    = null
  _container = ephemeral()
  _container.on "change", (key, data) ->
    console.log "Changed: #{key} => #{data}"

  _.bindAll _.extend _self,
    connect: (upstream, next) ->
      connector upstream, _.pass((remote) ->
        _remote = remote
        _remote.on "got", (key, data) ->
          _container.set key, data
        next false, true
      , next)

    create: (key, data, next) ->
      _remote.create key, data, next

    set: (key, data, next) ->
      _remote.set key, data, next

    get: (key, next) ->
      if _container.has key
        [error, node] = _container.get key
        next error, node
      else
        _remote.get key, next

    unref: (key) ->
      "unref locally"
