{EventEmitter} = require "events"
{_}            = require "UnderscoreKit"
upnode         = require "upnode"
hashring       = require "hashring"

getRouter = (upstream, next) ->
  ring  = new hashring(upstream);
  nodes = _.reduce(upstream, (memo, pair) ->
    [host, port] = pair.split ":"
    memo[pair] = upnode.connect port, host
    memo
  , {})
  wrapper = (name) -> (args...) ->
    [key] = args
    dest  = ring.getNode key
    nodes[dest] (remote) -> remote[name].apply this, args
  nodes[ring.getNode "a"] (remote) ->
    next _.reduce(_.keys(remote), (memo, name) ->
      memo[name] = wrapper name
      memo
    , {})

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
      queue = queue[key]
      delete queue[key]
      next error, data for next in queue

  getRouter upstream, (router) -> next false,
    _.bindAll _.extend self,
      get: (key, next) ->
        if not fetchIsQueued key then router.get key, createQueueRunner key
        queueCallback key, next

      set: (key, data, next) ->
        router.set key, data, next

      unget: (key, next) -> router.unget key, next

      remove: (key, next) -> router.remove key, next