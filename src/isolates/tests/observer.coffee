async          = require "async"
{EventEmitter} = require "events"
{_}            = require "UnderscoreKit"
ben            = require "ben"

load     = require "load"
warpgate = load "warpgate"

errorHandler = (error) -> console.log error

upstream = [
  "0.0.0.0:2200"
  "0.0.0.0:2201"
  "0.0.0.0:2202"
  "0.0.0.0:2203"
]

itterations = 10000

_client = warpgate()
_client.connect upstream, _.pass(() ->
  console.log "client ready"
  tick = () ->
    setTimeout(() ->
      _client.get "users:lohkey", (error, data) ->
        console.log data
        tick()
    , 500)
  tick()
, errorHandler)