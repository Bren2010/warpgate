{EventEmitter} = require "events"
{_}            = require "UnderscoreKit"
upnode         = require "upnode"

class ConnectorServer extends EventEmitter
  clientId: 0
  server:   null

  constructor: () ->
    self = this
    _.bindAll this
    @server = upnode () ->
      @_id = self.clientId++
      set:    (key, data, next) => self.emit "set",    @_id, key, data, next
      get:    (key, next)       => self.emit "get",    @_id, key, next
      unget:  (key, next)       => self.emit "unget",  @_id, key, next
      remove: (key, next)       => self.emit "remove", @_id, key, next

  listen: (port) -> @server.listen port
  getStream: ()  -> @server

module.exports = ConnectorServer