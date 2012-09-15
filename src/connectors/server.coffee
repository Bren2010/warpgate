{EventEmitter} = require "events"
{_}            = require "UnderscoreKit"
upnode         = require "upnode"

exports = module.exports = () ->
  self = new EventEmitter()
  clientId = 0

  server = upnode
    set:    (key, data, next) -> self.emit "set",    @_id, key, data, next
    get:    (key, next)       -> self.emit "get",    @_id, key, next
    unget:  (key, next)       -> self.emit "unget",  @_id, key, next
    remove: (key, next)       -> self.emit "remove", @_id, key, next

  server.on "local", (ref) ->
    ref._id = ++clientId
    _.bindAll ref

  _.bindAll _.extend self,
    listen: (port) -> server.listen port
    getStream:  () -> server
