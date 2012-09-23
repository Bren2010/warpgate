async          = require "async"
{EventEmitter} = require "events"
{_}            = require "UnderscoreKit"

load     = require "load"
Warpgate = load "warpgate"

upstream = [
  "0.0.0.0:2100"
  "0.0.0.0:2101"
  "0.0.0.0:2102"
  "0.0.0.0:2103"
]

itterations = 10000

client = new Warpgate()
client.connect upstream
console.log "client ready"
tick = () ->
  setTimeout(() ->
    client.get "users:lohkey", (error, data) ->
      console.log data
      tick()
  , 500)
tick()