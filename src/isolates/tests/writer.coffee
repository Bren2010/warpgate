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

itterations = 0

_client = warpgate()
_client.connect upstream, _.pass(() ->
  console.log "client ready"
  tick = () ->
    setTimeout(() ->
      _client.set "users:lohkey", version: ++itterations, () ->
        tick()
    , 300)
  tick()
, errorHandler)