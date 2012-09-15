assert = require "assert"
upnode = require "upnode"
invert = require "invert-stream"
{_}    = require "UnderscoreKit"

load      = require "load"
connector = load "connectors/client"

fakeUpstream = [
  "0.0.0.0:2200"
  "0.0.0.0:2201"
  "0.0.0.0:2202"
  "0.0.0.0:2203"
]

fakeHandlers =
  get:    (key, next)       -> next()
  set:    (key, data, next) -> next()
  unget:  (key, next)       -> next()
  remove: (key, next)       -> next()

getStreamMap = () -> _.reduce(fakeUpstream, (memo, target) ->
  inverted = invert()
  server   = upnode fakeHandlers
  writer = inverted.other.write
  inverted.other.write = (args...) -> setTimeout(() =>
    writer.apply this, args
  , 1)
  server.pipe(inverted).pipe(server)
  memo[target] = upnode.connect { createStream: () -> inverted.other }
  memo
, {})

describe "connectors/client", () ->
  beforeEach () ->
    @client = connector getStreamMap()
  describe ".get", () ->
    it "should route the request upstream and receive a response", (next) ->
      @client.get "k", next

  describe ".set", () ->
    it "should route the request upstream and receive a response", (next) ->
      @client.set "k", "v", next

  describe ".unget", () ->
    it "should route the request upstream and receive a response", (next) ->
      @client.unget "k", next

  describe "remove", () ->
    it "should route the request upstream and receive a response", (next) ->
      @client.remove "k", next