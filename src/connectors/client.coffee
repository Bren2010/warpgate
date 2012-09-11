{EventEmitter} = require "events"
{_}            = require "UnderscoreKit"
upnode         = require "upnode"
hashring       = require "hashring"

_getRouter = (upstream, next) ->
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
  _self   = new EventEmitter();
  _queue  = {}

  _fetchIsQueued = (key) -> _queue[key]? and _queue[key].length

  _queueCallback = (key, next) ->
    if _queue[key]?
      _queue[key].push next
    else
      _queue[key] = [next]

  _createQueueRunner = (key) -> (error, data) ->
    _self.emit "got", key, data
    _self.emit "got:#{key}", data
    if _queue[key]?
      queue = _queue[key]
      delete _queue[key]
      next error, data for next in queue

  _getRouter upstream, (router) -> next false,
    _.bindAll _.extend _self,
      get: (key, next) ->
        if not _fetchIsQueued key then router.get key, _createQueueRunner key
        _queueCallback key, next

      set: (key, data, next) ->
        router.set key, data, next

      unget: (key, next) -> router.unget key, next

      remove: (key, next) -> router.remove key, next