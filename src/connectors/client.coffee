{EventEmitter} = require "events"
{_}            = require "UnderscoreKit"
async          = require "async"
upnode         = require "upnode"
hashring       = require "hashring"

load   = require "load"
Router = load "router"

Queue = (self, router) ->
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

  (key, next) ->
    if not fetchIsQueued key
      router.route "get", key, createQueueRunner key
    queueCallback key, next

class ConnectorClient extends EventEmitter
  router: null
  queue:  {}

  constructor: (upstream) ->
    @router = new Router upstream
    @queue  = Queue this, @router
    _.bindAll this

  get: (key, next) ->
    @queue key, next

  set: (key, value, next) ->
    @router.route "set", key, value, next

  unget: (key, next) ->
    @router.route "unget", key, next

  remove: (key, next) ->
    @router.route "remove", key, next

module.exports = ConnectorClient