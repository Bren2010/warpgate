async          = require "async"
{EventEmitter} = require "events"
{_}            = require "UnderscoreKit"

load     = require "load"
warpgate = load "warpgate"

errorHandler = (error) -> console.log error

upstream = [
  "0.0.0.0:2100"
  "0.0.0.0:2101"
  "0.0.0.0:2102"
  "0.0.0.0:2103"
]

itterations = 0

client = warpgate()
client.connect upstream
console.log "client ready"
tick = () ->
  setTimeout(() ->
    client.set "users:lohkey", version: ++itterations, () ->
      tick()
  , 300)
tick()