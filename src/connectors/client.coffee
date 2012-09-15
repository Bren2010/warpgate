{EventEmitter} = require "events"
{_}            = require "UnderscoreKit"
upnode         = require "upnode"
hashring       = require "hashring"

load   = require "load"
router_gen = load "router"

exports = module.exports = (upstream, next) ->
  self   = new EventEmitter();
  queue  = {}

  fetchIsQueued = (key) -> queue[key]? and queue[key].length

  queueCallback = (key, next) ->
    if queue[key]?
      queue[key].push next
    else
      queue[key] = [next]

  createQueueRunner = (key) -> (error, data) ->
    self.emit "got", key, data
    self.emit "got:#{key}", data
    if queue[key]?
      callbacks = queue[key]
      delete queue[key]
      next error, data for next in callbacks

  router = router_gen upstream
  _.bindAll _.extend self,
    get: (key, next) ->
      if not fetchIsQueued key
        router.route "get", key, createQueueRunner key
      queueCallback key, next

    set: (key, data, next) ->
      router.route "set", key, data, next

    unget: (key, next) -> router.route "unget", key, next

    remove: (key, next) -> router.route "remove", key, next