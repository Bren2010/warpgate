assert = require "assert"
invert = require "invert-stream"
upnode = require "upnode"
{_}    = require "UnderscoreKit"

load      = require "load"
connector = load "connectors/server"

describe "connectors/server", () ->
  beforeEach () ->
    @server  = connector()
    @down    = @server.getStream()
    @stream  = invert()
    @down.pipe(@stream).pipe(@down)
    @up = upnode.connect { createStream: () => @stream.other }
  describe "set", () ->
    it "should emit set when called from a remote", (next) ->
      @server.on "set", (id, key, data, next) ->
        assert.equal "k", key
        assert.equal "v", data
        next()
      @up (client) -> client.set "k", "v", next

  describe "get", () ->
    it "should emit get when called from a remote", (next) ->
      @server.on "get", (id, key, next) ->
        assert.equal "k", key
        next()
      @up (client) -> client.get "k", next

  describe "unget", () ->
    it "should emit unget when called from a remote", (next) ->
      @server.on "unget", (id, key, next) ->
        assert.equal "k", key
        next()
      @up (client) -> client.unget "k", next

  describe "remove", () ->
    it "should emit remove when called from a remote", (next) ->
      @server.on "remove", (id, key, next) ->
        assert.equal "k", key
        next()
      @up (client) -> client.remove "k", next