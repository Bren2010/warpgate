{_}            = require "UnderscoreKit"
{EventEmitter} = require "events"

exports = module.exports = () ->
  _self = new EventEmitter()

  _refs =
    counters: {}
    used:     {}
    unused:   {}

  _hasLocalRef  = (key) -> _hasUsedRef(key) or _hasUnusedRef(key)
  _hasUsedRef   = (key) -> not _.isUndefined _refs.used[key]
  _hasUnusedRef = (key) -> not _.isUndefined _refs.unused[key]

  _increaseRefCount = (key) ->
    if not _refs.counters[key]?
      _reuseExistingRef key
      _refs.counters[key] = 1
    else
      ++_refs.counters[key]
    _refs.used[key]

  _decreaseRefCount = (key) ->
    if not _refs.counters[key]?
      ["Attempting to unrefrence a non referenced key", false]
    else
      if _refs.counters[key] <= 0
        ["Attempting to unrefrence a key with 0 references", false]
      else
        _refs.counters[key]--
        _isolateUnusedRef key
        [false, _refs.counters[key]]

  _isolateUnusedRef = (key) ->
    if _refs.counters[key] <= 0
      if _hasUsedRef key
        ["Attempting to isolate a ref already marked as unused", false]
      else
        if not _hasUsedRef key
          ["Attempting to isolate a ref that isn't in use", false]
        else
          _refs.unused[key] = _refs.used[key]
          delete _refs.used[key]
          [false, _refs.unused[key]]
    else
      [false, true]

  _reuseExistingRef = (key) ->
    if not _hasUnusedRef key
      ["That key doesn't exist in our unused store", false]
    else
      if _hasUsedRef key
        ["That key is already marked as in use", false]
      else
        _refs.used[key] = _refs.unused[key]
        delete _refs.unused[key]
        [false, _refs.used[key]]

  _.bindAll _.extend _self,
    has: _hasLocalRef
    get: (key) ->
      if _hasLocalRef key
        [false, _increaseRefCount key]
      else
        ["Attempting to get a node we don't have locally", false]
    set: (key, data) ->
      if _hasUsedRef key
        _refs.used[key] = data
      else
        _refs.unused[key] = data
    unref: (key) ->
      if _.isUndefined _refs.counters[key]
        ["Attempting to unrefrence a non referenced key", false]
      else
        if _refs.counters[key] <= 0
          ["Attempting to unrefrence a key with 0 references", false]
        else
          _decreaseRefCount key
          [false, _refs.counters[key]]
