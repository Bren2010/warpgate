{_}            = require "UnderscoreKit"
{EventEmitter} = require "events"

class Item extends EventEmitter
  constructor: (@client, @key, @value) ->
    console.log "in emitter"
    _.bindAll this
    @client.on "got:#{@key}", @_setter

  get: () -> @value

  set: (value, next) ->
    @client.set @key, value, next

  remove: (next) ->
    @client.remove @key, next

  unref: () ->
    @client.removeListener "got:#{@key}", @_setter
    @client.unref @key

  _setter: (@value) ->
    @emit "change", @value

module.exports = Item