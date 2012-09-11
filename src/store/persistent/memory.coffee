{_}            = require "UnderscoreKit"
{EventEmitter} = require "events"

exports = module.exports = () ->
  _self = new EventEmitter()
  _data = {}

  _.bindAll _.extend _self,
    get: (key, next) ->
      if not _data[key]?
        next "undefined key", false
      else
        _self.emit "get:#{key}"
        _self.emit "get", key
        next false, _data[key]

    set: (key, data, next) ->
      _data[key] = data
      _self.emit "set:#{key}", data
      _self.emit "set", key, data
      next false, true

    remove: (key, next) ->
      if not _data[key]?
        next "undefined key", false
      else
        delete _data[key]
        _self.emit "remove:#{key}"
        _self.emit "remove", key
        next false, true