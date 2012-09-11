{EventEmitter} = require "events"
{_}            = require "UnderscoreKit"
upnode         = require "upnode"

exports = module.exports = () ->
  _self = new EventEmitter()
  _clientId = 0

  _server = upnode
    set:    (key, data, next) -> _self.emit "set",    @_id, key, data, next
    get:    (key, next)       -> _self.emit "get",    @_id, key, next
    unget:  (key, next)       -> _self.emit "unget",  @_id, key, next
    remove: (key, next)       -> _self.emit "remove", @_id, key, next

  _server.on "local", (ref) ->
    ref._id = ++_clientId
    _.bindAll ref

  _.bindAll _.extend _self,
    listen: (port) -> _server.listen port
