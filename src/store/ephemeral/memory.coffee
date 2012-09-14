{_}            = require "UnderscoreKit"
{EventEmitter} = require "events"

exports = module.exports = () ->
  self = new EventEmitter()

  refs =
    used:     {}
    unused:   {}

  hasLocalRef  = (key) -> hasUsedRef(key) or hasUnusedRef(key)
  hasUsedRef   = (key) -> refs.used[key]?
  hasUnusedRef = (key) -> refs.unused[key]?

  reuseExistingRef = (key) ->
    if hasUnusedRef key
      refs.used[key] = refs.unused[key]
      delete refs.unused[key]
    refs.used[key]

  _.bindAll _.extend self,
    has: hasLocalRef
    get: (key) ->
      self.emit "get", key
      if hasLocalRef key
        [false, reuseExistingRef key]
      else
        ["Attempting to get a node we don't have locally", false]
    set: (key, data) ->
      self.emit "set", key, data
      if hasUsedRef key
        refs.used[key] = data
      else
        refs.unused[key] = data
    unref: (key) ->
      if not hasUsedRef key
        ["Attempting to unref an unused key", false]
      else
        refs.unused[key] = refs.used[key]
        delete refs.used[key]
        [false, true]
